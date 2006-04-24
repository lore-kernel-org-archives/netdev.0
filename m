From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: Van Jacobson's net channels and real-time
Date: Mon, 24 Apr 2006 10:28:41 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F143AAE5@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:15115 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1750949AbWDXR2x convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 13:28:53 -0400
Received: from mail-irva-8.broadcom.com (mail-irva-8 [10.10.64.221]) by
 mail-irva-10.broadcom.com (Postfix) with ESMTP id 81A3E2AE for
 <netdev@vger.kernel.org>; Mon, 24 Apr 2006 10:28:42 -0700 (PDT)
Received: from NT-SJCA-0751.brcm.ad.broadcom.com (nt-sjca-0751
 [10.16.192.221]) by mail-sj1-12.sj.broadcom.com (Postfix) with ESMTP id
 2CB1E20501 for <netdev@vger.kernel.org>; Mon, 24 Apr 2006 10:28:42
 -0700 (PDT)
Content-class: urn:content-classes:message
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> Subject: Re: Van Jacobson's net channels and real-time
>=20
>=20
> On Mon, 24 Apr 2006, Auke Kok wrote:
>=20
>> Ingo Oeser wrote:
>>> On Saturday, 22. April 2006 15:49, J=F6rn Engel wrote:
>>>> That was another main point, yes.  And the endpoints should be as
>>>> little burden on the bottlenecks as possible.  One bottleneck is
>>>> the receive interrupt, which shouldn't wait for cachelines from
>>>> other cpus too much.
>>>=20
>>> Thats right. This will be made a non issue with early demuxing on
>>> the NIC and MSI (or was it MSI-X?) which will select the right CPU
>>> based on hardware channels.
>>=20
>> MSI-X. with MSI you still have only one cpu handling all MSI
>> interrupts and that doesn't look any different than ordinary
>> interrupts. MSI-X will allow much better interrupt handling across
>> several cpu's.=20
>>=20
>> Auke
>> -
>=20
> Message signaled interrupts are just a kudge to save a trace
> on a PC board (read make junk cheaper still). They are not
> faster and may even be slower. They will not be the salvation
> of any interrupt latency problems. The solutions for
> increasing networking speed, where the bit-rate on the wire
> gets close to the bit-rate on the bus, is to put more and
> more of the networking code inside the network board. The CPU
> get interrupted after most things (like network handshakes)
> are complete.
>=20

The number of hardware interrupts supported is a bit out of scope.
Whatever the capacity is, the key is to have as few meaningless
interrupts as possible.

In the context of netchannels this would mean that an interrupt
should only be fired when there is a sufficient number of packets
for the user-mode code to process. Fully offloading the protocol
to the hardware is certainly one option, that I also thinks make
sense, but the goal of netchannels is to try to optimize performance
while keeping TCP processing on host.

More hardware offload is distinctly possible and relevant in this
context. Statefull offload, such as TSO, are fully relevant.
Going directly from the NIC to the channel is also possible (after
the channel is set up by the kernel, of course). If the NIC is
aware of the channels directly then interrupts can be limited to
packets that cross per-channel thresholds configured directly
by the ring consumer.


