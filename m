From: alekcejk@googlemail.com
Subject: Re: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 05:44:34 -0800 (PST)
Message-ID: <4249109.nLB9JCi9YF@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <5781419.24ZaHfTAxC@localhost.localdomain> <1329280993.2555.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61385 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758333Ab2BONog convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 08:44:36 -0500
Received: by mail-bk0-f46.google.com with SMTP id jm19so927135bkc.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 05:44:35 -0800 (PST)
In-Reply-To: <1329280993.2555.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=F7 =D3=CF=CF=C2=DD=C5=CE=C9=C9 =CF=D4 =F3=D2=C5=C4=C1 15 =C6=C5=D7=D2=C1=
=CC=D1 2012 05:43:13 =D7=D9 =CE=C1=D0=C9=D3=C1=CC=C9:
> OK thanks, nothing seems wrong on receiver side.
>=20
> Could you try to force ECN enabled flows and send tcpdump, to check i=
f
> we receive retransmits ?
>=20
> echo 1 >/proc/sys/net/ipv4/tcp_ecn
2 was there before I did it.


> And check tcp can engage ECN : tcpdump SYN/SYNACK should look like:
>=20
> 05:41:17.943538 IP 192.168.1.97.45986 > 68.232.35.119.80: Flags [SEW]=
,
> seq 2109565072, win 14600, options [mss 1460,sackOK,TS val 8295492 ec=
r
> 0,nop,wscale 6], length 0
>=20
> 05:41:17.980619 IP 68.232.35.119.80 > 192.168.1.97.45986: Flags [S.E]=
,
> seq 2519424885, ack 2109565073, win 14600, options [mss
> 1452,nop,nop,sackOK,nop,wscale 6], length 0

tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 byte=
s
15:21:20.799077 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [SEW], se=
q 1233000896, win 14600, options [mss 1460,sackOK,TS val 764819 ecr 0,n=
op,wscale 4], length 0
15:21:20.853575 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [S.], seq=
 3046667726, ack 1233000897, win 5792, options [mss 1460,sackOK,TS val =
3782118833 ecr 764819,nop,wscale 7], length=20
0
15:21:20.853597 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [.], ack =
1, win 913, options [nop,nop,TS val 764874 ecr 3782118833], length 0
15:21:20.912282 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [P.], seq=
 1:68, ack 1, win 46, options [nop,nop,TS val 3782118858 ecr 764874], l=
ength 67
15:21:20.912299 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [.], ack =
68, win 913, options [nop,nop,TS val 764932 ecr 3782118858], length 0
15:21:20.912357 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [P.], seq=
 1:17, ack 68, win 913, options [nop,nop,TS val 764933 ecr 3782118858],=
 length 16
15:21:20.966821 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [.], ack =
17, win 46, options [nop,nop,TS val 3782118881 ecr 764933], length 0
15:21:20.971689 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [P.], seq=
 68:143, ack 17, win 46, options [nop,nop,TS val 3782118883 ecr 764933]=
