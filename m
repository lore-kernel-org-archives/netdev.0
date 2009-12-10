From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: Crazy TCP bug (keepalive flood?) in 2.6.32?
Date: Thu, 10 Dec 2009 11:05:26 +0100
Message-ID: <4B20C7E6.3040105@tvk.rwth-aachen.de>
References: <200912092051.18258.denys@visp.net.lb>
 <alpine.DEB.2.00.0912101019490.23376@melkinpaasi.cs.helsinki.fi>
 <alpine.DEB.2.00.0912101025260.23376@melkinpaasi.cs.helsinki.fi>
 <alpine.DEB.2.00.0912101044190.23376@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:59438 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932856AbZLJKFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 05:05:40 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KUF0043OLDLANE0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 10 Dec 2009 11:05:45 +0100 (CET)
In-reply-to: <alpine.DEB.2.00.0912101044190.23376@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen schrieb:
> On Thu, 10 Dec 2009, Ilpo J=E4rvinen wrote:
>=20
>> On Thu, 10 Dec 2009, Ilpo J=E4rvinen wrote:
>>
>>> Cc Damian.
>>>
>>> On Wed, 9 Dec 2009, Denys Fedoryshchenko wrote:
>>>
>>>> Hi
>>>>
>>>> I did upgrade of my lusca(squid) proxies and notice that some user=
s getting up=20
>>>> to 8-15 Mbit/s flood (while they are shaped to 128Kbit/s). After t=
racing i end=20
>>>> up on  one of proxies host and seems it is bug in kernel tcp stack=
=2E
>>>>
>>>> I check packets inside - it is same repeating content (and even sa=
me tcp=20
>>>> sequence, so it is almost sure tcp bug). Sender also ignoring ICMP=
 unreachable=20
>>>> packets and continue flooding destination

By "also" you mean, that the sender is flooding with and without ICMPs?

>>>>
>>>> Here is some examples
>>>> ss output for corresponding entry
>>>>
>>>> ESTAB      0      8267        194.146.153.114:8080         172.16.=
67.243:2512
>>>>
>>>>
>>>> 20:32:08.491470 IP (tos 0x0, ttl 64, id 49493, offset 0, flags [DF=
], proto TCP=20
>>>> (6), length 655)
>>>>     194.146.153.114.8080 > 172.16.67.243.2512: Flags [P.], cksum 0=
xce63=20
>>>> (correct), seq 0:615, ack 1, win 7504, length 615
>>>> 20:32:08.492487 IP (tos 0x0, ttl 64, id 49494, offset 0, flags [DF=
], proto TCP=20
>>>> (6), length 655)
>>>>     194.146.153.114.8080 > 172.16.67.243.2512: Flags [P.], cksum 0=
xce63=20
>>>> (correct), seq 0:615, ack 1, win 7504, length 615
>>>> 20:32:08.493468 IP (tos 0x0, ttl 64, id 49495, offset 0, flags [DF=
], proto TCP=20
>>>> (6), length 655)
>>>>     194.146.153.114.8080 > 172.16.67.243.2512: Flags [P.], cksum 0=
xce63=20
>>>> (correct), seq 0:615, ack 1, win 7504, length 615
>>>> 20:32:08.494463 IP (tos 0x0, ttl 64, id 49496, offset 0, flags [DF=
], proto TCP=20
>>>> (6), length 655)
>>>>     194.146.153.114.8080 > 172.16.67.243.2512: Flags [P.], cksum 0=
xce63=20
>>>> (correct), seq 0:615, ack 1, win 7504, length 615
>>>> 20:32:08.495463 IP (tos 0x0, ttl 64, id 49497, offset 0, flags [DF=
], proto TCP=20
>>>> (6), length 655)
>>>>     194.146.153.114.8080 > 172.16.67.243.2512: Flags [P.], cksum 0=
xce63=20
>>>> (correct), seq 0:615, ack 1, win 7504, length 615
>>>> 20:32:08.496467 IP (tos 0x0, ttl 64, id 49498, offset 0, flags [DF=
], proto TCP=20
>>>> (6), length 655)
>>>>
>>>>
>>>> One more
>>>> 20:36:13.310718 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags=
 [.], ack 1,=20
