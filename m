From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH] tcp: fix ICMP-RTO war
Date: Fri, 29 Jan 2010 13:13:18 +0100
Message-ID: <4B62D0DE.9050706@tvk.rwth-aachen.de>
References: <201001271556.16156.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:53003 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752916Ab0A2MNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 07:13:20 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KX0009DICM7D6A0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Fri, 29 Jan 2010 13:13:19 +0100 (CET)
In-reply-to: <201001271556.16156.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko schrieb:
> On Wednesday 27 January 2010 14:36:18 you wrote:
>> Unless they are for a different connection? We might have to print s=
k (%p)
>> in all those printouts to be sure which maps to which. If a peer bec=
omes
>> unreachable, it may well have multiple connections open (this was a
>> proxy, iirc?).
>>
> Ok i will try to do that today.
>=20
> Most probably different connections, on this proxy i have 10-15k esta=
blished=20
> connections at peak time.

In total, there are probably multiple sockets involved, but for the pat=
tern
I mentioned, I doubt that. The pattern is all over the place; look at a=
nother
sample:

> [ 1497.679255] rto: 200 (0 >> 3 + 0, 21) time: 1197679 sent: 1197679 =
pen: 1 1198079 rem: 200                                                =
                                    =20
> [ 1497.679356] rto: 120000 (18111 >> 3 + 2633, 7) time: 1197679 sent:=
 1195423 pen: 1 1315423 rem: 117744                                    =
                                    =20
> [ 1501.113786] rto: 200 (0 >> 3 + 0, 24) time: 1201113 sent: 1200679 =
pen: 1 1203879 rem: 0                                                  =
                                    =20
> [ 1501.116064] rto: 120000 (17704 >> 3 + 4426, 8) time: 1201116 sent:=
 1198638 pen: 1 1318638 rem: 117522                                    =
                                    =20
> [ 1501.116216] rto: 200 (0 >> 3 + 0, 24) time: 1201116 sent: 1201113 =
pen: 1 1201513 rem: 197                                                =
                                    =20
> [ 1504.165953] rto: 200 (0 >> 3 + 0, 27) time: 1204165 sent: 1204113 =
pen: 1 1207313 rem: 148                                                =
                                    =20
> [ 1504.168151] rto: 200 (0 >> 3 + 0, 26) time: 1204168 sent: 1204113 =
pen: 1 1204313 rem: 145                                                =
                                    =20
> [ 1504.168327] rto: 200 (0 >> 3 + 0, 25) time: 1204168 sent: 1204113 =
pen: 1 1204313 rem: 145                                                =
                                    =20
> [ 1507.280096] rto: 200 (0 >> 3 + 0, 28) time: 1207280 sent: 1207113 =
pen: 1 1210313 rem: 33                                                 =
                                    =20
> [ 1507.280255] rto: 200 (0 >> 3 + 0, 27) time: 1207280 sent: 1207113 =
pen: 1 1207313 rem: 33                                                 =
                                    =20
> [ 1510.974574] rto: 200 (0 >> 3 + 0, 30) time: 1210974 sent: 1210113 =
pen: 1 1213313 rem: 0                                                  =
                                    =20
> [ 1510.974766] rto: 200 (0 >> 3 + 0, 30) time: 1210974 sent: 1210974 =
pen: 1 1211374 rem: 200                                                =
                                    =20
> [ 1514.436214] rto: 200 (0 >> 3 + 0, 33) time: 1214436 sent: 1213974 =
pen: 1 1217174 rem: 0                                                  =
                                    =20
> [ 1514.436378] rto: 200 (0 >> 3 + 0, 33) time: 1214436 sent: 1214436 =
pen: 1 1214836 rem: 200                                                =
                                    =20
> [ 1514.436525] rto: 200 (0 >> 3 + 0, 32) time: 1214436 sent: 1214436 =
pen: 1 1214636 rem: 200                                                =
                                    =20
> [ 1517.516537] rto: 200 (0 >> 3 + 0, 35) time: 1217516 sent: 1217436 =
pen: 1 1220636 rem: 120                                                =
                                    =20
> [ 1517.520724] rto: 200 (0 >> 3 + 0, 34) time: 1217520 sent: 1217436 =
pen: 1 1217636 rem: 116                                                =
                                    =20
> [ 1517.520919] rto: 200 (0 >> 3 + 0, 33) time: 1217520 sent: 1217436 =
pen: 1 1217636 rem: 116                                                =
                                    =20
> [ 1520.580000] rto: 200 (0 >> 3 + 0, 36) time: 1220579 sent: 1220436 =
pen: 1 1223636 rem: 57                                                 =
                                    =20
> [ 1520.580165] rto: 200 (0 >> 3 + 0, 35) time: 1220580 sent: 1220436 =
pen: 1 1220637 rem: 56                                                 =
                                    =20
> [ 1520.580744] rto: 200 (0 >> 3 + 0, 34) time: 1220580 sent: 1220436 =
pen: 1 1220636 rem: 56            =20

The two 120000ms RTOs are a different socket, but the rest is one socke=
t,
I believe. There is the sequence (N+2, N+1, N) for backoff, followed by
3 seconds silence, which I assume, are used for regular RTO retransmiss=
ions,
and then again a burst of ICMPs.
The three seconds are enough to fire backed-off retransmissions at
t+0.2, t+0.6, t+1.4 and t+3.0. There is a slight deviation of this patt=
ern
when rem becomes 0.

This pattern is too perfect to be triggered by different sockets, I thi=
nk.
But we will see, when Denys submits new test outputs.

>=20
> Also about estimating rtt, maybe there is something wrong in idea. Ju=
st what=20
> will happen if ip visible for proxy have multiple people behind? It c=
an be=20
> small router for hotspot and 10-20 people behind it,  some with very =
large=20
> rtt, some with very small.
>=20
> And some of them getting disconnected (out of range from wireless, fo=
r=20
> example), and thats most probably why host unreachable sent... at sam=
e time=20
> proxy have established and running tcp connections with other people =
on same=20
> router (means for proxy same ip).

Sockets are identified on a (src-ip, src-port)::(dst-ip, dst-port) quad=
ruple basis,
so RTT calculation usually is independent even for same ip-pairs, unles=
s
with TCB interdependence. But I don't know if that is implemented and/o=
r enabled
by default.

Regards
 Damian

> Sorry, again to Ilpo J=E4rvinen, by default i have reply, instead of =
reply all.