, length 75
15:21:20.971725 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [P.], seq=
 17:30, ack 143, win 913, options [nop,nop,TS val 764992 ecr 3782118883=
], length 13
15:21:21.027716 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [P.], seq=
 143:166, ack 30, win 46, options [nop,nop,TS val 3782118906 ecr 764992=
], length 23
15:21:21.067472 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [.], ack =
166, win 913, options [nop,nop,TS val 765088 ecr 3782118906], length 0
15:21:21.121931 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [P.], seq=
 166:393, ack 30, win 46, options [nop,nop,TS val 3782118946 ecr 765088=
], length 227
15:21:21.121943 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [.], ack =
393, win 980, options [nop,nop,TS val 765142 ecr 3782118946], length 0
15:21:21.122152 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [P.], seq=
 30:36, ack 393, win 980, options [nop,nop,TS val 765142 ecr 3782118946=
], length 6
15:21:21.176726 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [P.], seq=
 393:412, ack 36, win 46, options [nop,nop,TS val 3782118969 ecr 765142=
], length 19
15:21:21.176819 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [P.], seq=
 36:41, ack 412, win 980, options [nop,nop,TS val 765197 ecr 3782118969=
], length 5
15:21:21.231655 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [P.], seq=
 412:446, ack 41, win 46, options [nop,nop,TS val 3782118992 ecr 765197=
], length 34
15:21:21.231815 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [P.], seq=
 41:49, ack 446, win 980, options [nop,nop,TS val 765252 ecr 3782118992=
], length 8
15:21:21.286246 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [P.], seq=
 446:465, ack 49, win 46, options [nop,nop,TS val 3782119014 ecr 765252=
], length 19
15:21:21.286358 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [P.], seq=
 49:87, ack 465, win 980, options [nop,nop,TS val 765307 ecr 3782119014=
], length 38
15:21:21.341224 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [P.], seq=
 465:493, ack 87, win 46, options [nop,nop,TS val 3782119037 ecr 765307=
], length 28
15:21:21.341386 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [P.], seq=
 87:130, ack 493, win 980, options [nop,nop,TS val 765362 ecr 378211903=
7], length 43
15:21:21.395904 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [P.], seq=
 493:509, ack 130, win 46, options [nop,nop,TS val 3782119060 ecr 76536=
2], length 16
15:21:21.396043 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [P.], seq=
 130:136, ack 509, win 980, options [nop,nop,TS val 765416 ecr 37821190=
60], length 6
15:21:21.450756 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [P.], seq=
 509:559, ack 136, win 46, options [nop,nop,TS val 3782119083 ecr 76541=
6], length 50
15:21:21.450884 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [SEW],=
 seq 2740127335, win 14600, options [mss 1460,sackOK,TS val 765471 ecr =
0,nop,wscale 4], length 0
15:21:21.490473 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [.], ack =
559, win 980, options [nop,nop,TS val 765511 ecr 3782119083], length 0
15:21:21.505467 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [S.], =
seq 3050262605, ack 2740127336, win 5792, options [mss 1460,sackOK,TS v=
al 3782119106 ecr 765471,nop,wscale 7],=20
length 0
15:21:21.505482 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 1, win 913, options [nop,nop,TS val 765526 ecr 3782119106], length 0
15:21:21.505586 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [P.], seq=
 136:179, ack 559, win 980, options [nop,nop,TS val 765526 ecr 37821190=
83], length 43
15:21:21.561989 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [P.], seq=
 559:660, ack 179, win 46, options [nop,nop,TS val 3782119130 ecr 76552=
6], length 101
15:21:21.562018 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [.], ack =
660, win 980, options [nop,nop,TS val 765582 ecr 3782119130], length 0
15:21:21.562256 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 1:1449, ack 1, win 46, options [nop,nop,TS val 3782119130 ecr 765526=
], length 1448
15:21:21.562269 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 1449, win 1094, options [nop,nop,TS val 765582 ecr 3782119130], leng=
th 0
15:21:21.562378 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 1449:2897, ack 1, win 46, options [nop,nop,TS val 3782119130 ecr 765=
526], length 1448
15:21:21.562390 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 2897, win 1275, options [nop,nop,TS val 765583 ecr 3782119130], leng=
th 0
15:21:21.617148 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 2897:4345, ack 1, win 46, options [nop,nop,TS val 3782119153 ecr 765=
582], length 1448
15:21:21.617160 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 4345, win 1456, options [nop,nop,TS val 765637 ecr 3782119153], leng=
th 0
15:21:21.617273 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 4345:5793, ack 1, win 46, options [nop,nop,TS val 3782119153 ecr 765=
582], length 1448
15:21:21.617286 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 5793, win 1637, options [nop,nop,TS val 765637 ecr 3782119153], leng=
th 0
15:21:21.617400 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 5793:7241, ack 1, win 46, options [nop,nop,TS val 3782119153 ecr 765=
583], length 1448
15:21:21.617413 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 7241, win 1818, options [nop,nop,TS val 765638 ecr 3782119153], leng=
th 0
15:21:21.617518 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 7241:8689, ack 1, win 46, options [nop,nop,TS val 3782119153 ecr 765=
583], length 1448
15:21:21.617529 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 8689, win 1999, options [nop,nop,TS val 765638 ecr 3782119153], leng=
th 0
15:21:21.671932 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 8689:10137, ack 1, win 46, options [nop,nop,TS val 3782119176 ecr 76=
5637], length 1448
15:21:21.671945 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 10137, win 2180, options [nop,nop,TS val 765692 ecr 3782119176], len=
gth 0
15:21:21.672201 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 10137:11585, ack 1, win 46, options [nop,nop,TS val 3782119176 ecr 7=
65637], length 1448
15:21:21.672212 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 11585, win 2361, options [nop,nop,TS val 765692 ecr 3782119176], len=
gth 0
15:21:21.672325 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 11585:13033, ack 1, win 46, options [nop,nop,TS val 3782119176 ecr 7=
65637], length 1448
15:21:21.672337 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 13033, win 2542, options [nop,nop,TS val 765693 ecr 3782119176], len=
gth 0
15:21:21.672447 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 13033:14481, ack 1, win 46, options [nop,nop,TS val 3782119176 ecr 7=
65637], length 1448
15:21:21.672458 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 14481, win 2723, options [nop,nop,TS val 765693 ecr 3782119176], len=
gth 0
15:21:21.672571 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 14481:15929, ack 1, win 46, options [nop,nop,TS val 3782119176 ecr 7=
65638], length 1448
15:21:21.672583 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 15929, win 2904, options [nop,nop,TS val 765693 ecr 3782119176], len=
gth 0
15:21:21.672694 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 15929:17377, ack 1, win 46, options [nop,nop,TS val 3782119176 ecr 7=
65638], length 1448
15:21:21.672704 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 17377, win 3085, options [nop,nop,TS val 765693 ecr 3782119176], len=
gth 0
15:21:21.726740 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 17377:18825, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65692], length 1448
15:21:21.726753 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 18825, win 3266, options [nop,nop,TS val 765747 ecr 3782119199], len=
gth 0
15:21:21.726865 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 18825:20273, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65692], length 1448
15:21:21.726876 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 20273, win 3447, options [nop,nop,TS val 765747 ecr 3782119199], len=
gth 0
15:21:21.726991 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 20273:21721, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65692], length 1448
15:21:21.727003 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 21721, win 3628, options [nop,nop,TS val 765747 ecr 3782119199], len=
gth 0
15:21:21.727110 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 21721:23169, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65692], length 1448
15:21:21.727120 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 23169, win 3809, options [nop,nop,TS val 765747 ecr 3782119199], len=
gth 0
15:21:21.727233 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 23169:24617, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65693], length 1448
15:21:21.727246 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 24617, win 3990, options [nop,nop,TS val 765747 ecr 3782119199], len=
gth 0
15:21:21.727356 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 24617:26065, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65693], length 1448
15:21:21.727367 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 26065, win 3991, options [nop,nop,TS val 765748 ecr 3782119199], len=
gth 0
15:21:21.727479 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 26065:27513, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65693], length 1448
15:21:21.727492 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 27513, win 3991, options [nop,nop,TS val 765748 ecr 3782119199], len=
gth 0
15:21:21.727603 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 27513:28961, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65693], length 1448
15:21:21.727614 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 28961, win 3991, options [nop,nop,TS val 765748 ecr 3782119199], len=
gth 0
15:21:21.727725 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 28961:30409, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65693], length 1448
15:21:21.727736 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 30409, win 3991, options [nop,nop,TS val 765748 ecr 3782119199], len=
gth 0
15:21:21.727848 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 30409:31857, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65693], length 1448
15:21:21.727861 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 31857, win 3991, options [nop,nop,TS val 765748 ecr 3782119199], len=
gth 0
15:21:21.727971 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 31857:33305, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65693], length 1448
15:21:21.728094 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 33305:34753, ack 1, win 46, options [nop,nop,TS val 3782119199 ecr 7=
65693], length 1448
15:21:21.728107 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 34753, win 3991, options [nop,nop,TS val 765748 ecr 3782119199], len=
gth 0
15:21:21.781589 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 34753:36201, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.781712 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 36201:37649, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.781726 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 37649, win 3991, options [nop,nop,TS val 765802 ecr 3782119222], len=
gth 0
15:21:21.781835 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 37649:39097, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.781959 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 39097:40545, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.781973 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 40545, win 3991, options [nop,nop,TS val 765802 ecr 3782119222], len=
gth 0
15:21:21.782082 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 40545:41993, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.782205 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 41993:43441, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.782218 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 43441, win 3991, options [nop,nop,TS val 765802 ecr 3782119222], len=
gth 0
15:21:21.782328 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 43441:44889, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.782451 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 44889:46337, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.782464 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 46337, win 3991, options [nop,nop,TS val 765803 ecr 3782119222], len=
gth 0
15:21:21.782574 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 46337:47785, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.782697 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 47785:49233, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.782709 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 49233, win 3991, options [nop,nop,TS val 765803 ecr 3782119222], len=
gth 0
15:21:21.782827 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 49233:50681, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.782950 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 50681:52129, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65747], length 1448
15:21:21.782963 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 52129, win 3991, options [nop,nop,TS val 765803 ecr 3782119222], len=
gth 0
15:21:21.783073 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 52129:53577, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65748], length 1448
15:21:21.783197 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 53577:55025, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65748], length 1448
15:21:21.783210 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 55025, win 3991, options [nop,nop,TS val 765803 ecr 3782119222], len=
gth 0
15:21:21.783319 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 55025:56473, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65748], length 1448
15:21:21.783442 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 56473:57921, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65748], length 1448
15:21:21.783453 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 57921, win 3991, options [nop,nop,TS val 765804 ecr 3782119222], len=
gth 0
15:21:21.783565 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 57921:59369, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65748], length 1448
15:21:21.783688 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 59369:60817, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65748], length 1448
15:21:21.783699 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 60817, win 3991, options [nop,nop,TS val 765804 ecr 3782119222], len=
gth 0
15:21:21.783812 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 60817:62265, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65748], length 1448
15:21:21.783934 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 62265:63713, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65748], length 1448
15:21:21.783945 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 63713, win 3991, options [nop,nop,TS val 765804 ecr 3782119222], len=
gth 0
15:21:21.784057 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 63713:65161, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65748], length 1448
15:21:21.784181 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 65161:66609, ack 1, win 46, options [nop,nop,TS val 3782119222 ecr 7=
65748], length 1448
15:21:21.784191 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 66609, win 3991, options [nop,nop,TS val 765804 ecr 3782119222], len=
gth 0
15:21:21.836513 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 66609:68057, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.836637 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 68057:69505, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.836649 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 69505, win 3991, options [nop,nop,TS val 765857 ecr 3782119245], len=
gth 0
15:21:21.836764 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 69505:70953, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.836883 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 70953:72401, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.836894 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 72401, win 3991, options [nop,nop,TS val 765857 ecr 3782119245], len=
gth 0
15:21:21.837006 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 72401:73849, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.837128 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 73849:75297, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.837139 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 75297, win 3991, options [nop,nop,TS val 765857 ecr 3782119245], len=
gth 0
15:21:21.837264 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 75297:76745, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.837382 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 76745:78193, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.837393 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 78193, win 3991, options [nop,nop,TS val 765858 ecr 3782119245], len=
gth 0
15:21:21.837505 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 78193:79641, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.837628 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 79641:81089, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.837641 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 81089, win 3991, options [nop,nop,TS val 765858 ecr 3782119245], len=
gth 0
15:21:21.837751 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 81089:82537, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.837874 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 82537:83985, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65802], length 1448
15:21:21.837886 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 83985, win 3991, options [nop,nop,TS val 765858 ecr 3782119245], len=
gth 0
15:21:21.837997 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 83985:85433, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65803], length 1448
15:21:21.838120 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 85433:86881, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65803], length 1448
15:21:21.838133 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 86881, win 3991, options [nop,nop,TS val 765858 ecr 3782119245], len=
gth 0
15:21:21.838244 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 86881:88329, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65803], length 1448
15:21:21.838366 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 88329:89777, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65803], length 1448
15:21:21.838378 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 89777, win 3991, options [nop,nop,TS val 765859 ecr 3782119245], len=
gth 0
15:21:21.838489 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 89777:91225, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65803], length 1448
15:21:21.838613 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 91225:92673, ack 1, win 46, options [nop,nop,TS val 3782119245 ecr 7=
65803], length 1448
15:21:21.838625 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 92673, win 3991, options [nop,nop,TS val 765859 ecr 3782119245], len=
gth 0
15:21:21.838735 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 92673:94121, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr 7=
65803], length 1448
15:21:21.838858 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 94121:95569, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr 7=
65803], length 1448
15:21:21.838871 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 95569, win 3991, options [nop,nop,TS val 765859 ecr 3782119246], len=
gth 0
15:21:21.838981 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 95569:97017, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr 7=
65803], length 1448
15:21:21.839105 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 97017:98465, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr 7=
65804], length 1448
15:21:21.839117 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 98465, win 3991, options [nop,nop,TS val 765859 ecr 3782119246], len=
gth 0
15:21:21.839228 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 98465:99913, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr 7=
65804], length 1448
15:21:21.839352 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 99913:101361, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr =
765804], length 1448
15:21:21.839364 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 101361, win 3991, options [nop,nop,TS val 765860 ecr 3782119246], le=
ngth 0
15:21:21.839473 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 101361:102809, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr=
 765804], length 1448