>>>> win 7469, length 1440
>>>> 20:36:13.311725 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags=
 [.], ack 1,=20
>>>> win 7469, length 1440
>>>> 20:36:13.312729 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags=
 [.], ack 1,=20
>>>> win 7469, length 1440
>>>> 20:36:13.313717 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags=
 [.], ack 1,=20
>>>> win 7469, length 1440
>>>> 20:36:13.314717 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags=
 [.], ack 1,=20
>>>> win 7469, length 1440
>>>> 20:36:13.315718 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags=
 [.], ack 1,=20
>>>> win 7469, length 1440
>>>> 20:36:13.316725 IP 194.146.153.114.8080 > 172.16.49.30.1319: Flags=
 [.], ack 1,=20
>>>> win 7469, length 1440
>>>>
>>>> I run multiple times ss
>>>>
>>>> ESTAB      0      7730        194.146.153.114:8080          172.16=
=2E49.30:1319  =20
>>>> timer:(on,,172) uid:101 ino:4772596 sk:c0ce84c0
>>>> ESTAB      0      7730        194.146.153.114:8080          172.16=
=2E49.30:1319  =20
>>>> timer:(on,,43) uid:101 ino:4772596 sk:c0ce84c0
>>>> ESTAB      0      7730        194.146.153.114:8080          172.16=
=2E49.30:1319  =20
>>>> timer:(on,,17) uid:101 ino:4772596 sk:c0ce84c0
>>>>
>>>> After i kill squid it will  switch socket to FIN-WAIT state and fl=
ood will=20
>>>> stop.
>>>>
>>>> Some sysctl tuning done during boot (maybe related)
>>>> sysctl -w net.ipv4.tcp_frto=3D2
>>>> sysctl -w net.ipv4.tcp_frto_response=3D2
>>>>
>>>> And most probably it is related to keepalive. I have it set on thi=
s socket:
>>>> http_port 8080 transparent tcpkeepalive=3D30,30,60 http11         =
                                                                       =
                                                                  =20
>>>>
>>>> From manual
>>>> #<----->   tcpkeepalive[=3Didle,interval,timeout]
>>>> #<-----><------><------>Enable TCP keepalive probes of idle connec=
tions
>>>> #<-----><------><------>idle is the initial time before TCP starts=
 probing
>>>> #<-----><------><------>the connection, interval how often to prob=
e, and
>>>> #<-----><------><------>timeout the time before giving up.
>>>>
>>>> I am not able to reproduce reliably bug, but it is appearing on di=
fferent=20
>>>> cluster pc's randomly for single connection each 5-10 minutes (aro=
und 8000=20
>>>> established connections to each at moment, 8 pc's in cluster) and =
dissapearing=20
>>>> after 10-50 seconds of flood.
>>> Damian, can you please take a look. ...It's a bit weird after a ver=
y brief=20
>>> look (as if RTO would trigger way too often). Maybe its backoff is =
broken=20
>>> now?
>> ...I meant broken when keepalives are in use.
>=20
> I guess it's that the ICMPs are somehow triggering the=20
> tcp_retransmit_timer call in tcp_ipv4 even though they're not suppose=
d=20
> to do that until the RTO timeout would have fired. I've no idea why=20
> remaining doesn't do what it's supposed to.
>=20

Hm.
Those ICMPs will trigger only, if icsk_backoff and retransmits is non-z=
ero.
If that's because of a retransmission (which was thought to be), then
packets_out is non-zero and tcp_probe_timer will return before sending =
anything.
Correct me, if I'm wrong here.
I'll try to think of a case, where those are non-zero with no packets_o=
ut.

Damian
