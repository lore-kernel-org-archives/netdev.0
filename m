From: alekcejk@googlemail.com
Subject: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 14 Feb 2012 01:49:32 +0200
Message-ID: <2578783.aLeNzacy8Q@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <3490386.xy2kafBK9b@localhost.localdomain> <1329173056.2523.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45331 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754746Ab2BMXtn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 18:49:43 -0500
Received: by bkcjm19 with SMTP id jm19so4988618bkc.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 15:49:40 -0800 (PST)
In-Reply-To: <1329173056.2523.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=9F=D0=BE=D0=BD=D0=B5=D0=B4=D0=B5=D0=BB=D1=8C=D0=BD=D0=B8=D0=BA =
13 =D1=84=D0=B5=D0=B2=D1=80=D0=B0=D0=BB=D1=8F 2012 23:44:16 =D0=B2=D1=8B=
 =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=D0=B8:
> Le lundi 13 f=C3=A9vrier 2012 =C3=A0 21:18 +0100, Eric Dumazet a =C3=A9=
crit :
> I wonder if the other side of your link believes link is in half dupl=
ex
> mode... Could you please check ?

I have no access to other side, the only I can check is ethtool and mii=
-diag (kernel-3.2.3):

ethtool eth0:=20

Settings for eth0:
	Supported ports: [ TP MII ]
	Supported link modes:   10baseT/Half 10baseT/Full=20
	                        100baseT/Half 100baseT/Full=20
	Supported pause frame use: No
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full=20
	                        100baseT/Half 100baseT/Full=20
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Link partner advertised link modes:  10baseT/Half 10baseT/Full=20
	                                     100baseT/Half 100baseT/Full=20
	Link partner advertised pause frame use: No
	Link partner advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: MII
	PHYAD: 32
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: pumbg
	Wake-on: d
	Current message level: 0x00000007 (7)
			       drv probe link
	Link detected: yes

mii-diag eth0:

Basic registers of MII PHY #32:  1100 782d 0000 0000 01e1 41e1 0001 000=
0.
 The autonegotiated capability is 01e0.
The autonegotiated media type is 100baseTx-FD.
 Basic mode control register 0x1100: Auto-negotiation enabled.
 You have link beat, and everything is working OK.
 Your link partner advertised 41e1: 100baseTx-FD 100baseTx 10baseT-FD 1=
0baseT.
   End of basic transceiver information.

But I can say that probably there is really 100Mb/s with Full duplex be=
cause as I wrote in first mail
there is some servers which have almost the same speed with 3.2.3 kerne=
l as with 3.1.10.
They are mostly located geographically close to me (maybe there are oth=
er servers, not close, but I not found such one).
Here example of such server ftp.linux.kiev.ua, download speed 11,1 Mega=
bytes/s with both kernels.

tcpdump for ftp.linux.kiev.ua and kernel 3.2.3:

tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 byte=
s
01:17:26.293216 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [S], seq =
3304772853, win 14600, options [mss 1460,sackOK,TS val 75113 ecr 0,nop,=
wscale 4], length 0
01:17:26.299848 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [S.], seq=
 177870624, ack 3304772854, win 14600, options [mss 1460,nop,nop,sackOK=
,nop,wscale 7], length 0
01:17:26.299871 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
1, win 913, length 0
01:17:26.300022 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [P.], seq=
 1:180, ack 1, win 913, length 179
01:17:26.306714 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], ack =
180, win 123, length 0
01:17:26.306955 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 1:308, ack 180, win 123, length 307
01:17:26.306967 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
308, win 980, length 0
01:17:26.307150 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
308:1768, ack 180, win 123, length 1460
01:17:26.307163 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
1768, win 1162, length 0
01:17:26.307273 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
1768:3228, ack 180, win 123, length 1460
01:17:26.307287 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
3228, win 1345, length 0
01:17:26.307401 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
3228:4688, ack 180, win 123, length 1460
01:17:26.307414 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
4688, win 1527, length 0
01:17:26.307517 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
4688:6148, ack 180, win 123, length 1460
01:17:26.307530 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
6148, win 1710, length 0
01:17:26.307640 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
6148:7608, ack 180, win 123, length 1460
01:17:26.307651 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
7608, win 1892, length 0
01:17:26.307764 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
7608:9068, ack 180, win 123, length 1460
01:17:26.307775 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
9068, win 2075, length 0
01:17:26.307887 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
9068:10528, ack 180, win 123, length 1460
01:17:26.307900 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
10528, win 2257, length 0
01:17:26.313930 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
10528:11988, ack 180, win 123, length 1460
01:17:26.313942 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
11988, win 2440, length 0
01:17:26.314055 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
11988:13448, ack 180, win 123, length 1460
01:17:26.314067 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
13448, win 2622, length 0
01:17:26.314180 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
13448:14908, ack 180, win 123, length 1460
01:17:26.314193 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
14908, win 2805, length 0
01:17:26.314301 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 14908:16368, ack 180, win 123, length 1460
01:17:26.314313 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
16368, win 2987, length 0
01:17:26.314321 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
16368:16692, ack 180, win 123, length 324
01:17:26.314332 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
16692, win 3170, length 0
01:17:26.314456 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
16692:18152, ack 180, win 123, length 1460
01:17:26.314466 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
18152, win 3352, length 0
01:17:26.314579 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
18152:19612, ack 180, win 123, length 1460
01:17:26.314600 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
19612, win 3535, length 0
01:17:26.314703 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
19612:21072, ack 180, win 123, length 1460
01:17:26.314713 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
21072, win 3717, length 0
01:17:26.314824 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
21072:22532, ack 180, win 123, length 1460
01:17:26.314835 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
22532, win 3900, length 0
01:17:26.314948 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
22532:23992, ack 180, win 123, length 1460
01:17:26.314960 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
23992, win 3991, length 0
01:17:26.315071 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
23992:25452, ack 180, win 123, length 1460
01:17:26.315081 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
25452, win 3991, length 0
01:17:26.315194 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 25452:26912, ack 180, win 123, length 1460
01:17:26.315206 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
26912, win 3991, length 0
01:17:26.315317 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
26912:28372, ack 180, win 123, length 1460
01:17:26.315328 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
28372, win 3991, length 0
01:17:26.315440 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
28372:29832, ack 180, win 123, length 1460
01:17:26.315452 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
29832, win 3991, length 0
01:17:26.315563 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
29832:31292, ack 180, win 123, length 1460
01:17:26.315575 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
31292, win 3991, length 0
01:17:26.315687 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 31292:32752, ack 180, win 123, length 1460
01:17:26.315697 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
32752, win 3991, length 0
01:17:26.315809 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
32752:34212, ack 180, win 123, length 1460
01:17:26.315819 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
34212, win 3991, length 0
01:17:26.315931 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
34212:35672, ack 180, win 123, length 1460
01:17:26.315943 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
35672, win 3991, length 0
01:17:26.320846 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
35672:37132, ack 180, win 123, length 1460
01:17:26.320858 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
37132, win 3991, length 0
01:17:26.320969 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
37132:38592, ack 180, win 123, length 1460
01:17:26.320979 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
38592, win 3991, length 0
01:17:26.321097 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
38592:40052, ack 180, win 123, length 1460
01:17:26.321109 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
40052, win 3991, length 0
01:17:26.321215 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
40052:41512, ack 180, win 123, length 1460
01:17:26.321225 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
41512, win 3991, length 0
01:17:26.321337 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
41512:42972, ack 180, win 123, length 1460
01:17:26.321461 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
42972:44432, ack 180, win 123, length 1460
01:17:26.321472 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
44432, win 3991, length 0
01:17:26.321583 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
44432:45892, ack 180, win 123, length 1460
01:17:26.321707 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
45892:47352, ack 180, win 123, length 1460
01:17:26.321718 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
47352, win 3991, length 0
01:17:26.321830 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
47352:48812, ack 180, win 123, length 1460
01:17:26.321953 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
48812:50272, ack 180, win 123, length 1460
01:17:26.321965 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
50272, win 3991, length 0
01:17:26.322076 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 50272:51732, ack 180, win 123, length 1460
01:17:26.322199 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
51732:53192, ack 180, win 123, length 1460
01:17:26.322209 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
53192, win 3991, length 0
01:17:26.322322 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
53192:54652, ack 180, win 123, length 1460
01:17:26.322445 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
54652:56112, ack 180, win 123, length 1460
01:17:26.322455 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
56112, win 3991, length 0
01:17:26.322568 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
56112:57572, ack 180, win 123, length 1460
01:17:26.322691 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
57572:59032, ack 180, win 123, length 1460
01:17:26.322702 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
59032, win 3991, length 0
01:17:26.322815 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
59032:60492, ack 180, win 123, length 1460
01:17:26.322937 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 60492:61952, ack 180, win 123, length 1460
01:17:26.322949 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
61952, win 3991, length 0
01:17:26.323060 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
61952:63412, ack 180, win 123, length 1460
01:17:26.323183 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
63412:64872, ack 180, win 123, length 1460
01:17:26.323195 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
64872, win 3991, length 0
01:17:26.323306 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
64872:66332, ack 180, win 123, length 1460
01:17:26.323430 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
66332:67792, ack 180, win 123, length 1460
01:17:26.323441 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
67792, win 3991, length 0
01:17:26.323552 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
67792:69252, ack 180, win 123, length 1460
01:17:26.323675 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
69252:70712, ack 180, win 123, length 1460
01:17:26.323687 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
70712, win 3991, length 0
01:17:26.323799 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
70712:72172, ack 180, win 123, length 1460
01:17:26.323921 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
72172:73632, ack 180, win 123, length 1460
01:17:26.323933 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
73632, win 3991, length 0
01:17:26.324045 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
73632:75092, ack 180, win 123, length 1460
01:17:26.324168 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
75092:76552, ack 180, win 123, length 1460
01:17:26.324179 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
76552, win 3991, length 0
01:17:26.324291 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
76552:78012, ack 180, win 123, length 1460
01:17:26.324414 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
78012:79472, ack 180, win 123, length 1460
01:17:26.324424 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
79472, win 3991, length 0
01:17:26.324537 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
79472:80932, ack 180, win 123, length 1460
01:17:26.324660 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
80932:82392, ack 180, win 123, length 1460
01:17:26.324672 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
82392, win 3991, length 0
01:17:26.324783 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
82392:83852, ack 180, win 123, length 1460
01:17:26.324905 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
83852:85312, ack 180, win 123, length 1460
01:17:26.324915 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
85312, win 3991, length 0
01:17:26.325029 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
85312:86772, ack 180, win 123, length 1460
01:17:26.325152 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
86772:88232, ack 180, win 123, length 1460
01:17:26.325162 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
88232, win 3991, length 0
01:17:26.327757 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
88232:89692, ack 180, win 123, length 1460
01:17:26.327880 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
89692:91152, ack 180, win 123, length 1460
01:17:26.327891 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
91152, win 3991, length 0
01:17:26.328007 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
91152:92612, ack 180, win 123, length 1460
01:17:26.328126 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 92612:94072, ack 180, win 123, length 1460
01:17:26.328137 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
94072, win 3991, length 0
01:17:26.328250 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
94072:95532, ack 180, win 123, length 1460
01:17:26.328372 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
95532:96992, ack 180, win 123, length 1460
01:17:26.328384 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
96992, win 3991, length 0
01:17:26.328495 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
96992:98452, ack 180, win 123, length 1460
01:17:26.328619 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
98452:99912, ack 180, win 123, length 1460
01:17:26.328629 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
99912, win 3991, length 0
01:17:26.328741 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
99912:101372, ack 180, win 123, length 1460
01:17:26.328865 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
101372:102832, ack 180, win 123, length 1460
01:17:26.328875 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
102832, win 3991, length 0
01:17:26.328987 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
102832:104292, ack 180, win 123, length 1460
01:17:26.329110 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
104292:105752, ack 180, win 123, length 1460
01:17:26.329120 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
105752, win 3991, length 0
01:17:26.329234 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
105752:107212, ack 180, win 123, length 1460
01:17:26.329356 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 107212:108672, ack 180, win 123, length 1460
01:17:26.329368 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
108672, win 3991, length 0
01:17:26.329480 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
108672:110132, ack 180, win 123, length 1460
01:17:26.329603 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
110132:111592, ack 180, win 123, length 1460
01:17:26.329614 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
111592, win 3991, length 0
01:17:26.329726 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
111592:113052, ack 180, win 123, length 1460
01:17:26.329849 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
113052:114512, ack 180, win 123, length 1460
01:17:26.329861 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
114512, win 4188, length 0
01:17:26.329971 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
114512:115972, ack 180, win 123, length 1460
01:17:26.329982 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
115972, win 4370, length 0
01:17:26.330094 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
115972:117432, ack 180, win 123, length 1460
01:17:26.330107 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
117432, win 4553, length 0
01:17:26.330218 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
117432:118892, ack 180, win 123, length 1460
01:17:26.330229 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
118892, win 4735, length 0
01:17:26.330341 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
118892:120352, ack 180, win 123, length 1460
01:17:26.330353 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
120352, win 4918, length 0
01:17:26.330464 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
120352:121812, ack 180, win 123, length 1460
01:17:26.330474 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
121812, win 5100, length 0
01:17:26.330587 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
121812:123272, ack 180, win 123, length 1460
01:17:26.330599 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
123272, win 5283, length 0
01:17:26.330710 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
123272:124732, ack 180, win 123, length 1460
01:17:26.330723 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
124732, win 5465, length 0
01:17:26.330833 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
124732:126192, ack 180, win 123, length 1460
01:17:26.330843 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
126192, win 5648, length 0
01:17:26.330956 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
126192:127652, ack 180, win 123, length 1460
01:17:26.330967 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
127652, win 5830, length 0
01:17:26.331079 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
127652:129112, ack 180, win 123, length 1460
01:17:26.331091 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
129112, win 6013, length 0
01:17:26.331202 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
129112:130572, ack 180, win 123, length 1460
01:17:26.331214 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
130572, win 6195, length 0
01:17:26.331325 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
130572:132032, ack 180, win 123, length 1460
01:17:26.331336 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
132032, win 6378, length 0
01:17:26.331448 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
132032:133492, ack 180, win 123, length 1460
01:17:26.331460 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
133492, win 6560, length 0
01:17:26.331572 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
133492:134952, ack 180, win 123, length 1460
01:17:26.331582 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
134952, win 6743, length 0
01:17:26.331695 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
134952:136412, ack 180, win 123, length 1460
01:17:26.331707 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
136412, win 6925, length 0
01:17:26.331817 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
136412:137872, ack 180, win 123, length 1460
01:17:26.331828 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
137872, win 7108, length 0
01:17:26.331940 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
137872:139332, ack 180, win 123, length 1460
01:17:26.331952 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
139332, win 7290, length 0
01:17:26.332064 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 139332:140792, ack 180, win 123, length 1460
01:17:26.332074 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
140792, win 7473, length 0
01:17:26.332187 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
140792:142252, ack 180, win 123, length 1460
01:17:26.332199 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
142252, win 7655, length 0
01:17:26.332309 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
142252:143712, ack 180, win 123, length 1460
01:17:26.332321 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
143712, win 7838, length 0
01:17:26.332432 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
143712:145172, ack 180, win 123, length 1460
01:17:26.332444 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
145172, win 8020, length 0
01:17:26.332556 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
145172:146632, ack 180, win 123, length 1460
01:17:26.332567 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
146632, win 8203, length 0
01:17:26.332679 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
146632:148092, ack 180, win 123, length 1460
01:17:26.332689 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
148092, win 8385, length 0
01:17:26.332802 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
148092:149552, ack 180, win 123, length 1460
01:17:26.332812 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
149552, win 8568, length 0
01:17:26.332925 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
149552:151012, ack 180, win 123, length 1460
01:17:26.332935 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
151012, win 8750, length 0
01:17:26.334759 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
151012:152472, ack 180, win 123, length 1460
01:17:26.334770 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
152472, win 8933, length 0
01:17:26.334883 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
152472:153932, ack 180, win 123, length 1460
01:17:26.334893 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
153932, win 9115, length 0
01:17:26.335028 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
153932:155392, ack 180, win 123, length 1460
01:17:26.335040 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
155392, win 9298, length 0
01:17:26.335151 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
155392:156852, ack 180, win 123, length 1460
01:17:26.335163 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
156852, win 9480, length 0
01:17:26.335317 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
156852:158312, ack 180, win 123, length 1460
01:17:26.335329 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
158312, win 9490, length 0
01:17:26.335451 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
158312:159772, ack 180, win 123, length 1460
01:17:26.335563 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
159772:161232, ack 180, win 123, length 1460
01:17:26.335575 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
161232, win 9490, length 0
01:17:26.335686 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
161232:162692, ack 180, win 123, length 1460
01:17:26.335808 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
162692:164152, ack 180, win 123, length 1460
01:17:26.335820 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
164152, win 9490, length 0
01:17:26.335935 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
164152:165612, ack 180, win 123, length 1460
01:17:26.336054 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
165612:167072, ack 180, win 123, length 1460
01:17:26.336067 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
167072, win 9490, length 0
01:17:26.336178 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
167072:168532, ack 180, win 123, length 1460
01:17:26.336300 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
168532:169992, ack 180, win 123, length 1460
01:17:26.336312 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
169992, win 9490, length 0
01:17:26.336423 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
169992:171452, ack 180, win 123, length 1460
01:17:26.336546 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
171452:172912, ack 180, win 123, length 1460
01:17:26.336556 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
172912, win 9490, length 0
01:17:26.336677 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
172912:174372, ack 180, win 123, length 1460
01:17:26.336793 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 174372:175832, ack 180, win 123, length 1460
01:17:26.336805 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
175832, win 9490, length 0
01:17:26.336916 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
175832:177292, ack 180, win 123, length 1460
01:17:26.337039 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
177292:178752, ack 180, win 123, length 1460
01:17:26.337049 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
178752, win 9490, length 0
01:17:26.337162 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
178752:180212, ack 180, win 123, length 1460
01:17:26.337285 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
180212:181672, ack 180, win 123, length 1460
01:17:26.337295 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
181672, win 9490, length 0
01:17:26.337407 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
181672:183132, ack 180, win 123, length 1460
01:17:26.337530 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
183132:184592, ack 180, win 123, length 1460
01:17:26.337540 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
184592, win 9490, length 0
01:17:26.337654 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
184592:186052, ack 180, win 123, length 1460
01:17:26.337777 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
186052:187512, ack 180, win 123, length 1460
01:17:26.337787 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
187512, win 9490, length 0
01:17:26.337901 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
187512:188972, ack 180, win 123, length 1460
01:17:26.338023 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
188972:190432, ack 180, win 123, length 1460
01:17:26.338035 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
190432, win 9490, length 0
01:17:26.338146 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
190432:191892, ack 180, win 123, length 1460
01:17:26.338270 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
191892:193352, ack 180, win 123, length 1460
01:17:26.338280 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
193352, win 9490, length 0
01:17:26.338393 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
193352:194812, ack 180, win 123, length 1460
01:17:26.338515 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
194812:196272, ack 180, win 123, length 1460
01:17:26.338526 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
196272, win 9490, length 0
01:17:26.338639 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
196272:197732, ack 180, win 123, length 1460
01:17:26.338761 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
197732:199192, ack 180, win 123, length 1460
01:17:26.338771 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
199192, win 9490, length 0
01:17:26.338885 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
199192:200652, ack 180, win 123, length 1460
01:17:26.339007 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
200652:202112, ack 180, win 123, length 1460
01:17:26.339019 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
202112, win 9490, length 0
01:17:26.339130 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
202112:203572, ack 180, win 123, length 1460
01:17:26.339254 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
203572:205032, ack 180, win 123, length 1460
01:17:26.339266 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
205032, win 9490, length 0
01:17:26.339377 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
205032:206492, ack 180, win 123, length 1460
01:17:26.339500 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 206492:207952, ack 180, win 123, length 1460
01:17:26.339511 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
207952, win 9490, length 0
01:17:26.339623 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
207952:209412, ack 180, win 123, length 1460
01:17:26.339745 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
209412:210872, ack 180, win 123, length 1460
01:17:26.339758 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
210872, win 9490, length 0
01:17:26.339869 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
210872:212332, ack 180, win 123, length 1460
01:17:26.339991 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
212332:213792, ack 180, win 123, length 1460
01:17:26.340003 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
213792, win 9490, length 0
01:17:26.340115 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
213792:215252, ack 180, win 123, length 1460
01:17:26.340238 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
215252:216712, ack 180, win 123, length 1460
01:17:26.340250 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
216712, win 9490, length 0
01:17:26.340361 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
216712:218172, ack 180, win 123, length 1460
01:17:26.340484 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
218172:219632, ack 180, win 123, length 1460
01:17:26.340494 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
219632, win 9490, length 0
01:17:26.340607 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
219632:221092, ack 180, win 123, length 1460
01:17:26.340730 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [P.], seq=
 221092:222552, ack 180, win 123, length 1460