15:21:21.839486 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 102809, win 4187, options [nop,nop,TS val 765860 ecr 3782119246], le=
ngth 0
15:21:21.839597 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 102809:104257, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr=
 765804], length 1448
15:21:21.839608 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 104257, win 4368, options [nop,nop,TS val 765860 ecr 3782119246], le=
ngth 0
15:21:21.839719 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 104257:105705, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr=
 765804], length 1448
15:21:21.839732 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 105705, win 4549, options [nop,nop,TS val 765860 ecr 3782119246], le=
ngth 0
15:21:21.839842 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 105705:107153, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr=
 765804], length 1448
15:21:21.839853 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 107153, win 4730, options [nop,nop,TS val 765860 ecr 3782119246], le=
ngth 0
15:21:21.839966 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 107153:108601, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr=
 765804], length 1448
15:21:21.839978 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 108601, win 4911, options [nop,nop,TS val 765860 ecr 3782119246], le=
ngth 0
15:21:21.840089 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 108601:110049, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr=
 765804], length 1448
15:21:21.840099 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 110049, win 5092, options [nop,nop,TS val 765860 ecr 3782119246], le=
ngth 0
15:21:21.840212 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 110049:111497, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr=
 765804], length 1448
15:21:21.840224 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 111497, win 5273, options [nop,nop,TS val 765860 ecr 3782119246], le=
ngth 0
15:21:21.840335 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 111497:112945, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr=
 765804], length 1448
