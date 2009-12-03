From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: scp stalls mysteriously
Date: Thu, 03 Dec 2009 16:34:12 +0100
Message-ID: <4B17DA74.3070600@nets.rwth-aachen.de>
References: <20091130213727.2f4047d2@houba>
 <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi>
 <20091201211945.505d3c98@houba>
 <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
 <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
 <20091202154403.GB30730@sd-11162.dedibox.fr>
 <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
 <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr>
 <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
 <4B17CABE.8070402@nets.rwth-aachen.de>
 <alpine.DEB.2.00.0912031630390.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frederic Leroy <fredo@starox.org>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:35187 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753509AbZLCPeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 10:34:24 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KU3005YF1XIVXD0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 03 Dec 2009 16:34:30 +0100 (CET)
In-reply-to: <alpine.DEB.2.00.0912031630390.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Thu, 3 Dec 2009, Arnd Hannemann wrote:
>=20
>> Ilpo J=E4rvinen wrote:
>>
>> [snipped]
>>
>>> Also, we have the another mystery to be solved, the fast retransmis=
sion is=20
>>> not triggered for some reason (or alternatively not captured in to =
a=20
>>> log), even in the working .9. case. It would be easy to see whether=
 it=20
>>> works at all from TCP point of view by looking into mibs once you h=
ave=20
>>> have some transfers in a working configuration:
>>>
>>> grep -A1 TCP /proc/net/netstat
>>>
>>> ...luckily this fast retransmit issue is less crucial as almost all=
 people=20
>>> are pretty happy already if their RTO-based recovery works even if =
the=20
>>> fast recovery would not. So figuring it out can be postponed (if on=
e has=20
>>> to prioritize) until the silent death issue is out of the way.
>>>
>>>
>> I looked at the working .9 case stream from 192.168.1.15 to 192.168.=
1.19.
>> I don't think it is a mystery that fast retransmit does not trigger.
>> The condition SACKED_DATA > 3* SMSS is simply not fulfilled.
>> Neither are there 3 non-continuous SACK sequences.
>> The segments sent are too small :-(
>> Interesting though, seems to me in this case non-SACK would be bette=
r than SACK.
>> Or did I miss something?
>=20
> Yes, a particularly big one, linux does not count SACKs bytes but pac=
kets.=20
> In the first recovery, plenty of packets are SACKed:
>=20
>     135 sack 1 {2598:2646}>
>     108 sack 1 {2598:2694}>
>     121 sack 1 {2598:2742}>
>      95 sack 1 {2598:2790}>
>     426 sack 1 {2598:2838}>
>=20
> fackets_out should be 6 now which is way more than 3 which is the=20
> default tp->reordering.

Ok, you probable know better than me.
But, aren't the SKBs collapsed to SMSS size segments and then
counted? I thought so.
The 3*SMSS restriction is from RFC 3517, but of course you know.

>=20
>> Hey we could cook up a draft for this problem ;-)
>>
>> Anyway, real problem is, RTO does not trigger...
>=20
> There are two problems. ...Both are real. ;-) But significance of the=
=20
> other is much worse than the other.

I agree.
I'm already trying to get scp stalling, but no luck so far. Neither wit=
h
artificially dropping packets, nor using WLAN :-(


Best regards,
Arnd