01:17:26.340742 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
222552, win 9490, length 0
01:17:26.340853 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
222552:224012, ack 180, win 123, length 1460
01:17:26.341616 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
224012:225472, ack 180, win 123, length 1460
01:17:26.341626 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
225472, win 9490, length 0
01:17:26.341809 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
225472:226932, ack 180, win 123, length 1460
01:17:26.341933 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
226932:228392, ack 180, win 123, length 1460
01:17:26.341944 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
228392, win 9490, length 0
01:17:26.342058 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
228392:229852, ack 180, win 123, length 1460
01:17:26.342209 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
229852:231312, ack 180, win 123, length 1460
01:17:26.342219 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
231312, win 9490, length 0
01:17:26.342483 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
231312:232772, ack 180, win 123, length 1460
01:17:26.342606 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
232772:234232, ack 180, win 123, length 1460
01:17:26.342616 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
234232, win 9490, length 0
01:17:26.342729 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
234232:235692, ack 180, win 123, length 1460
01:17:26.342856 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
235692:237152, ack 180, win 123, length 1460
01:17:26.342868 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
237152, win 9490, length 0
01:17:26.342975 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
237152:238612, ack 180, win 123, length 1460
01:17:26.343098 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
238612:240072, ack 180, win 123, length 1460
01:17:26.343109 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
240072, win 9490, length 0
01:17:26.343228 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
240072:241532, ack 180, win 123, length 1460
01:17:26.343351 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
241532:242992, ack 180, win 123, length 1460
01:17:26.343361 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
242992, win 9490, length 0
01:17:26.343474 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
242992:244452, ack 180, win 123, length 1460
01:17:26.343597 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
244452:245912, ack 180, win 123, length 1460
01:17:26.343607 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
245912, win 9490, length 0
01:17:26.343720 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
245912:247372, ack 180, win 123, length 1460
01:17:26.343846 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
247372:248832, ack 180, win 123, length 1460
01:17:26.343859 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
248832, win 9490, length 0
01:17:26.343967 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
248832:250292, ack 180, win 123, length 1460
01:17:26.344090 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
250292:251752, ack 180, win 123, length 1460
01:17:26.344102 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
251752, win 9490, length 0
01:17:26.344212 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
251752:253212, ack 180, win 123, length 1460
01:17:26.344339 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
253212:254672, ack 180, win 123, length 1460
01:17:26.344350 IP AA.BB.CC.XY.40055 > 62.149.13.37.80: Flags [.], ack =
254672, win 9490, length 0
01:17:26.344459 IP 62.149.13.37.80 > AA.BB.CC.XY.40055: Flags [.], seq =
254672:256132, ack 180, win 123, length 1460
300 packets captured
300 packets received by filter
0 packets dropped by kernel

tcpdump for ftp.linux.kiev.ua and kernel 3.1.10:

tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 byte=
s
01:44:26.587425 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [S], seq =
965321103, win 14600, options [mss 1460,sackOK,TS val 1251342 ecr 0,nop=
,wscale 4], length 0
01:44:26.594057 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [S.], seq=
 2388283741, ack 965321104, win 14600, options [mss 1460,nop,nop,sackOK=
,nop,wscale 7], length 0
01:44:26.594084 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
1, win 913, length 0
01:44:26.594207 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [P.], seq=
 1:180, ack 1, win 913, length 179