15:21:21.840345 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 112945, win 5454, options [nop,nop,TS val 765861 ecr 3782119246], le=
ngth 0
15:21:21.840458 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 112945:114393, ack 1, win 46, options [nop,nop,TS val 3782119246 ecr=
 765804], length 1448
15:21:21.840470 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 114393, win 5635, options [nop,nop,TS val 765861 ecr 3782119246], le=
ngth 0
15:21:21.891439 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 114393:115841, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765857], length 1448
15:21:21.891452 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 115841, win 5816, options [nop,nop,TS val 765912 ecr 3782119268], le=
ngth 0
15:21:21.891563 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 115841:117289, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765857], length 1448
15:21:21.891576 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 117289, win 5997, options [nop,nop,TS val 765912 ecr 3782119268], le=
ngth 0
15:21:21.891691 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 117289:118737, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765857], length 1448
15:21:21.891702 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 118737, win 6178, options [nop,nop,TS val 765912 ecr 3782119268], le=
ngth 0
15:21:21.891808 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 118737:120185, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765857], length 1448
15:21:21.891820 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 120185, win 6359, options [nop,nop,TS val 765912 ecr 3782119268], le=
ngth 0
15:21:21.891931 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 120185:121633, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765857], length 1448
15:21:21.891942 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 121633, win 6540, options [nop,nop,TS val 765912 ecr 3782119268], le=
ngth 0
15:21:21.892055 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 121633:123081, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765857], length 1448
15:21:21.892068 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 123081, win 6721, options [nop,nop,TS val 765912 ecr 3782119268], le=
ngth 0
15:21:21.892179 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [P.], =
seq 123081:124529, ack 1, win 46, options [nop,nop,TS val 3782119268 ec=
r 765857], length 1448
15:21:21.892189 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 124529, win 6902, options [nop,nop,TS val 765912 ecr 3782119268], le=
ngth 0
15:21:21.892301 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 124529:125977, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765857], length 1448
15:21:21.892311 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 125977, win 7083, options [nop,nop,TS val 765913 ecr 3782119268], le=
ngth 0
15:21:21.892423 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 125977:127425, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765857], length 1448
15:21:21.892436 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 127425, win 7264, options [nop,nop,TS val 765913 ecr 3782119268], le=
ngth 0
15:21:21.892546 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 127425:128873, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765857], length 1448
15:21:21.892557 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 128873, win 7445, options [nop,nop,TS val 765913 ecr 3782119268], le=
ngth 0
15:21:21.892670 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 128873:130321, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765857], length 1448
15:21:21.892682 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 130321, win 7626, options [nop,nop,TS val 765913 ecr 3782119268], le=
ngth 0
15:21:21.892793 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 130321:131769, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765857], length 1448
15:21:21.892803 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 131769, win 7807, options [nop,nop,TS val 765913 ecr 3782119268], le=
ngth 0
15:21:21.892915 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 131769:133217, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765858], length 1448
15:21:21.892927 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 133217, win 7988, options [nop,nop,TS val 765913 ecr 3782119268], le=
ngth 0
15:21:21.893039 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 133217:134665, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765858], length 1448
15:21:21.893050 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 134665, win 8145, options [nop,nop,TS val 765913 ecr 3782119268], le=
ngth 0
15:21:21.893162 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 134665:136113, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765858], length 1448
15:21:21.893285 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 136113:137561, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765858], length 1448
15:21:21.893296 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 137561, win 8145, options [nop,nop,TS val 765913 ecr 3782119268], le=
ngth 0
15:21:21.893408 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 137561:139009, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765858], length 1448
15:21:21.893531 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 139009:140457, ack 1, win 46, options [nop,nop,TS val 3782119268 ecr=
 765858], length 1448
