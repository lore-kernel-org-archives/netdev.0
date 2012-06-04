From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Mon, 4 Jun 2012 22:22:01 +0300
Message-ID: <CAEnQRZCNUYmP88Ocm_nG7gpA1Qcwy1tOc6kgCgZ7RqXcxQsHhg@mail.gmail.com>
References: <4FCCFE76.3060304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:49877 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221Ab2FDTWC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 15:22:02 -0400
Received: by vcbf11 with SMTP id f11so2675673vcb.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 12:22:01 -0700 (PDT)
In-Reply-To: <4FCCFE76.3060304@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 4, 2012 at 9:29 PM, Ben Greear <greearb@candelatech.com> wr=
ote:
> I'm going some TCP performance testing on wifi -> LAN interface conne=
ctions.
> =A0With
> UDP, we can get around 250Mbps of payload throughput. =A0With TCP, ma=
x is
> about 80Mbps.
>
> I think the problem is that there are way too many ACK packets, and
> bi-directional
> traffic on wifi interfaces really slows things down. =A0(About 7000 p=
kts per
> second in
> upload direction, 2000 pps download. =A0And the vast majority of the =
download
> pkts
> are 66 byte ACK pkts from what I can tell.)
>
> Kernel is 3.3.7+
>
> Anyone know of any tuning parameters that would let the receiving soc=
ket
> wait a
> bit longer and send more ACK data in fewer packets?

An ACK is generated after every second full sized segment or a timeout
expires.

Currently, there is no way to tune these parameters. Here is an experim=
ental
patch [1]. If anyone, thinks that this patch has a chance to get accept=
ed
I will be happily try to further improve it.

>
> Packet traces and other info available if anyone wants to take a look=
=2E

thanks,
Daniel.

[1] http://marc.info/?l=3Dlinux-netdev&m=3D131983649130350&w=3D2