01:44:26.600878 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], ack =
180, win 123, length 0
01:44:26.663816 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 1:308, ack 180, win 123, length 307
01:44:26.663867 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
308, win 980, length 0
01:44:26.718585 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
308:1768, ack 180, win 123, length 1460
01:44:26.718609 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
1768, win 1162, length 0
01:44:26.718711 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
1768:3228, ack 180, win 123, length 1460
01:44:26.718726 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
3228, win 1345, length 0
01:44:26.718838 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
3228:4688, ack 180, win 123, length 1460
01:44:26.718855 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
4688, win 1527, length 0
01:44:26.718955 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
4688:6148, ack 180, win 123, length 1460
01:44:26.718967 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
6148, win 1710, length 0
01:44:26.719078 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
6148:7608, ack 180, win 123, length 1460
01:44:26.719090 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
7608, win 1892, length 0
01:44:26.719200 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
7608:9068, ack 180, win 123, length 1460
01:44:26.719212 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
9068, win 2075, length 0
01:44:26.719324 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
9068:10528, ack 180, win 123, length 1460
01:44:26.719336 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
10528, win 2257, length 0
01:44:26.719446 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
10528:11988, ack 180, win 123, length 1460
01:44:26.719457 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
11988, win 2440, length 0
01:44:26.725451 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
11988:13448, ack 180, win 123, length 1460
01:44:26.725466 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
13448, win 2622, length 0
01:44:26.725574 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
13448:14908, ack 180, win 123, length 1460
01:44:26.725586 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
14908, win 2805, length 0
01:44:26.725696 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
14908:16368, ack 180, win 123, length 1460
01:44:26.725709 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
16368, win 2987, length 0
01:44:26.725820 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 16368:17828, ack 180, win 123, length 1460
01:44:26.725832 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
17828, win 3170, length 0
01:44:26.725942 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
17828:19288, ack 180, win 123, length 1460
01:44:26.725955 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
19288, win 3352, length 0
01:44:26.726065 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
19288:20748, ack 180, win 123, length 1460
01:44:26.726077 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
20748, win 3535, length 0
01:44:26.726190 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
20748:22208, ack 180, win 123, length 1460
01:44:26.726202 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
22208, win 3717, length 0
01:44:26.726313 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
22208:23668, ack 180, win 123, length 1460
01:44:26.726326 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
23668, win 3900, length 0
01:44:26.726435 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
23668:25128, ack 180, win 123, length 1460
01:44:26.726448 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
25128, win 4005, length 0
01:44:26.726557 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
25128:26588, ack 180, win 123, length 1460
01:44:26.726570 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
26588, win 4005, length 0
01:44:26.726681 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 26588:28048, ack 180, win 123, length 1460
01:44:26.726692 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
28048, win 4005, length 0
01:44:26.726804 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
28048:29508, ack 180, win 123, length 1460
01:44:26.726815 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
29508, win 4005, length 0
01:44:26.726927 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
29508:30968, ack 180, win 123, length 1460
01:44:26.726940 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
30968, win 4005, length 0
01:44:26.727049 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
30968:32428, ack 180, win 123, length 1460
01:44:26.727061 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
32428, win 4005, length 0
01:44:26.727173 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 32428:33888, ack 180, win 123, length 1460
01:44:26.727185 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
33888, win 4005, length 0
01:44:26.727296 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 33888:35348, ack 180, win 123, length 1460
01:44:26.727307 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
35348, win 4005, length 0
01:44:26.727419 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
35348:36808, ack 180, win 123, length 1460
01:44:26.727431 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
36808, win 4005, length 0
01:44:26.727543 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
36808:38268, ack 180, win 123, length 1460
01:44:26.727555 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
38268, win 4005, length 0
01:44:26.732282 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
38268:39728, ack 180, win 123, length 1460
01:44:26.732297 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
39728, win 4005, length 0
01:44:26.732405 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
39728:41188, ack 180, win 123, length 1460
01:44:26.732418 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
41188, win 4005, length 0
01:44:26.732528 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
41188:42648, ack 180, win 123, length 1460
01:44:26.732541 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
42648, win 4005, length 0
01:44:26.732651 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
42648:44108, ack 180, win 123, length 1460
01:44:26.732775 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
44108:45568, ack 180, win 123, length 1460
01:44:26.732787 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
45568, win 4005, length 0
01:44:26.732897 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
45568:47028, ack 180, win 123, length 1460
01:44:26.733019 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
47028:48488, ack 180, win 123, length 1460
01:44:26.733031 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
48488, win 4005, length 0
01:44:26.733143 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
48488:49948, ack 180, win 123, length 1460
01:44:26.733266 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
49948:51408, ack 180, win 123, length 1460
01:44:26.733278 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
51408, win 4005, length 0
01:44:26.733389 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
51408:52868, ack 180, win 123, length 1460
01:44:26.733513 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
52868:54328, ack 180, win 123, length 1460
01:44:26.733525 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
54328, win 4005, length 0
01:44:26.733635 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 54328:55788, ack 180, win 123, length 1460
01:44:26.733758 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
55788:57248, ack 180, win 123, length 1460
01:44:26.733770 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
57248, win 4005, length 0
01:44:26.733881 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
57248:58708, ack 180, win 123, length 1460
01:44:26.734006 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
58708:60168, ack 180, win 123, length 1460
01:44:26.734018 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
60168, win 4005, length 0
01:44:26.734128 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
60168:61628, ack 180, win 123, length 1460
01:44:26.734250 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
61628:63088, ack 180, win 123, length 1460
01:44:26.734263 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
63088, win 4005, length 0
01:44:26.734373 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 63088:64548, ack 180, win 123, length 1460
01:44:26.734497 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
64548:66008, ack 180, win 123, length 1460
01:44:26.734509 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
66008, win 4005, length 0
01:44:26.734619 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
66008:67468, ack 180, win 123, length 1460
01:44:26.734742 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
67468:68928, ack 180, win 123, length 1460
01:44:26.734755 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
68928, win 4005, length 0
01:44:26.734866 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
68928:70388, ack 180, win 123, length 1460
01:44:26.734989 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
70388:71848, ack 180, win 123, length 1460
01:44:26.735007 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
71848, win 4005, length 0
01:44:26.735112 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
71848:73308, ack 180, win 123, length 1460
01:44:26.735124 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
73308, win 4188, length 0
01:44:26.735235 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
73308:74768, ack 180, win 123, length 1460
01:44:26.735247 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
74768, win 4370, length 0
01:44:26.735357 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
74768:76228, ack 180, win 123, length 1460
01:44:26.735369 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
76228, win 4553, length 0
01:44:26.735481 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
76228:77688, ack 180, win 123, length 1460
01:44:26.735493 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
77688, win 4735, length 0
01:44:26.735604 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
77688:79148, ack 180, win 123, length 1460
01:44:26.735615 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
79148, win 4918, length 0
01:44:26.735727 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
79148:80608, ack 180, win 123, length 1460
01:44:26.735739 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
80608, win 5100, length 0
01:44:26.735851 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
80608:82068, ack 180, win 123, length 1460
01:44:26.735862 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
82068, win 5283, length 0
01:44:26.735973 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
82068:83528, ack 180, win 123, length 1460
01:44:26.735985 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
83528, win 5465, length 0
01:44:26.736096 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
83528:84988, ack 180, win 123, length 1460
01:44:26.736107 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
84988, win 5648, length 0
01:44:26.736219 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
84988:86448, ack 180, win 123, length 1460
01:44:26.736232 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
86448, win 5830, length 0
01:44:26.736343 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
86448:87908, ack 180, win 123, length 1460
01:44:26.736355 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
87908, win 6013, length 0
01:44:26.736466 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
87908:89368, ack 180, win 123, length 1460
01:44:26.736478 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
89368, win 6195, length 0
01:44:26.736588 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
89368:90828, ack 180, win 123, length 1460
01:44:26.736600 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
90828, win 6378, length 0
01:44:26.739196 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
90828:92288, ack 180, win 123, length 1460
01:44:26.739211 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
92288, win 6560, length 0
01:44:26.739320 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
92288:93748, ack 180, win 123, length 1460
01:44:26.739334 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
93748, win 6570, length 0
01:44:26.739442 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
93748:95208, ack 180, win 123, length 1460
01:44:26.739565 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 95208:96668, ack 180, win 123, length 1460
01:44:26.739577 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
96668, win 6570, length 0
01:44:26.739688 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
96668:98128, ack 180, win 123, length 1460
01:44:26.739811 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
98128:99588, ack 180, win 123, length 1460
01:44:26.739824 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
99588, win 6570, length 0
01:44:26.739934 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
99588:101048, ack 180, win 123, length 1460
01:44:26.740057 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
101048:102508, ack 180, win 123, length 1460
01:44:26.740069 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
102508, win 6570, length 0
01:44:26.740180 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
102508:103968, ack 180, win 123, length 1460
01:44:26.740304 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
103968:105428, ack 180, win 123, length 1460
01:44:26.740316 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
105428, win 6570, length 0
01:44:26.740426 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
105428:106888, ack 180, win 123, length 1460
01:44:26.740550 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
106888:108348, ack 180, win 123, length 1460
01:44:26.740562 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
108348, win 6570, length 0
01:44:26.740672 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 108348:109808, ack 180, win 123, length 1460
01:44:26.741473 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
109808:111268, ack 180, win 123, length 1460
01:44:26.741488 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
111268, win 6570, length 0
01:44:26.741596 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
111268:112728, ack 180, win 123, length 1460
01:44:26.741718 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
112728:114188, ack 180, win 123, length 1460
01:44:26.741730 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
114188, win 6570, length 0
01:44:26.741841 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
114188:115648, ack 180, win 123, length 1460
01:44:26.741964 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
115648:117108, ack 180, win 123, length 1460
01:44:26.741976 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
117108, win 6570, length 0
01:44:26.742087 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
117108:118568, ack 180, win 123, length 1460
01:44:26.742210 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
118568:120028, ack 180, win 123, length 1460
01:44:26.742223 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
120028, win 6570, length 0
01:44:26.742333 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
120028:121488, ack 180, win 123, length 1460
01:44:26.742456 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
121488:122948, ack 180, win 123, length 1460
01:44:26.742469 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
122948, win 6570, length 0
01:44:26.742477 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
122948:123188, ack 180, win 123, length 240
01:44:26.742496 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
123188, win 6570, length 0
01:44:26.742605 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
123188:124648, ack 180, win 123, length 1460
01:44:26.742728 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
124648:126108, ack 180, win 123, length 1460
01:44:26.742739 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
126108, win 6570, length 0
01:44:26.742851 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
126108:127568, ack 180, win 123, length 1460
01:44:26.742974 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
127568:129028, ack 180, win 123, length 1460
01:44:26.742985 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
129028, win 6570, length 0
01:44:26.743097 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
129028:130488, ack 180, win 123, length 1460
01:44:26.743109 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
130488, win 6753, length 0
01:44:26.743221 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
130488:131948, ack 180, win 123, length 1460
01:44:26.743233 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
131948, win 6935, length 0
01:44:26.743343 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
131948:133408, ack 180, win 123, length 1460
01:44:26.743355 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
133408, win 7118, length 0
01:44:26.743466 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
133408:134868, ack 180, win 123, length 1460
01:44:26.743479 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
134868, win 7127, length 0
01:44:26.743589 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
134868:136328, ack 180, win 123, length 1460
01:44:26.743712 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
136328:137788, ack 180, win 123, length 1460
01:44:26.743725 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
137788, win 7127, length 0
01:44:26.743835 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
137788:139248, ack 180, win 123, length 1460
01:44:26.743958 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
139248:140708, ack 180, win 123, length 1460
01:44:26.743970 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
140708, win 7127, length 0
01:44:26.744082 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 140708:142168, ack 180, win 123, length 1460
01:44:26.744205 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
142168:143628, ack 180, win 123, length 1460
01:44:26.744217 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
143628, win 7127, length 0
01:44:26.744327 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
143628:145088, ack 180, win 123, length 1460
01:44:26.744450 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
145088:146548, ack 180, win 123, length 1460
01:44:26.744462 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
146548, win 7127, length 0
01:44:26.744574 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
146548:148008, ack 180, win 123, length 1460
01:44:26.744696 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
148008:149468, ack 180, win 123, length 1460
01:44:26.744709 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
149468, win 7127, length 0
01:44:26.744819 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
149468:150928, ack 180, win 123, length 1460
01:44:26.744943 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
150928:152388, ack 180, win 123, length 1460
01:44:26.744955 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
152388, win 7127, length 0
01:44:26.745066 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
152388:153848, ack 180, win 123, length 1460
01:44:26.745189 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
153848:155308, ack 180, win 123, length 1460
01:44:26.745201 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
155308, win 7127, length 0
01:44:26.745312 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
155308:156768, ack 180, win 123, length 1460
01:44:26.745434 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
156768:158228, ack 180, win 123, length 1460
01:44:26.745447 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
158228, win 7127, length 0
01:44:26.745558 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
158228:159688, ack 180, win 123, length 1460
01:44:26.745681 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
159688:161148, ack 180, win 123, length 1460
01:44:26.745693 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
161148, win 7127, length 0
01:44:26.745804 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
161148:162608, ack 180, win 123, length 1460
01:44:26.746140 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
162608:164068, ack 180, win 123, length 1460
01:44:26.746155 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
164068, win 7127, length 0
01:44:26.746262 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
164068:165528, ack 180, win 123, length 1460
01:44:26.746458 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
165528:166988, ack 180, win 123, length 1460
01:44:26.746470 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
166988, win 7127, length 0
01:44:26.746580 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
166988:168448, ack 180, win 123, length 1460
01:44:26.746903 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
168448:169908, ack 180, win 123, length 1460
01:44:26.746918 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
169908, win 7127, length 0
01:44:26.747026 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
169908:171368, ack 180, win 123, length 1460
01:44:26.747158 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
171368:172828, ack 180, win 123, length 1460
01:44:26.747170 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
172828, win 7127, length 0
01:44:26.747272 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
172828:174288, ack 180, win 123, length 1460
01:44:26.747395 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
174288:175748, ack 180, win 123, length 1460
01:44:26.747407 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
175748, win 7127, length 0
01:44:26.747518 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
175748:177208, ack 180, win 123, length 1460
01:44:26.747641 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
177208:178668, ack 180, win 123, length 1460
01:44:26.747653 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
178668, win 7127, length 0
01:44:26.747764 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
178668:180128, ack 180, win 123, length 1460
01:44:26.747887 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
180128:181588, ack 180, win 123, length 1460
01:44:26.747899 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
181588, win 7127, length 0
01:44:26.748353 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
181588:183048, ack 180, win 123, length 1460
01:44:26.748475 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
183048:184508, ack 180, win 123, length 1460
01:44:26.748490 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
184508, win 7127, length 0
01:44:26.748628 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
184508:185968, ack 180, win 123, length 1460
01:44:26.748751 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
185968:187428, ack 180, win 123, length 1460
01:44:26.748764 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
187428, win 7127, length 0
01:44:26.748903 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
187428:188888, ack 180, win 123, length 1460
01:44:26.749031 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
188888:190348, ack 180, win 123, length 1460
01:44:26.749046 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
190348, win 7127, length 0
01:44:26.749149 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
190348:191808, ack 180, win 123, length 1460
01:44:26.749272 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 191808:193268, ack 180, win 123, length 1460
01:44:26.749286 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
193268, win 7127, length 0
01:44:26.749396 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
193268:194728, ack 180, win 123, length 1460
01:44:26.749517 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
194728:196188, ack 180, win 123, length 1460
01:44:26.749529 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
196188, win 7127, length 0
01:44:26.749641 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
196188:197648, ack 180, win 123, length 1460
01:44:26.749764 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
197648:199108, ack 180, win 123, length 1460
01:44:26.749776 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
199108, win 7127, length 0
01:44:26.749887 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
199108:200568, ack 180, win 123, length 1460
01:44:26.750014 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
200568:202028, ack 180, win 123, length 1460
01:44:26.750027 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
202028, win 7127, length 0
01:44:26.750133 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
202028:203488, ack 180, win 123, length 1460
01:44:26.750255 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
203488:204948, ack 180, win 123, length 1460
01:44:26.750268 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
204948, win 7127, length 0
01:44:26.750379 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
204948:206408, ack 180, win 123, length 1460
01:44:26.750502 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
206408:207868, ack 180, win 123, length 1460
01:44:26.750514 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
207868, win 7127, length 0
01:44:26.750625 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
207868:209328, ack 180, win 123, length 1460
01:44:26.750748 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
209328:210788, ack 180, win 123, length 1460
01:44:26.750761 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
210788, win 7127, length 0
01:44:26.750871 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
210788:212248, ack 180, win 123, length 1460
01:44:26.750999 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
212248:213708, ack 180, win 123, length 1460
01:44:26.751012 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
213708, win 7127, length 0
01:44:26.751117 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
213708:215168, ack 180, win 123, length 1460
01:44:26.751130 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
215168, win 7330, length 0
01:44:26.751240 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
215168:216628, ack 180, win 123, length 1460
01:44:26.751254 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
216628, win 7513, length 0
01:44:26.751363 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
216628:218088, ack 180, win 123, length 1460
01:44:26.751375 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
218088, win 7695, length 0
01:44:26.751486 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
218088:219548, ack 180, win 123, length 1460
01:44:26.751499 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
219548, win 7878, length 0
01:44:26.751609 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
219548:221008, ack 180, win 123, length 1460
01:44:26.751621 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
221008, win 8060, length 0
01:44:26.751733 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
221008:222468, ack 180, win 123, length 1460
01:44:26.751745 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
222468, win 8243, length 0
01:44:26.751855 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
222468:223928, ack 180, win 123, length 1460
01:44:26.751868 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
223928, win 8425, length 0
01:44:26.751978 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
223928:225388, ack 180, win 123, length 1460
01:44:26.751990 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
225388, win 8608, length 0
01:44:26.752102 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
225388:226848, ack 180, win 123, length 1460
01:44:26.752114 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
226848, win 8790, length 0
01:44:26.752225 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
226848:228308, ack 180, win 123, length 1460
01:44:26.752237 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
228308, win 8973, length 0
01:44:26.752348 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
228308:229768, ack 180, win 123, length 1460
01:44:26.752361 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
229768, win 9155, length 0
01:44:26.752470 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
229768:231228, ack 180, win 123, length 1460
01:44:26.752482 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
231228, win 9338, length 0
01:44:26.752593 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
231228:232688, ack 180, win 123, length 1460
01:44:26.752605 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
232688, win 9520, length 0
01:44:26.752717 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
232688:234148, ack 180, win 123, length 1460
01:44:26.752729 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
234148, win 9703, length 0
01:44:26.752839 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [P.], seq=
 234148:235608, ack 180, win 123, length 1460