15:21:21.893542 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 140457, win 8145, options [nop,nop,TS val 765914 ecr 3782119268], le=
ngth 0
15:21:21.893654 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 140457:141905, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765858], length 1448
15:21:21.893777 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 141905:143353, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765858], length 1448
15:21:21.893788 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 143353, win 8145, options [nop,nop,TS val 765914 ecr 3782119269], le=
ngth 0
15:21:21.893900 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 143353:144801, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765858], length 1448
15:21:21.894023 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 144801:146249, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.894034 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 146249, win 8145, options [nop,nop,TS val 765914 ecr 3782119269], le=
ngth 0
15:21:21.894152 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 146249:147697, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.894269 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 147697:149145, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.894282 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 149145, win 8145, options [nop,nop,TS val 765914 ecr 3782119269], le=
ngth 0
15:21:21.894393 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 149145:150593, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.894515 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 150593:152041, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.894528 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 152041, win 8145, options [nop,nop,TS val 765915 ecr 3782119269], le=
ngth 0
15:21:21.894638 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 152041:153489, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.894762 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 153489:154937, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.894774 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 154937, win 8145, options [nop,nop,TS val 765915 ecr 3782119269], le=
ngth 0
15:21:21.894884 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 154937:156385, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.895008 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 156385:157833, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.895020 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 157833, win 8145, options [nop,nop,TS val 765915 ecr 3782119269], le=
ngth 0
15:21:21.895131 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 157833:159281, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.895253 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 159281:160729, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.895266 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 160729, win 8145, options [nop,nop,TS val 765915 ecr 3782119269], le=
ngth 0
15:21:21.895376 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 160729:162177, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765859], length 1448
15:21:21.895499 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 162177:163625, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.895512 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 163625, win 8145, options [nop,nop,TS val 765916 ecr 3782119269], le=
ngth 0
15:21:21.895623 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 163625:165073, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.895746 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 165073:166521, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.895758 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 166521, win 8145, options [nop,nop,TS val 765916 ecr 3782119269], le=
ngth 0
15:21:21.895869 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 166521:167969, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.895992 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 167969:169417, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.896004 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 169417, win 8145, options [nop,nop,TS val 765916 ecr 3782119269], le=
ngth 0
15:21:21.896120 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 169417:170865, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.896238 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 170865:172313, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.896250 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 172313, win 8145, options [nop,nop,TS val 765916 ecr 3782119269], le=
ngth 0
15:21:21.896361 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 172313:173761, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.896484 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 173761:175209, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.896495 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 175209, win 8326, options [nop,nop,TS val 765917 ecr 3782119269], le=
ngth 0
15:21:21.896607 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 175209:176657, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.896620 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 176657, win 8507, options [nop,nop,TS val 765917 ecr 3782119269], le=
ngth 0
15:21:21.896730 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 176657:178105, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.896740 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 178105, win 8688, options [nop,nop,TS val 765917 ecr 3782119269], le=
ngth 0
15:21:21.896853 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 178105:179553, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.896865 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 179553, win 8869, options [nop,nop,TS val 765917 ecr 3782119269], le=
ngth 0
15:21:21.896976 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 179553:181001, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.896987 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 181001, win 9050, options [nop,nop,TS val 765917 ecr 3782119269], le=
ngth 0
15:21:21.897099 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 181001:182449, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.897222 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 182449:183897, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.897233 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 183897, win 9050, options [nop,nop,TS val 765917 ecr 3782119269], le=
ngth 0
15:21:21.897345 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 183897:185345, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.897468 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 185345:186793, ack 1, win 46, options [nop,nop,TS val 3782119269 ecr=
 765860], length 1448
