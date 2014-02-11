From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bonding
Date: Tue, 11 Feb 2014 09:55:35 -0800
Message-ID: <27459.1392141335@death.nxdomain>
References: <8532C3BD1ECBC64BA47CE43AFED6D38EC37E5AA5@S103.efacec.pt> <20140211141549.GB29570@redhat.com> <8532C3BD1ECBC64BA47CE43AFED6D38EC37E5B04@S103.efacec.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gustavo Pimentel <gustavo.pimentel@efacec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:46590 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbaBKR4N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 12:56:13 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 11 Feb 2014 10:56:12 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 4782F19D8042
	for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 10:56:09 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1BHu4Rp10420544
	for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 18:56:09 +0100
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1BHtnDh026334
	for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 10:55:49 -0700
In-reply-to: <8532C3BD1ECBC64BA47CE43AFED6D38EC37E5B04@S103.efacec.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gustavo Pimentel <gustavo.pimentel@efacec.com> wrote:

>Hi Veaceslav,
>
>It's quite different from broadcast mode, each frame sent through the =
slaves has attached a Redundancy Control Trailer also known as RCT (thi=
s trailer is compose by a LAN identifier, sequence number, a LSDU size =
and a PRP suffix).
>Also the equipment with PRP capability has to send periodically a supe=
rvision frame to both similar LANs. Each device on the network has to k=
eep track of receive sequence numbers received, if the received a seque=
nce number for instance from LAN A of specific device and it doesn't ex=
ist on internal table, the device should accept the frame and update th=
e internal table. When receiving the same sequence number from the LAN =
B, the device should discard it, providing zero downtime redundancy.
>
>I can supply you information about this redundancy protocol, if you li=
ke. This type of network redundancy is now being large deployed on elec=
trical power stations (like thermal and hydro) and transmission power s=
tations instead of teaming / bonding that depends on RSTP for redundanc=
y.

	Are you aware that there is already an implementation of HSR
(High-availability Seamless Redundancy) in the linux kernel?  I believe
HSR and PRP are defined by the same standard (IEC 62439-3), and are
similar enough to interoperate to some degree.  Perhaps PRP would be
better implemented as a variant within the existing net/hsr/ framework.

	-J


>> -----Original Message-----
>> From: Veaceslav Falico [mailto:vfalico@redhat.com]
>> Sent: ter=C3=A7a-feira, 11 de Fevereiro de 2014 14:16
>> To: Gustavo Pimentel
>> Cc: netdev@vger.kernel.org
>> Subject: Re: Bonding
>>=20
>> On Tue, Feb 11, 2014 at 01:53:32PM +0000, Gustavo Pimentel wrote:
>> >Hi,
>>=20
>> Hi Gustavo,
>>=20
>> >
>> >I'm writing you because because I'm have implemented a new mode (PR=
P Parallel
>> Redundancy Protocol) for bonding kernel driver. This new mode is qui=
te simple, I
>> don't know if you have heard about PRP, but it's a new standard that=
 allows to
>> overcome any single network failure without affecting the data trans=
mission. The
>> general idea resides on having two separate LAN (A & B) very similar=
 and
>> transmitting the almost the same frame=C2=A0through both LANs and th=
e end device
>> should accept one frame and discard the other according to a known m=
echanism.
>>=20
>> Isn't that the current 'broadcast' mode, where every packet is trans=
mitted over all
>> the slaves? After quick googling/reading I don't see any difference =
there, though I
>> might have missed something.
>>=20
>> >
>> >I have implemented this new mode on bonding driver, but I have some
>> difficulties:
>> >. Writing linux driver is quite new for me. I don't' know if exists=
 guide lines for
>> driver coding.
>>=20
>> You can find everything under Documentation/, but without the code I=
 can't tell you
>> exact documents. CodingStyle and SubmittingPatches might be the firs=
t ones.
>>=20
>> Also, try CC-ing relevant people for more feedback, specifically bon=
ding
>> maintainers.
>>=20
>> >. I don't know how to submit the code to be include on kernel repos=
itory.
>> >. Maybe another pair of eyes could find help to improve the writing=
 code for this
>> mode.
>>=20
>> Try sending an RFC when net-next opens.
>>=20
>> >
>> >I think my driver code is 99% complete. I'm currently testing with =
3 equipments (1
>> pc + 1 embedded device running both my modify bonding driver) and a =
third party
>> equipment called RedBox.
>> >
>> >Would you be interested in participating / helping this project?
>> >
>> >With my best regards,
>> >
>> >Gustavo Gama da Rocha Pimentel
>> >Power Systems Automation / Innovation & Development Efacec Engenhar=
ia e
>> >Sistemas, S.A.
>> >Phone: +351229403391
>> >Disclaimer

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