01:44:26.752852 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
235608, win 9885, length 0
01:44:26.752963 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
235608:237068, ack 180, win 123, length 1460
01:44:26.752975 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
237068, win 10068, length 0
01:44:26.753086 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
237068:238528, ack 180, win 123, length 1460
01:44:26.753099 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
238528, win 10250, length 0
01:44:26.753209 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
238528:239988, ack 180, win 123, length 1460
01:44:26.753220 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
239988, win 10433, length 0
01:44:26.753332 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
239988:241448, ack 180, win 123, length 1460
01:44:26.753343 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
241448, win 10585, length 0
01:44:26.753455 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
241448:242908, ack 180, win 123, length 1460
01:44:26.753577 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
242908:244368, ack 180, win 123, length 1460
01:44:26.753588 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
244368, win 10585, length 0
01:44:26.753780 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
244368:245828, ack 180, win 123, length 1460
01:44:26.753902 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
245828:247288, ack 180, win 123, length 1460
01:44:26.753914 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
247288, win 10585, length 0
01:44:26.754056 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
247288:248748, ack 180, win 123, length 1460
01:44:26.754179 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
248748:250208, ack 180, win 123, length 1460
01:44:26.754191 IP AA.BB.CC.XY.35215 > 62.149.13.37.80: Flags [.], ack =
250208, win 10585, length 0
01:44:26.754302 IP 62.149.13.37.80 > AA.BB.CC.XY.35215: Flags [.], seq =
250208:251668, ack 180, win 123, length 1460
300 packets captured
300 packets received by filter
0 packets dropped by kernel


>=20
> There are some glitches in the tcpdump :
> > > tcpdump -p -n -s 0 -i eth0 -c 300
> > 23:44:07.773262 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.=
], ack 34753, win 3991, options [nop,nop,TS val 4294905354 ecr 37223445=
61], length 0
>=20
> ~50 ms delay here from sender
>=20
> > 23:44:07.830955 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.=
], ack 66609, win 3991, options [nop,nop,TS val 4294905411 ecr 37223445=
85], length 0
>=20
> Here, ~50 ms delay from sender
>=20
> > 23:44:07.888996 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.=
], ack 114393, win 5635, options [nop,nop,TS val 4294905469 ecr 3722344=
609], length 0
>=20
> Here , 50ms delay from sender
>=20
> > 23:44:07.948635 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.=
], seq 195481:196929, ack 1, win 46, options [nop,nop,TS val 3722344634=
 ecr 4294905469], length 1448
>=20
> ~40 ms delay (we lost a frame and send our delack)
>=20

I doubt that something wrong with ftp3.de.freebsd.org server.
It is not only one server which have download speed about 5.5 Megabytes=
/s with 3.2.3 and 11 megabytes/s with 3.1.10.
Downloads from speedtest.tele2.net - 5.3 MB/s with 3.2.3 and about 10 M=
B/s with 3.1.10.

tcpdump for speedtest.tele2.net and kernel 3.2.3:

tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 byte=
s
01:13:33.947801 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 648907525:648908973, ack 3357148586, win 9, options [nop,nop,TS val 33=
90871329 ecr 4294810003], length 1448
01:13:33.947922 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 1448:2896, ack 1, win 9, options [nop,nop,TS val 3390871329 ecr 429481=
0003], length 1448
01:13:33.947929 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 2896, win 21177, options [nop,nop,TS val 4294810064 ecr 3390871329], l=
ength 0
01:13:33.948073 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 2896:4344, ack 1, win 9, options [nop,nop,TS val 3390871329 ecr 429481=
0003], length 1448
01:13:33.948197 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 4344:5792, ack 1, win 9, options [nop,nop,TS val 3390871329 ecr 429481=
0003], length 1448
01:13:33.948203 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 5792, win 21177, options [nop,nop,TS val 4294810064 ecr 3390871329], l=
ength 0
01:13:33.948320 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 5792:7240, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 429481=
0003], length 1448
01:13:33.948443 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 7240:8688, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 429481=
0003], length 1448
01:13:33.948452 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 8688, win 21177, options [nop,nop,TS val 4294810064 ecr 3390871330], l=
ength 0
01:13:33.948593 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 8688:10136, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 42948=
10004], length 1448
01:13:33.948745 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 10136:11584, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810004], length 1448
01:13:33.948754 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 11584, win 21177, options [nop,nop,TS val 4294810065 ecr 3390871330], =
length 0
01:13:33.948932 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 11584:13032, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810004], length 1448
01:13:33.949054 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 13032:14480, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810004], length 1448
01:13:33.949063 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 14480, win 21177, options [nop,nop,TS val 4294810065 ecr 3390871330], =
length 0
01:13:33.949177 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 14480:15928, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810004], length 1448
01:13:33.949300 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 15928:17376, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810004], length 1448
01:13:33.949310 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 17376, win 21177, options [nop,nop,TS val 4294810065 ecr 3390871330], =
length 0
01:13:33.949424 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 17376:18824, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810004], length 1448
01:13:33.949546 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 18824:20272, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810004], length 1448
01:13:33.949555 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 20272, win 21177, options [nop,nop,TS val 4294810065 ecr 3390871330], =
length 0
01:13:33.949670 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 20272:21720, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810005], length 1448
01:13:33.949791 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 21720:23168, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810005], length 1448
01:13:33.949800 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 23168, win 21177, options [nop,nop,TS val 4294810066 ecr 3390871330], =
length 0
01:13:33.949919 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 23168:24616, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810005], length 1448
01:13:33.950037 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 24616:26064, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810005], length 1448
01:13:33.950046 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 26064, win 21177, options [nop,nop,TS val 4294810066 ecr 3390871330], =
length 0
01:13:33.950199 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 26064:27512, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810005], length 1448
01:13:33.950323 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 27512:28960, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810005], length 1448
01:13:33.950331 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 28960, win 21177, options [nop,nop,TS val 4294810066 ecr 3390871330], =
length 0
01:13:33.950445 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 28960:30408, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810005], length 1448
01:13:33.950813 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 33304:34752, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810006], length 1448
01:13:33.950822 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 34752, win 21177, options [nop,nop,TS val 4294810067 ecr 3390871330], =
length 0
01:13:33.950976 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 34752:36200, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810006], length 1448
01:13:33.951099 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 36200:37648, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810006], length 1448
01:13:33.951106 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 37648, win 21177, options [nop,nop,TS val 4294810067 ecr 3390871330], =
length 0
01:13:33.951222 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 37648:39096, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810006], length 1448
01:13:33.951344 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 39096:40544, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810006], length 1448
01:13:33.951356 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 40544, win 21177, options [nop,nop,TS val 4294810067 ecr 3390871330], =
length 0
01:13:33.951505 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 40544:41992, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810007], length 1448
01:13:33.951627 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 41992:43440, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810007], length 1448
01:13:33.951637 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 43440, win 21177, options [nop,nop,TS val 4294810067 ecr 3390871330], =
length 0
01:13:33.951880 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 43440:44888, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810007], length 1448
01:13:33.952003 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 44888:46336, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810007], length 1448
01:13:33.952014 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 46336, win 21177, options [nop,nop,TS val 4294810068 ecr 3390871330], =
length 0
01:13:33.952126 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 46336:47784, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810007], length 1448
01:13:33.952249 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 47784:49232, ack 1, win 9, options [nop,nop,TS val 3390871330 ecr 4294=
810007], length 1448
01:13:33.952258 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 49232, win 21177, options [nop,nop,TS val 4294810068 ecr 3390871330], =
length 0
01:13:33.952372 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 49232:50680, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810007], length 1448
01:13:33.952496 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 50680:52128, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810007], length 1448
01:13:33.952506 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 52128, win 21177, options [nop,nop,TS val 4294810068 ecr 3390871331], =
length 0
01:13:33.952618 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 52128:53576, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810008], length 1448
01:13:33.952742 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 53576:55024, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810008], length 1448
01:13:33.952753 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 55024, win 21177, options [nop,nop,TS val 4294810069 ecr 3390871331], =
length 0
01:13:33.952904 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 55024:56472, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810008], length 1448
01:13:33.953027 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 56472:57920, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810008], length 1448
01:13:33.953037 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 57920, win 21177, options [nop,nop,TS val 4294810069 ecr 3390871331], =
length 0
01:13:33.953282 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 57920:59368, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810008], length 1448
01:13:33.953405 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 59368:60816, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810008], length 1448
01:13:33.953415 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 60816, win 21177, options [nop,nop,TS val 4294810069 ecr 3390871331], =
length 0
01:13:33.953547 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 60816:62264, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810009], length 1448
01:13:33.953670 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 62264:63712, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810009], length 1448
01:13:33.953681 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 63712, win 21177, options [nop,nop,TS val 4294810070 ecr 3390871331], =
length 0
01:13:33.953929 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 63712:65160, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810009], length 1448
01:13:33.954053 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 65160:66608, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810009], length 1448
01:13:33.954063 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 66608, win 21177, options [nop,nop,TS val 4294810070 ecr 3390871331], =
length 0
01:13:33.954378 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 66608:68056, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810009], length 1448
01:13:33.954501 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 68056:69504, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810009], length 1448
01:13:33.954509 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 69504, win 21177, options [nop,nop,TS val 4294810070 ecr 3390871331], =
length 0
01:13:33.954736 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 69504:70952, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810010], length 1448
01:13:33.954859 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 70952:72400, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810010], length 1448
01:13:33.954868 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 72400, win 21177, options [nop,nop,TS val 4294810071 ecr 3390871331], =
length 0
01:13:33.955110 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 72400:73848, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810010], length 1448
01:13:33.955234 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [P.], se=
q 73848:75296, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 429=
4810010], length 1448
01:13:33.955243 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 75296, win 21177, options [nop,nop,TS val 4294810071 ecr 3390871331], =
length 0
01:13:33.955363 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 75296:76744, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810010], length 1448
01:13:33.955487 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 76744:78192, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810010], length 1448
01:13:33.955496 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 78192, win 21177, options [nop,nop,TS val 4294810071 ecr 3390871331], =
length 0
01:13:33.955728 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 78192:79640, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810011], length 1448
01:13:33.955851 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 79640:81088, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810011], length 1448
01:13:33.955860 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 81088, win 21177, options [nop,nop,TS val 4294810072 ecr 3390871331], =
length 0
01:13:33.956016 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 81088:82536, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810011], length 1448
01:13:33.956139 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 82536:83984, ack 1, win 9, options [nop,nop,TS val 3390871331 ecr 4294=
810011], length 1448
01:13:33.956148 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 83984, win 21177, options [nop,nop,TS val 4294810072 ecr 3390871331], =
length 0
01:13:33.956371 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 83984:85432, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 4294=
810011], length 1448
01:13:33.956493 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 85432:86880, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 4294=
810011], length 1448
01:13:33.956503 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 86880, win 21177, options [nop,nop,TS val 4294810072 ecr 3390871332], =
length 0
01:13:33.956616 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 86880:88328, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 4294=
810012], length 1448
01:13:33.956739 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 88328:89776, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 4294=
810012], length 1448
01:13:33.956750 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 89776, win 21177, options [nop,nop,TS val 4294810073 ecr 3390871332], =
length 0
01:13:33.956862 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 89776:91224, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 4294=
810012], length 1448
01:13:33.956984 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 91224:92672, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 4294=
810012], length 1448
01:13:33.956993 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 92672, win 21177, options [nop,nop,TS val 4294810073 ecr 3390871332], =
length 0
01:13:33.957109 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 92672:94120, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 4294=
810012], length 1448
01:13:33.957231 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 94120:95568, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 4294=
810012], length 1448
01:13:33.957239 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 95568, win 21177, options [nop,nop,TS val 4294810073 ecr 3390871332], =
length 0
01:13:33.957353 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 95568:97016, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 4294=
810012], length 1448
01:13:33.957477 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 97016:98464, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 4294=
810012], length 1448
01:13:33.957486 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 98464, win 21177, options [nop,nop,TS val 4294810073 ecr 3390871332], =
length 0
01:13:33.957600 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 98464:99912, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 4294=
810013], length 1448
01:13:33.957723 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 99912:101360, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 429=
4810013], length 1448
01:13:33.957732 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 101360, win 21177, options [nop,nop,TS val 4294810074 ecr 3390871332],=
 length 0
01:13:33.957846 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 101360:102808, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810013], length 1448
01:13:33.957969 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 102808:104256, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810013], length 1448
01:13:33.957979 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 104256, win 21177, options [nop,nop,TS val 4294810074 ecr 3390871332],=
 length 0
01:13:33.958092 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 104256:105704, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810013], length 1448
01:13:33.958215 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 105704:107152, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810013], length 1448
01:13:33.958224 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 107152, win 21177, options [nop,nop,TS val 4294810074 ecr 3390871332],=
 length 0
01:13:33.958366 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 107152:108600, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810013], length 1448
01:13:33.958489 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 108600:110048, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810013], length 1448
01:13:33.958498 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 110048, win 21177, options [nop,nop,TS val 4294810074 ecr 3390871332],=
 length 0
01:13:33.958612 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 110048:111496, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810014], length 1448
01:13:33.958735 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 111496:112944, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810014], length 1448
01:13:33.958745 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 112944, win 21177, options [nop,nop,TS val 4294810075 ecr 3390871332],=
 length 0
01:13:33.958858 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 112944:114392, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810014], length 1448
01:13:33.958981 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 114392:115840, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810014], length 1448
01:13:33.958990 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 115840, win 21177, options [nop,nop,TS val 4294810075 ecr 3390871332],=
 length 0
01:13:33.959111 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 115840:117288, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810014], length 1448
01:13:33.959237 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 117288:118736, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810014], length 1448
01:13:33.959247 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 118736, win 21177, options [nop,nop,TS val 4294810075 ecr 3390871332],=
 length 0
01:13:33.959391 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 118736:120184, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810014], length 1448
01:13:33.959515 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 120184:121632, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810014], length 1448
01:13:33.959524 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 121632, win 21177, options [nop,nop,TS val 4294810075 ecr 3390871332],=
 length 0
01:13:33.959667 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 121632:123080, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810015], length 1448
01:13:33.959790 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 123080:124528, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810015], length 1448
01:13:33.959800 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 124528, win 21177, options [nop,nop,TS val 4294810076 ecr 3390871332],=
 length 0
01:13:33.959912 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 124528:125976, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810015], length 1448
01:13:33.960035 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 125976:127424, ack 1, win 9, options [nop,nop,TS val 3390871332 ecr 42=
94810015], length 1448
01:13:33.960044 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 127424, win 21177, options [nop,nop,TS val 4294810076 ecr 3390871332],=
 length 0
01:13:33.960222 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 127424:128872, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810015], length 1448
01:13:33.960344 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 128872:130320, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810015], length 1448
01:13:33.960353 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 130320, win 21177, options [nop,nop,TS val 4294810076 ecr 3390871333],=
 length 0
01:13:33.960467 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 130320:131768, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810015], length 1448
01:13:33.960592 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 131768:133216, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810015], length 1448
01:13:33.960601 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 133216, win 21177, options [nop,nop,TS val 4294810076 ecr 3390871333],=
 length 0
01:13:33.960714 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 133216:134664, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810016], length 1448
01:13:33.960837 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 134664:136112, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810016], length 1448
01:13:33.960846 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 136112, win 21177, options [nop,nop,TS val 4294810077 ecr 3390871333],=
 length 0
01:13:33.960960 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 136112:137560, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810016], length 1448
01:13:33.961083 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 137560:139008, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810016], length 1448
01:13:33.961092 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 139008, win 21177, options [nop,nop,TS val 4294810077 ecr 3390871333],=
 length 0
01:13:33.961231 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 139008:140456, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810016], length 1448
01:13:33.961354 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 140456:141904, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810016], length 1448
01:13:33.961363 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 141904, win 21177, options [nop,nop,TS val 4294810077 ecr 3390871333],=
 length 0
01:13:33.961477 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 141904:143352, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810016], length 1448
01:13:33.961601 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 143352:144800, ack 1, win 9, options [nop,nop,TS val 3390871333 ecr 42=
94810016], length 1448
01:13:33.961610 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 144800, win 21177, options [nop,nop,TS val 4294810077 ecr 3390871333],=
 length 0
01:13:33.964419 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 170864:172312, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810019], length 1448
01:13:33.964542 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 172312:173760, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810019], length 1448
01:13:33.964551 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 173760, win 21177, options [nop,nop,TS val 4294810080 ecr 3390871334],=
 length 0
01:13:33.964720 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 173760:175208, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810020], length 1448
01:13:33.964843 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 175208:176656, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810020], length 1448
01:13:33.964852 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 176656, win 21177, options [nop,nop,TS val 4294810081 ecr 3390871334],=
 length 0
01:13:33.964998 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 176656:178104, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810020], length 1448
01:13:33.965122 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 178104:179552, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810020], length 1448
01:13:33.965134 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 179552, win 21177, options [nop,nop,TS val 4294810081 ecr 3390871334],=
 length 0
01:13:33.965336 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 179552:181000, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810020], length 1448
01:13:33.965460 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 181000:182448, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810020], length 1448
01:13:33.965471 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 182448, win 21177, options [nop,nop,TS val 4294810081 ecr 3390871334],=
 length 0
01:13:33.965587 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 182448:183896, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810021], length 1448
01:13:33.965710 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 183896:185344, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810021], length 1448
01:13:33.965720 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 185344, win 21177, options [nop,nop,TS val 4294810082 ecr 3390871334],=
 length 0
01:13:33.965836 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 185344:186792, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810021], length 1448
01:13:33.965959 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 186792:188240, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810021], length 1448
01:13:33.965970 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 188240, win 21177, options [nop,nop,TS val 4294810082 ecr 3390871334],=
 length 0
01:13:33.966117 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 188240:189688, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810021], length 1448
01:13:33.966241 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 189688:191136, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810021], length 1448
01:13:33.966252 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 191136, win 21177, options [nop,nop,TS val 4294810082 ecr 3390871334],=
 length 0
01:13:33.966364 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 191136:192584, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810021], length 1448
01:13:33.966487 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 192584:194032, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810021], length 1448
01:13:33.966496 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 194032, win 21177, options [nop,nop,TS val 4294810082 ecr 3390871334],=
 length 0
01:13:33.966610 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 194032:195480, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810022], length 1448
01:13:33.966734 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 195480:196928, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810022], length 1448
01:13:33.966743 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 196928, win 21177, options [nop,nop,TS val 4294810083 ecr 3390871334],=
 length 0
01:13:33.966918 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 196928:198376, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810022], length 1448
01:13:33.967042 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 198376:199824, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810022], length 1448
01:13:33.967052 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 199824, win 21177, options [nop,nop,TS val 4294810083 ecr 3390871334],=
 length 0
01:13:33.967265 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 199824:201272, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810022], length 1448
01:13:33.967386 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 201272:202720, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810022], length 1448
01:13:33.967395 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 202720, win 21177, options [nop,nop,TS val 4294810083 ecr 3390871334],=
 length 0
01:13:33.967509 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 202720:204168, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810022], length 1448
01:13:33.967633 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 204168:205616, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810022], length 1448
01:13:33.967642 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 205616, win 21177, options [nop,nop,TS val 4294810083 ecr 3390871334],=
 length 0
01:13:33.967756 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 205616:207064, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810023], length 1448
01:13:33.967880 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 207064:208512, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810023], length 1448
01:13:33.967890 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 208512, win 21177, options [nop,nop,TS val 4294810084 ecr 3390871334],=
 length 0
01:13:33.968002 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 208512:209960, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810023], length 1448
01:13:33.968125 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 209960:211408, ack 1, win 9, options [nop,nop,TS val 3390871334 ecr 42=
94810023], length 1448
01:13:33.968134 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 211408, win 21177, options [nop,nop,TS val 4294810084 ecr 3390871334],=
 length 0
01:13:33.968293 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 211408:212856, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810023], length 1448
01:13:33.968417 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 212856:214304, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810023], length 1448
01:13:33.968426 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 214304, win 21177, options [nop,nop,TS val 4294810084 ecr 3390871335],=
 length 0