15:21:21.897479 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 186793, win 9050, options [nop,nop,TS val 765918 ecr 3782119269], le=
ngth 0
15:21:21.897592 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [P.], =
seq 186793:188241, ack 1, win 46, options [nop,nop,TS val 3782119269 ec=
r 765860], length 1448
15:21:21.897714 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 188241:189689, ack 1, win 46, options [nop,nop,TS val 3782119270 ecr=
 765861], length 1448
15:21:21.897725 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 189689, win 9050, options [nop,nop,TS val 765918 ecr 3782119269], le=
ngth 0
15:21:21.897837 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 189689:191137, ack 1, win 46, options [nop,nop,TS val 3782119270 ecr=
 765861], length 1448
15:21:21.897961 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 191137:192585, ack 1, win 46, options [nop,nop,TS val 3782119270 ecr=
 765861], length 1448
15:21:21.897971 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 192585, win 9050, options [nop,nop,TS val 765918 ecr 3782119270], le=
ngth 0
15:21:21.898088 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 192585:194033, ack 1, win 46, options [nop,nop,TS val 3782119270 ecr=
 765861], length 1448
15:21:21.898207 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 194033:195481, ack 1, win 46, options [nop,nop,TS val 3782119270 ecr=
 765861], length 1448
15:21:21.898219 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 195481, win 9050, options [nop,nop,TS val 765918 ecr 3782119270], le=
ngth 0
15:21:21.898330 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 195481:196929, ack 1, win 46, options [nop,nop,TS val 3782119270 ecr=
 765861], length 1448
15:21:21.938401 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 196929, win 9050, options [nop,nop,TS val 765959 ecr 3782119270], le=
ngth 0
15:21:21.946654 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 196929:198377, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.946778 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 198377:199825, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.946790 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 199825, win 9050, options [nop,nop,TS val 765967 ecr 3782119291], le=
ngth 0
15:21:21.946906 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 199825:201273, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.947025 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 201273:202721, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.947036 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 202721, win 9050, options [nop,nop,TS val 765967 ecr 3782119291], le=
ngth 0
15:21:21.947147 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 202721:204169, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.947270 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 204169:205617, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.947281 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 205617, win 9050, options [nop,nop,TS val 765967 ecr 3782119291], le=
ngth 0
15:21:21.947393 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 205617:207065, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.947517 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 207065:208513, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.947528 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 208513, win 9050, options [nop,nop,TS val 765968 ecr 3782119291], le=
ngth 0
15:21:21.947639 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 208513:209961, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.947763 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 209961:211409, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.947774 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 211409, win 9050, options [nop,nop,TS val 765968 ecr 3782119291], le=
ngth 0
15:21:21.947885 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 211409:212857, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.948009 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 212857:214305, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765912], length 1448
15:21:21.948020 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 214305, win 9050, options [nop,nop,TS val 765968 ecr 3782119291], le=
ngth 0
15:21:21.948132 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 214305:215753, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765913], length 1448
15:21:21.948255 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 215753:217201, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765913], length 1448
15:21:21.948266 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 217201, win 9050, options [nop,nop,TS val 765968 ecr 3782119291], le=
ngth 0
15:21:21.948382 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 217201:218649, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765913], length 1448
15:21:21.948501 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 218649:220097, ack 1, win 46, options [nop,nop,TS val 3782119291 ecr=
 765913], length 1448