01:13:33.968539 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 214304:215752, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810024], length 1448
01:13:33.968663 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 215752:217200, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810024], length 1448
01:13:33.968673 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 217200, win 21177, options [nop,nop,TS val 4294810085 ecr 3390871335],=
 length 0
01:13:33.969023 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 217200:218648, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810024], length 1448
01:13:33.969147 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 218648:220096, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810024], length 1448
01:13:33.969155 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 220096, win 21177, options [nop,nop,TS val 4294810085 ecr 3390871335],=
 length 0
01:13:33.969268 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 220096:221544, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810024], length 1448
01:13:33.969392 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 221544:222992, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810024], length 1448
01:13:33.969399 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 222992, win 21177, options [nop,nop,TS val 4294810085 ecr 3390871335],=
 length 0
01:13:33.969614 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 222992:224440, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810025], length 1448
01:13:33.969738 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 224440:225888, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810025], length 1448
01:13:33.969746 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 225888, win 21177, options [nop,nop,TS val 4294810086 ecr 3390871335],=
 length 0
01:13:33.969861 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 225888:227336, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810025], length 1448
01:13:33.969983 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 227336:228784, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810025], length 1448
01:13:33.969991 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 228784, win 21177, options [nop,nop,TS val 4294810086 ecr 3390871335],=
 length 0
01:13:33.970107 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 228784:230232, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810025], length 1448
01:13:33.970230 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 230232:231680, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810025], length 1448
01:13:33.970237 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 231680, win 21177, options [nop,nop,TS val 4294810086 ecr 3390871335],=
 length 0
01:13:33.970353 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 231680:233128, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810025], length 1448
01:13:33.970476 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 233128:234576, ack 1, win 9, options [nop,nop,TS val 3390871335 ecr 42=
94810025], length 1448
01:13:33.970483 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 234576, win 21177, options [nop,nop,TS val 4294810086 ecr 3390871335],=
 length 0
01:13:33.980143 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 234576:236024, ack 1, win 9, options [nop,nop,TS val 3390871337 ecr 42=
94810035], length 1448
01:13:33.980266 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 236024:237472, ack 1, win 9, options [nop,nop,TS val 3390871337 ecr 42=
94810035], length 1448
01:13:33.980276 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 237472, win 21177, options [nop,nop,TS val 4294810096 ecr 3390871337],=
 length 0
01:13:33.981444 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 237472:238920, ack 1, win 9, options [nop,nop,TS val 3390871338 ecr 42=
94810036], length 1448
01:13:33.981565 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 238920:240368, ack 1, win 9, options [nop,nop,TS val 3390871338 ecr 42=
94810036], length 1448
01:13:33.981575 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 240368, win 21177, options [nop,nop,TS val 4294810097 ecr 3390871338],=
 length 0
01:13:33.981787 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 240368:241816, ack 1, win 9, options [nop,nop,TS val 3390871338 ecr 42=
94810037], length 1448
01:13:33.981911 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 241816:243264, ack 1, win 9, options [nop,nop,TS val 3390871338 ecr 42=
94810037], length 1448
01:13:33.981920 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 243264, win 21177, options [nop,nop,TS val 4294810098 ecr 3390871338],=
 length 0
01:13:33.997476 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 243264:244712, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810052], length 1448
01:13:33.997599 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 244712:246160, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810052], length 1448
01:13:33.997612 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 246160, win 21177, options [nop,nop,TS val 4294810113 ecr 3390871342],=
 length 0
01:13:33.997755 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 246160:247608, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810053], length 1448
01:13:33.997877 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 247608:249056, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810053], length 1448
01:13:33.997888 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 249056, win 21177, options [nop,nop,TS val 4294810114 ecr 3390871342],=
 length 0
01:13:33.998175 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 249056:250504, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810053], length 1448
01:13:33.998298 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 250504:251952, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810053], length 1448
01:13:33.998308 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 251952, win 21177, options [nop,nop,TS val 4294810114 ecr 3390871342],=
 length 0
01:13:33.998577 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 251952:253400, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810054], length 1448
01:13:33.998702 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 253400:254848, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810054], length 1448
01:13:33.998713 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 254848, win 21177, options [nop,nop,TS val 4294810115 ecr 3390871342],=
 length 0
01:13:33.998864 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 254848:256296, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810054], length 1448
01:13:33.998986 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 256296:257744, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810054], length 1448
01:13:33.998996 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 257744, win 21177, options [nop,nop,TS val 4294810115 ecr 3390871342],=
 length 0
01:13:33.999312 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 257744:259192, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810054], length 1448
01:13:33.999436 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 259192:260640, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810054], length 1448
01:13:33.999446 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 260640, win 21177, options [nop,nop,TS val 4294810115 ecr 3390871342],=
 length 0
01:13:33.999933 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 260640:262088, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810055], length 1448
01:13:34.000056 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 262088:263536, ack 1, win 9, options [nop,nop,TS val 3390871342 ecr 42=
94810055], length 1448
01:13:34.000067 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 263536, win 21177, options [nop,nop,TS val 4294810116 ecr 3390871342],=
 length 0
01:13:34.000393 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 263536:264984, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810055], length 1448
01:13:34.000516 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 264984:266432, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810055], length 1448
01:13:34.000527 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 266432, win 21177, options [nop,nop,TS val 4294810116 ecr 3390871343],=
 length 0
01:13:34.000644 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 266432:267880, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810056], length 1448
01:13:34.000767 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 267880:269328, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810056], length 1448
01:13:34.000778 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 269328, win 21177, options [nop,nop,TS val 4294810117 ecr 3390871343],=
 length 0
01:13:34.001164 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 269328:270776, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810056], length 1448
01:13:34.001287 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 270776:272224, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810056], length 1448
01:13:34.001298 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 272224, win 21177, options [nop,nop,TS val 4294810117 ecr 3390871343],=
 length 0
01:13:34.001411 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 272224:273672, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810056], length 1448
01:13:34.001533 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 273672:275120, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810056], length 1448
01:13:34.001543 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 275120, win 21177, options [nop,nop,TS val 4294810117 ecr 3390871343],=
 length 0
01:13:34.001780 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 275120:276568, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810057], length 1448
01:13:34.001901 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 276568:278016, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810057], length 1448
01:13:34.001912 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 278016, win 21177, options [nop,nop,TS val 4294810118 ecr 3390871343],=
 length 0
01:13:34.002337 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 278016:279464, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810057], length 1448
01:13:34.002460 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 279464:280912, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810057], length 1448
01:13:34.002471 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 280912, win 21177, options [nop,nop,TS val 4294810118 ecr 3390871343],=
 length 0
01:13:34.002636 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 280912:282360, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810058], length 1448
01:13:34.002758 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 282360:283808, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810058], length 1448
01:13:34.002769 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 283808, win 21177, options [nop,nop,TS val 4294810119 ecr 3390871343],=
 length 0
01:13:34.002896 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 283808:285256, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810058], length 1448
01:13:34.003018 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 285256:286704, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810058], length 1448
01:13:34.003029 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 286704, win 21177, options [nop,nop,TS val 4294810119 ecr 3390871343],=
 length 0
01:13:34.003267 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 286704:288152, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810058], length 1448
01:13:34.003391 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 288152:289600, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810058], length 1448
01:13:34.003401 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 289600, win 21177, options [nop,nop,TS val 4294810119 ecr 3390871343],=
 length 0
01:13:34.003636 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 289600:291048, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810059], length 1448
01:13:34.003759 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 291048:292496, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810059], length 1448
01:13:34.003770 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 292496, win 21177, options [nop,nop,TS val 4294810120 ecr 3390871343],=
 length 0
01:13:34.003914 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 292496:293944, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810059], length 1448
01:13:34.004038 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 293944:295392, ack 1, win 9, options [nop,nop,TS val 3390871343 ecr 42=
94810059], length 1448
01:13:34.004049 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 295392, win 21177, options [nop,nop,TS val 4294810120 ecr 3390871343],=
 length 0
01:13:34.004541 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 295392:296840, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810060], length 1448
01:13:34.004664 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 296840:298288, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810060], length 1448
01:13:34.004675 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 298288, win 21177, options [nop,nop,TS val 4294810121 ecr 3390871344],=
 length 0
01:13:34.004787 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 298288:299736, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810060], length 1448
01:13:34.004910 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 299736:301184, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810060], length 1448
01:13:34.004922 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 301184, win 21177, options [nop,nop,TS val 4294810121 ecr 3390871344],=
 length 0
01:13:34.005036 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 301184:302632, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810060], length 1448
01:13:34.005158 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 302632:304080, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810060], length 1448
01:13:34.005169 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 304080, win 21177, options [nop,nop,TS val 4294810121 ecr 3390871344],=
 length 0
01:13:34.005401 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 304080:305528, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810060], length 1448
01:13:34.005525 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 305528:306976, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810060], length 1448
01:13:34.005536 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 306976, win 21177, options [nop,nop,TS val 4294810121 ecr 3390871344],=
 length 0
01:13:34.005681 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 306976:308424, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810061], length 1448
01:13:34.005804 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 308424:309872, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810061], length 1448
01:13:34.005815 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 309872, win 21177, options [nop,nop,TS val 4294810122 ecr 3390871344],=
 length 0
01:13:34.006075 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 309872:311320, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810061], length 1448
01:13:34.006199 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [P.], se=
q 311320:312768, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 4=
294810061], length 1448
01:13:34.006210 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 312768, win 21177, options [nop,nop,TS val 4294810122 ecr 3390871344],=
 length 0
01:13:34.006423 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 312768:314216, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810061], length 1448
01:13:34.006545 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 314216:315664, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810061], length 1448
01:13:34.006556 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 315664, win 21177, options [nop,nop,TS val 4294810122 ecr 3390871344],=
 length 0
01:13:34.006668 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 315664:317112, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810062], length 1448
01:13:34.006790 IP 90.130.66.198.80 > AA.BB.CC.XY.44164: Flags [.], seq=
 317112:318560, ack 1, win 9, options [nop,nop,TS val 3390871344 ecr 42=
94810062], length 1448
01:13:34.006801 IP AA.BB.CC.XY.44164 > 90.130.66.198.80: Flags [.], ack=
 318560, win 21177, options [nop,nop,TS val 4294810123 ecr 3390871344],=
 length 0
300 packets captured
352 packets received by filter
30 packets dropped by kernel


tcpdump for speedtest.tele2.net and kernel 3.1.10:

tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 byte=
s
01:39:20.669849 IP 178.151.71.150.138 > 178.151.71.255.138: NBT UDP PAC=
KET(138)
01:39:23.152632 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [S], seq=
 505609954, win 14600, options [mss 1460,sackOK,TS val 947907 ecr 0,nop=
,wscale 4], length 0
01:39:23.213282 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [S.], se=
q 3677311236, ack 505609955, win 17896, options [mss 8960,sackOK,TS val=
 3391258646 ecr 947907,nop,wscale 11],=20
length 0
01:39:23.213321 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 1, win 913, options [nop,nop,TS val 947968 ecr 3391258646], length 0
01:39:23.213441 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [P.], se=
q 1:125, ack 1, win 913, options [nop,nop,TS val 947968 ecr 3391258646]=
, length 124
01:39:23.274138 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], ack=
 125, win 9, options [nop,nop,TS val 3391258661 ecr 947968], length 0
01:39:23.274537 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 1:1449, ack 125, win 9, options [nop,nop,TS val 3391258661 ecr 947968]=
, length 1448
01:39:23.274558 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 1449, win 1094, options [nop,nop,TS val 948029 ecr 3391258661], length=
 0
01:39:23.274654 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 1449:2897, ack 125, win 9, options [nop,nop,TS val 3391258661 ecr 9479=
68], length 1448
01:39:23.274668 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 2897, win 1275, options [nop,nop,TS val 948029 ecr 3391258661], length=
 0
01:39:23.335420 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 2897:4345, ack 125, win 9, options [nop,nop,TS val 3391258676 ecr 9480=
29], length 1448
01:39:23.335443 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 4345, win 1456, options [nop,nop,TS val 948090 ecr 3391258676], length=
 0
01:39:23.335544 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 4345:5793, ack 125, win 9, options [nop,nop,TS val 3391258676 ecr 9480=
29], length 1448
01:39:23.335558 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 5793, win 1637, options [nop,nop,TS val 948090 ecr 3391258676], length=
 0
01:39:23.335669 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 5793:7241, ack 125, win 9, options [nop,nop,TS val 3391258676 ecr 9480=
29], length 1448
01:39:23.335683 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 7241, win 1818, options [nop,nop,TS val 948090 ecr 3391258676], length=
 0
01:39:23.335788 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 7241:8689, ack 125, win 9, options [nop,nop,TS val 3391258676 ecr 9480=
29], length 1448
01:39:23.335800 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 8689, win 1999, options [nop,nop,TS val 948090 ecr 3391258676], length=
 0
01:39:23.396292 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 8689:10137, ack 125, win 9, options [nop,nop,TS val 3391258691 ecr 948=
090], length 1448
01:39:23.396317 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 10137, win 2180, options [nop,nop,TS val 948151 ecr 3391258691], lengt=
h 0
01:39:23.396414 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 10137:11585, ack 125, win 9, options [nop,nop,TS val 3391258691 ecr 94=
8090], length 1448
01:39:23.396434 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 11585, win 2361, options [nop,nop,TS val 948151 ecr 3391258691], lengt=
h 0
01:39:23.396538 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 11585:13033, ack 125, win 9, options [nop,nop,TS val 3391258691 ecr 94=
8090], length 1448
01:39:23.396550 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 13033, win 2542, options [nop,nop,TS val 948151 ecr 3391258691], lengt=
h 0
01:39:23.396661 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 13033:14481, ack 125, win 9, options [nop,nop,TS val 3391258691 ecr 94=
8090], length 1448
01:39:23.396671 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 14481, win 2723, options [nop,nop,TS val 948151 ecr 3391258691], lengt=
h 0
01:39:23.396784 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [P.], se=
q 14481:15929, ack 125, win 9, options [nop,nop,TS val 3391258691 ecr 9=
48090], length 1448
01:39:23.396796 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 15929, win 2904, options [nop,nop,TS val 948151 ecr 3391258691], lengt=
h 0
01:39:23.396907 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 15929:17377, ack 125, win 9, options [nop,nop,TS val 3391258691 ecr 94=
8090], length 1448
01:39:23.396917 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 17377, win 3085, options [nop,nop,TS val 948151 ecr 3391258691], lengt=
h 0
01:39:23.397029 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 17377:18825, ack 125, win 9, options [nop,nop,TS val 3391258691 ecr 94=
8090], length 1448
01:39:23.397041 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 18825, win 3266, options [nop,nop,TS val 948152 ecr 3391258691], lengt=
h 0
01:39:23.397153 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 18825:20273, ack 125, win 9, options [nop,nop,TS val 3391258691 ecr 94=
8090], length 1448
01:39:23.397163 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 20273, win 3447, options [nop,nop,TS val 948152 ecr 3391258691], lengt=
h 0
01:39:23.457152 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 20273:21721, ack 125, win 9, options [nop,nop,TS val 3391258706 ecr 94=
8151], length 1448
01:39:23.457171 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 21721, win 3628, options [nop,nop,TS val 948212 ecr 3391258706], lengt=
h 0
01:39:23.457276 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 21721:23169, ack 125, win 9, options [nop,nop,TS val 3391258706 ecr 94=
8151], length 1448
01:39:23.457293 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 23169, win 3809, options [nop,nop,TS val 948212 ecr 3391258706], lengt=
h 0
01:39:23.457403 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [P.], se=
q 23169:24617, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 9=
48151], length 1448
01:39:23.457415 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 24617, win 3990, options [nop,nop,TS val 948212 ecr 3391258707], lengt=
h 0
01:39:23.457521 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 24617:26065, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8151], length 1448
01:39:23.457533 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 26065, win 4006, options [nop,nop,TS val 948212 ecr 3391258707], lengt=
h 0
01:39:23.457645 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 26065:27513, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8151], length 1448
01:39:23.457656 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 27513, win 4006, options [nop,nop,TS val 948212 ecr 3391258707], lengt=
h 0
01:39:23.457768 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 27513:28961, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8151], length 1448
01:39:23.457779 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 28961, win 4006, options [nop,nop,TS val 948212 ecr 3391258707], lengt=
h 0
01:39:23.457890 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 28961:30409, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8151], length 1448
01:39:23.457901 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 30409, win 4006, options [nop,nop,TS val 948212 ecr 3391258707], lengt=
h 0
01:39:23.458014 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 30409:31857, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8151], length 1448
01:39:23.458026 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 31857, win 4006, options [nop,nop,TS val 948213 ecr 3391258707], lengt=
h 0
01:39:23.458136 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 31857:33305, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8151], length 1448
01:39:23.458260 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 33305:34753, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8151], length 1448
01:39:23.458271 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 34753, win 4006, options [nop,nop,TS val 948213 ecr 3391258707], lengt=
h 0
01:39:23.458383 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 34753:36201, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8151], length 1448
01:39:23.458506 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 36201:37649, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8151], length 1448
01:39:23.458516 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 37649, win 4006, options [nop,nop,TS val 948213 ecr 3391258707], lengt=
h 0
01:39:23.458629 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 37649:39097, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8152], length 1448
01:39:23.458752 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [P.], se=
q 39097:40545, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 9=
48152], length 1448
01:39:23.458762 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 40545, win 4006, options [nop,nop,TS val 948213 ecr 3391258707], lengt=
h 0
01:39:23.458875 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 40545:41993, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8152], length 1448
01:39:23.458999 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 41993:43441, ack 125, win 9, options [nop,nop,TS val 3391258707 ecr 94=
8152], length 1448
01:39:23.459010 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 43441, win 4006, options [nop,nop,TS val 948214 ecr 3391258707], lengt=
h 0
01:39:23.517996 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 43441:44889, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.518118 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 44889:46337, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.518137 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 46337, win 4187, options [nop,nop,TS val 948273 ecr 3391258722], lengt=
h 0
01:39:23.518266 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [P.], se=
q 46337:47785, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 9=
48212], length 1448
01:39:23.518280 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 47785, win 4326, options [nop,nop,TS val 948273 ecr 3391258722], lengt=
h 0
01:39:23.518365 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 47785:49233, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.518487 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 49233:50681, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.518502 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 50681, win 4326, options [nop,nop,TS val 948273 ecr 3391258722], lengt=
h 0
01:39:23.518610 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 50681:52129, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.518733 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 52129:53577, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.518746 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 53577, win 4326, options [nop,nop,TS val 948273 ecr 3391258722], lengt=
h 0
01:39:23.518857 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 53577:55025, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.518979 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 55025:56473, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.518991 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 56473, win 4326, options [nop,nop,TS val 948273 ecr 3391258722], lengt=
h 0
01:39:23.519102 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 56473:57921, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.519226 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 57921:59369, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.519238 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 59369, win 4326, options [nop,nop,TS val 948274 ecr 3391258722], lengt=
h 0
01:39:23.519349 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 59369:60817, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.519472 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 60817:62265, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.519484 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 62265, win 4326, options [nop,nop,TS val 948274 ecr 3391258722], lengt=
h 0
01:39:23.519594 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 62265:63713, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8212], length 1448
01:39:23.519717 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [P.], se=
q 63713:65161, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 9=
48213], length 1448
01:39:23.519728 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 65161, win 4326, options [nop,nop,TS val 948274 ecr 3391258722], lengt=
h 0
01:39:23.519841 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 65161:66609, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8213], length 1448
01:39:23.519963 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 66609:68057, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8213], length 1448
01:39:23.519975 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 68057, win 4326, options [nop,nop,TS val 948274 ecr 3391258722], lengt=
h 0
01:39:23.520087 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 68057:69505, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8213], length 1448
01:39:23.520209 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 69505:70953, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8213], length 1448
01:39:23.520221 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 70953, win 4326, options [nop,nop,TS val 948275 ecr 3391258722], lengt=
h 0
01:39:23.520332 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 70953:72401, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8213], length 1448
01:39:23.520456 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 72401:73849, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8213], length 1448
01:39:23.520467 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 73849, win 4326, options [nop,nop,TS val 948275 ecr 3391258722], lengt=
h 0
01:39:23.520579 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 73849:75297, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8213], length 1448
01:39:23.520702 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 75297:76745, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8213], length 1448
01:39:23.520714 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 76745, win 4326, options [nop,nop,TS val 948275 ecr 3391258722], lengt=
h 0
01:39:23.520825 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 76745:78193, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8213], length 1448
01:39:23.520947 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 78193:79641, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8213], length 1448
01:39:23.520959 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 79641, win 4326, options [nop,nop,TS val 948275 ecr 3391258722], lengt=
h 0
01:39:23.521070 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 79641:81089, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8214], length 1448
01:39:23.521194 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 81089:82537, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8214], length 1448
01:39:23.521206 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 82537, win 4326, options [nop,nop,TS val 948276 ecr 3391258722], lengt=
h 0
01:39:23.521317 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 82537:83985, ack 125, win 9, options [nop,nop,TS val 3391258722 ecr 94=
8214], length 1448
01:39:23.561066 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 83985, win 4344, options [nop,nop,TS val 948316 ecr 3391258722], lengt=
h 0
01:39:23.579012 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 83985:85433, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr 94=
8273], length 1448
01:39:23.579120 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 85433:86881, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr 94=
8273], length 1448
01:39:23.579205 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 86881, win 4344, options [nop,nop,TS val 948334 ecr 3391258737], lengt=
h 0
01:39:23.579244 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 86881:88329, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr 94=
8273], length 1448
01:39:23.579365 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 88329:89777, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr 94=
8273], length 1448
01:39:23.579412 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 89777, win 4344, options [nop,nop,TS val 948334 ecr 3391258737], lengt=
h 0
01:39:23.579488 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 89777:91225, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr 94=
8273], length 1448
01:39:23.579611 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 91225:92673, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr 94=
8273], length 1448
01:39:23.579653 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 92673, win 4344, options [nop,nop,TS val 948334 ecr 3391258737], lengt=
h 0
01:39:23.579734 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 92673:94121, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr 94=
8273], length 1448
01:39:23.579856 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 94121:95569, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr 94=
8273], length 1448
01:39:23.579900 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 95569, win 4344, options [nop,nop,TS val 948334 ecr 3391258737], lengt=
h 0
01:39:23.579979 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 95569:97017, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr 94=
8273], length 1448
01:39:23.580103 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [P.], se=
q 97017:98465, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr 9=
48273], length 1448
01:39:23.580149 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 98465, win 4344, options [nop,nop,TS val 948335 ecr 3391258737], lengt=
h 0
01:39:23.580226 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 98465:99913, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr 94=
8273], length 1448
01:39:23.580349 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [P.], se=
q 99913:101361, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948273], length 1448
01:39:23.580393 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 101361, win 4344, options [nop,nop,TS val 948335 ecr 3391258737], leng=
th 0
01:39:23.580472 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 101361:102809, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948273], length 1448
01:39:23.580596 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 102809:104257, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948273], length 1448
01:39:23.580639 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 104257, win 4344, options [nop,nop,TS val 948335 ecr 3391258737], leng=
th 0
01:39:23.580717 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 104257:105705, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.580841 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 105705:107153, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.580897 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 107153, win 4344, options [nop,nop,TS val 948335 ecr 3391258737], leng=
th 0
01:39:23.580970 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 107153:108601, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.581107 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 108601:110049, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.581119 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 110049, win 4525, options [nop,nop,TS val 948336 ecr 3391258737], leng=
th 0
01:39:23.581230 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 110049:111497, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.581240 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 111497, win 4706, options [nop,nop,TS val 948336 ecr 3391258737], leng=
th 0
01:39:23.581352 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 111497:112945, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.581362 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 112945, win 4887, options [nop,nop,TS val 948336 ecr 3391258737], leng=
th 0
01:39:23.581475 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 112945:114393, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.581487 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 114393, win 5068, options [nop,nop,TS val 948336 ecr 3391258737], leng=
th 0
01:39:23.581599 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 114393:115841, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.581609 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 115841, win 5249, options [nop,nop,TS val 948336 ecr 3391258737], leng=
th 0
01:39:23.581721 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 115841:117289, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.581732 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 117289, win 5430, options [nop,nop,TS val 948336 ecr 3391258737], leng=
th 0
01:39:23.581844 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 117289:118737, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.581855 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 118737, win 5611, options [nop,nop,TS val 948336 ecr 3391258737], leng=
th 0
01:39:23.581968 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 118737:120185, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.581977 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 120185, win 5792, options [nop,nop,TS val 948336 ecr 3391258737], leng=
th 0
01:39:23.582091 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 120185:121633, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948274], length 1448
01:39:23.582102 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 121633, win 5973, options [nop,nop,TS val 948337 ecr 3391258737], leng=
th 0
01:39:23.582214 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 121633:123081, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948275], length 1448
01:39:23.582224 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 123081, win 6154, options [nop,nop,TS val 948337 ecr 3391258737], leng=
th 0
01:39:23.582337 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 123081:124529, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948275], length 1448
01:39:23.582348 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 124529, win 6335, options [nop,nop,TS val 948337 ecr 3391258737], leng=
th 0
01:39:23.582459 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 124529:125977, ack 125, win 9, options [nop,nop,TS val 3391258737 ecr =
948275], length 1448
01:39:23.582470 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 125977, win 6516, options [nop,nop,TS val 948337 ecr 3391258737], leng=
th 0
01:39:23.582584 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 125977:127425, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr =
948275], length 1448
01:39:23.582596 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 127425, win 6697, options [nop,nop,TS val 948337 ecr 3391258738], leng=
th 0
01:39:23.582707 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 127425:128873, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr =
948275], length 1448
01:39:23.582718 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 128873, win 6878, options [nop,nop,TS val 948337 ecr 3391258738], leng=
th 0
01:39:23.582829 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 128873:130321, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr =
948275], length 1448
01:39:23.582840 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 130321, win 7059, options [nop,nop,TS val 948337 ecr 3391258738], leng=
th 0
01:39:23.582953 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 130321:131769, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr =
948275], length 1448
01:39:23.582964 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 131769, win 7240, options [nop,nop,TS val 948337 ecr 3391258738], leng=
th 0
01:39:23.583075 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 131769:133217, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr =
948275], length 1448
01:39:23.583086 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 133217, win 7421, options [nop,nop,TS val 948338 ecr 3391258738], leng=
th 0
01:39:23.583199 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 133217:134665, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr =
948275], length 1448
01:39:23.583211 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 134665, win 7602, options [nop,nop,TS val 948338 ecr 3391258738], leng=
th 0
01:39:23.583321 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [P.], se=
q 134665:136113, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr=
 948275], length 1448