15:21:21.948514 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 220097, win 9050, options [nop,nop,TS val 765969 ecr 3782119291], le=
ngth 0
15:21:21.948623 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 220097:221545, ack 1, win 46, options [nop,nop,TS val 3782119292 ecr=
 765913], length 1448
15:21:21.948747 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 221545:222993, ack 1, win 46, options [nop,nop,TS val 3782119292 ecr=
 765913], length 1448
15:21:21.948762 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 222993, win 9050, options [nop,nop,TS val 765969 ecr 3782119292], le=
ngth 0
15:21:21.948872 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 222993:224441, ack 1, win 46, options [nop,nop,TS val 3782119292 ecr=
 765913], length 1448
15:21:21.948993 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 224441:225889, ack 1, win 46, options [nop,nop,TS val 3782119292 ecr=
 765913], length 1448
15:21:21.949005 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 225889, win 9050, options [nop,nop,TS val 765969 ecr 3782119292], le=
ngth 0
15:21:21.949116 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 225889:227337, ack 1, win 46, options [nop,nop,TS val 3782119292 ecr=
 765913], length 1448
15:21:21.949239 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 227337:228785, ack 1, win 46, options [nop,nop,TS val 3782119292 ecr=
 765913], length 1448
15:21:21.949252 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 228785, win 9050, options [nop,nop,TS val 765969 ecr 3782119292], le=
ngth 0
15:21:21.949366 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 228785:230233, ack 1, win 46, options [nop,nop,TS val 3782119292 ecr=
 765913], length 1448
15:21:21.949485 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 230233:231681, ack 1, win 46, options [nop,nop,TS val 3782119292 ecr=
 765913], length 1448
15:21:21.949498 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 231681, win 9050, options [nop,nop,TS val 765970 ecr 3782119292], le=
ngth 0
15:21:21.949608 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 231681:233129, ack 1, win 46, options [nop,nop,TS val 3782119292 ecr=
 765913], length 1448
15:21:21.949731 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [.], s=
eq 233129:234577, ack 1, win 46, options [nop,nop,TS val 3782119292 ecr=
 765913], length 1448
15:21:21.949744 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [.], a=
ck 234577, win 9050, options [nop,nop,TS val 765970 ecr 3782119292], le=
ngth 0
300 packets captured
302 packets received by filter
0 packets dropped by kernel