01:39:23.583333 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 136113, win 7783, options [nop,nop,TS val 948338 ecr 3391258738], leng=
th 0
01:39:23.583444 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 136113:137561, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr =
948275], length 1448
01:39:23.583455 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 137561, win 7964, options [nop,nop,TS val 948338 ecr 3391258738], leng=
th 0
01:39:23.583567 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 137561:139009, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr =
948275], length 1448
01:39:23.583690 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 139009:140457, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr =
948276], length 1448
01:39:23.583701 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 140457, win 7964, options [nop,nop,TS val 948338 ecr 3391258738], leng=
th 0
01:39:23.583813 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 140457:141905, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr =
948276], length 1448
01:39:23.583937 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 141905:143353, ack 125, win 9, options [nop,nop,TS val 3391258738 ecr =
948276], length 1448
01:39:23.583948 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 143353, win 7964, options [nop,nop,TS val 948338 ecr 3391258738], leng=
th 0
01:39:23.621906 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 143353:144801, ack 125, win 9, options [nop,nop,TS val 3391258748 ecr =
948316], length 1448
01:39:23.622028 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 144801:146249, ack 125, win 9, options [nop,nop,TS val 3391258748 ecr =
948316], length 1448
01:39:23.622045 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 146249, win 7964, options [nop,nop,TS val 948377 ecr 3391258748], leng=
th 0
01:39:23.640106 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 146249:147697, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948334], length 1448
01:39:23.640229 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 147697:149145, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948334], length 1448
01:39:23.640244 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 149145, win 7964, options [nop,nop,TS val 948395 ecr 3391258752], leng=
th 0
01:39:23.640351 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 149145:150593, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948334], length 1448
01:39:23.640475 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [P.], se=
q 150593:152041, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr=
 948334], length 1448
01:39:23.640488 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 152041, win 7964, options [nop,nop,TS val 948395 ecr 3391258752], leng=
th 0
01:39:23.640598 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 152041:153489, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948334], length 1448
01:39:23.640721 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 153489:154937, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948334], length 1448
01:39:23.640734 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 154937, win 7964, options [nop,nop,TS val 948395 ecr 3391258752], leng=
th 0
01:39:23.640843 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 154937:156385, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948334], length 1448
01:39:23.640966 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 156385:157833, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948334], length 1448
01:39:23.640978 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 157833, win 7964, options [nop,nop,TS val 948395 ecr 3391258752], leng=
th 0
01:39:23.641089 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 157833:159281, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948334], length 1448
01:39:23.641213 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 159281:160729, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948334], length 1448
01:39:23.641226 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 160729, win 7964, options [nop,nop,TS val 948396 ecr 3391258752], leng=
th 0
01:39:23.641335 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 160729:162177, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948334], length 1448
01:39:23.641459 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 162177:163625, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948334], length 1448
01:39:23.641471 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 163625, win 7964, options [nop,nop,TS val 948396 ecr 3391258752], leng=
th 0
01:39:23.641582 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 163625:165073, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948335], length 1448
01:39:23.641705 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 165073:166521, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948335], length 1448
01:39:23.641717 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 166521, win 7964, options [nop,nop,TS val 948396 ecr 3391258752], leng=
th 0
01:39:23.641828 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 166521:167969, ack 125, win 9, options [nop,nop,TS val 3391258752 ecr =
948335], length 1448
01:39:23.641951 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 167969:169417, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948335], length 1448
01:39:23.641963 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 169417, win 7964, options [nop,nop,TS val 948396 ecr 3391258752], leng=
th 0
01:39:23.642074 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 169417:170865, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948335], length 1448
01:39:23.642197 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 170865:172313, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948335], length 1448
01:39:23.642209 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 172313, win 7964, options [nop,nop,TS val 948397 ecr 3391258753], leng=
th 0
01:39:23.642321 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 172313:173761, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948335], length 1448
01:39:23.642443 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 173761:175209, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948335], length 1448
01:39:23.642455 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 175209, win 7964, options [nop,nop,TS val 948397 ecr 3391258753], leng=
th 0
01:39:23.642566 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 175209:176657, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948335], length 1448
01:39:23.642689 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 176657:178105, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.642702 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 178105, win 7964, options [nop,nop,TS val 948397 ecr 3391258753], leng=
th 0
01:39:23.642812 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 178105:179553, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.642825 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 179553, win 8145, options [nop,nop,TS val 948397 ecr 3391258753], leng=
th 0
01:39:23.642935 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 179553:181001, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.642948 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 181001, win 8326, options [nop,nop,TS val 948397 ecr 3391258753], leng=
th 0
01:39:23.643058 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 181001:182449, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.643071 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 182449, win 8507, options [nop,nop,TS val 948398 ecr 3391258753], leng=
th 0
01:39:23.643181 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 182449:183897, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.643193 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 183897, win 8688, options [nop,nop,TS val 948398 ecr 3391258753], leng=
th 0
01:39:23.643305 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 183897:185345, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.643427 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 185345:186793, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.643439 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 186793, win 8688, options [nop,nop,TS val 948398 ecr 3391258753], leng=
th 0
01:39:23.643550 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [P.], se=
q 186793:188241, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr=
 948336], length 1448
01:39:23.643674 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 188241:189689, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.643686 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 189689, win 8688, options [nop,nop,TS val 948398 ecr 3391258753], leng=
th 0
01:39:23.643796 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 189689:191137, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.643920 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 191137:192585, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.643931 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 192585, win 8688, options [nop,nop,TS val 948398 ecr 3391258753], leng=
th 0
01:39:23.644042 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 192585:194033, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.644166 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 194033:195481, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.644177 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 195481, win 8688, options [nop,nop,TS val 948399 ecr 3391258753], leng=
th 0
01:39:23.644289 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 195481:196929, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.644411 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 196929:198377, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.644423 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 198377, win 8688, options [nop,nop,TS val 948399 ecr 3391258753], leng=
th 0
01:39:23.644534 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 198377:199825, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.644658 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 199825:201273, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.644669 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 201273, win 8688, options [nop,nop,TS val 948399 ecr 3391258753], leng=
th 0
01:39:23.644781 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 201273:202721, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.644904 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 202721:204169, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.644916 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 204169, win 8688, options [nop,nop,TS val 948399 ecr 3391258753], leng=
th 0
01:39:23.645027 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 204169:205617, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948336], length 1448
01:39:23.645150 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 205617:207065, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.645161 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 207065, win 8688, options [nop,nop,TS val 948400 ecr 3391258753], leng=
th 0
01:39:23.645273 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 207065:208513, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.645396 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 208513:209961, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.645408 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 209961, win 8688, options [nop,nop,TS val 948400 ecr 3391258753], leng=
th 0
01:39:23.645519 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 209961:211409, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.645643 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 211409:212857, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.645654 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 212857, win 8688, options [nop,nop,TS val 948400 ecr 3391258753], leng=
th 0
01:39:23.645765 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 212857:214305, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.645889 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 214305:215753, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.645901 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 215753, win 8688, options [nop,nop,TS val 948400 ecr 3391258753], leng=
th 0
01:39:23.646011 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 215753:217201, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.646134 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 217201:218649, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.646146 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 218649, win 8688, options [nop,nop,TS val 948401 ecr 3391258753], leng=
th 0
01:39:23.646257 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [P.], se=
q 218649:220097, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr=
 948337], length 1448
01:39:23.646381 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 220097:221545, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.646392 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 221545, win 8688, options [nop,nop,TS val 948401 ecr 3391258753], leng=
th 0
01:39:23.646503 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 221545:222993, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.646629 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 222993:224441, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.646641 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 224441, win 8688, options [nop,nop,TS val 948401 ecr 3391258753], leng=
th 0
01:39:23.646749 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 224441:225889, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.646872 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 225889:227337, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.646884 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 227337, win 8688, options [nop,nop,TS val 948401 ecr 3391258753], leng=
th 0
01:39:23.647001 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 227337:228785, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948337], length 1448
01:39:23.647118 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 228785:230233, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.647130 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 230233, win 8688, options [nop,nop,TS val 948402 ecr 3391258753], leng=
th 0
01:39:23.647242 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 230233:231681, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.647365 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 231681:233129, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.647376 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 233129, win 8688, options [nop,nop,TS val 948402 ecr 3391258753], leng=
th 0
01:39:23.647488 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 233129:234577, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.647611 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 234577:236025, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.647624 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 236025, win 8688, options [nop,nop,TS val 948402 ecr 3391258753], leng=
th 0
01:39:23.647733 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 236025:237473, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.647856 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 237473:238921, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.647868 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 238921, win 8688, options [nop,nop,TS val 948402 ecr 3391258753], leng=
th 0
01:39:23.647980 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 238921:240369, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.648103 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 240369:241817, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.648115 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 241817, win 8688, options [nop,nop,TS val 948403 ecr 3391258753], leng=
th 0
01:39:23.648226 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 241817:243265, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.648349 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 243265:244713, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.648360 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 244713, win 8688, options [nop,nop,TS val 948403 ecr 3391258753], leng=
th 0
01:39:23.648472 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 244713:246161, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.648595 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 246161:247609, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.648607 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 247609, win 8688, options [nop,nop,TS val 948403 ecr 3391258753], leng=
th 0
01:39:23.648719 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 247609:249057, ack 125, win 9, options [nop,nop,TS val 3391258753 ecr =
948338], length 1448
01:39:23.682907 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 249057:250505, ack 125, win 9, options [nop,nop,TS val 3391258763 ecr =
948377], length 1448
01:39:23.682930 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 250505, win 8688, options [nop,nop,TS val 948437 ecr 3391258753], leng=
th 0
01:39:23.683030 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 250505:251953, ack 125, win 9, options [nop,nop,TS val 3391258763 ecr =
948377], length 1448
01:39:23.683152 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 251953:253401, ack 125, win 9, options [nop,nop,TS val 3391258763 ecr =
948377], length 1448
01:39:23.683163 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 253401, win 8688, options [nop,nop,TS val 948438 ecr 3391258763], leng=
th 0
01:39:23.701070 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 253401:254849, ack 125, win 9, options [nop,nop,TS val 3391258767 ecr =
948395], length 1448
01:39:23.701193 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 254849:256297, ack 125, win 9, options [nop,nop,TS val 3391258767 ecr =
948395], length 1448
01:39:23.701206 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 256297, win 8688, options [nop,nop,TS val 948456 ecr 3391258767], leng=
th 0
01:39:23.701316 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 256297:257745, ack 125, win 9, options [nop,nop,TS val 3391258767 ecr =
948395], length 1448
01:39:23.701438 IP 90.130.66.198.80 > AA.BB.CC.XY.36447: Flags [.], seq=
 257745:259193, ack 125, win 9, options [nop,nop,TS val 3391258768 ecr =
948395], length 1448
01:39:23.701450 IP AA.BB.CC.XY.36447 > 90.130.66.198.80: Flags [.], ack=
 259193, win 8688, options [nop,nop,TS val 948456 ecr 3391258767], leng=
th 0
300 packets captured
300 packets received by filter
0 packets dropped by kernel
