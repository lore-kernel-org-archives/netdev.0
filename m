From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: Re: Re: Re: Re: Re: limited network bandwidth with
 3.2.x kernels
Date: Wed, 15 Feb 2012 16:08:01 +0100
Message-ID: <1329318481.2437.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <4249109.nLB9JCi9YF@localhost.localdomain>
	 <1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <2687521.3ztN17SHUf@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:56369 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878Ab2BOPIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 10:08:05 -0500
Received: by wics10 with SMTP id s10so575445wic.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 07:08:04 -0800 (PST)
In-Reply-To: <2687521.3ztN17SHUf@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 16:11 +0200, alekcejk@googlemai=
l.com a
=C3=A9crit :

> ftp.snt.utwente.nl - yet one server with download speed 11,2 Megabyte=
s/s with 3.1.10 kernel
> and 5,41 or 5,56 or 5,8 Megabytes/s with 3.2.6 kernel (maximum speed =
shown by wget
> may vary after restarting of download).
>=20

OK good... Unfortunately there is something in the path eating ECT

all frames we receive from remote peer have tos 0x0, so we cant detect
retransmits.

> tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size=
 65535 bytes
> 16:01:37.313964 IP (tos 0x0, ttl 100, id 63113, offset 0, flags [DF],=
 proto TCP (6), length 60)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [SEW], cksum 0x1028 (=
incorrect -> 0xe45b), seq 1339270399, win 14600, options [mss 1460,sack=
OK,TS val 4294857334 ecr 0,nop,wscale 4],=20
> length 0
> 16:01:37.365919 IP (tos 0x0, ttl 57, id 0, offset 0, flags [DF], prot=
o TCP (6), length 60)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [S.E], cksum 0xec12 (=
correct), seq 1335027049, ack 1339270400, win 5792, options [mss 1460,s=
ackOK,TS val 86368507 ecr=20
> 4294857334,nop,wscale 7], length 0
> 16:01:37.365942 IP (tos 0x0, ttl 100, id 63114, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (in=
correct -> 0x2dfa), ack 1, win 913, options [nop,nop,TS val 4294857386 =
ecr 86368507], length 0
> 16:01:37.418747 IP (tos 0x0, ttl 57, id 1133, offset 0, flags [DF], p=
roto TCP (6), length 116)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x4e71 (c=
orrect), seq 1:65, ack 1, win 46, options [nop,nop,TS val 86368520 ecr =
4294857386], length 64
> 16:01:37.418764 IP (tos 0x0, ttl 100, id 63115, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (in=
correct -> 0x2d78), ack 65, win 913, options [nop,nop,TS val 4294857439=
 ecr 86368520], length 0
> 16:01:37.418771 IP (tos 0x0, ttl 57, id 1134, offset 0, flags [DF], p=
roto TCP (6), length 93)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x4a09 (c=
orrect), seq 65:106, ack 1, win 46, options [nop,nop,TS val 86368520 ec=
r 4294857386], length 41
> 16:01:37.418783 IP (tos 0x0, ttl 100, id 63116, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (in=
correct -> 0x2d4f), ack 106, win 913, options [nop,nop,TS val 429485743=
9 ecr 86368520], length 0
> 16:01:37.418790 IP (tos 0x0, ttl 57, id 1135, offset 0, flags [DF], p=
roto TCP (6), length 93)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x8227 (c=
orrect), seq 106:147, ack 1, win 46, options [nop,nop,TS val 86368520 e=
cr 4294857386], length 41
> 16:01:37.418801 IP (tos 0x0, ttl 100, id 63117, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (in=
correct -> 0x2d26), ack 147, win 913, options [nop,nop,TS val 429485743=
9 ecr 86368520], length 0
> 16:01:37.470393 IP (tos 0x0, ttl 57, id 1136, offset 0, flags [DF], p=
roto TCP (6), length 1396)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x71a3 (c=
orrect), seq 147:1491, ack 1, win 46, options [nop,nop,TS val 86368533 =
ecr 4294857439], length 1344
> 16:01:37.470405 IP (tos 0x0, ttl 100, id 63118, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (in=
correct -> 0x26fd), ack 1491, win 1081, options [nop,nop,TS val 4294857=
491 ecr 86368533], length 0
> 16:01:37.470668 IP (tos 0x2,ECT(0), ttl 100, id 63119, offset 0, flag=
s [DF], proto TCP (6), length 68)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1030 (i=
ncorrect -> 0x9f08), seq 1:17, ack 1491, win 1081, options [nop,nop,TS =
val 4294857491 ecr 86368533], length 16
> 16:01:37.522117 IP (tos 0x0, ttl 57, id 1137, offset 0, flags [DF], p=
roto TCP (6), length 52)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [.], cksum 0x2aeb (co=
rrect), ack 17, win 46, options [nop,nop,TS val 86368546 ecr 4294857491=
], length 0
> 16:01:37.522129 IP (tos 0x0, ttl 57, id 1138, offset 0, flags [DF], p=
roto TCP (6), length 86)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0xe39f (c=
orrect), seq 1491:1525, ack 17, win 46, options [nop,nop,TS val 8636854=
6 ecr 4294857491], length 34
> 16:01:37.522176 IP (tos 0x2,ECT(0), ttl 100, id 63120, offset 0, flag=
s [DF], proto TCP (6), length 65)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x102d (i=
ncorrect -> 0x3bca), seq 17:30, ack 1525, win 1081, options [nop,nop,TS=
 val 4294857543 ecr 86368546], length 13
> 16:01:37.573661 IP (tos 0x0, ttl 57, id 1139, offset 0, flags [DF], p=
roto TCP (6), length 75)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x48e3 (c=
orrect), seq 1525:1548, ack 30, win 46, options [nop,nop,TS val 8636855=
9 ecr 4294857543], length 23
> 16:01:37.573826 IP (tos 0x2,ECT(0), ttl 100, id 63121, offset 0, flag=
s [DF], proto TCP (6), length 58)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1026 (i=
ncorrect -> 0x7260), seq 30:36, ack 1548, win 1081, options [nop,nop,TS=
 val 4294857594 ecr 86368559], length 6
> 16:01:37.625305 IP (tos 0x0, ttl 57, id 1140, offset 0, flags [DF], p=
roto TCP (6), length 71)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0xc2b3 (c=
orrect), seq 1548:1567, ack 36, win 46, options [nop,nop,TS val 8636857=
1 ecr 4294857594], length 19
> 16:01:37.625425 IP (tos 0x2,ECT(0), ttl 100, id 63122, offset 0, flag=
s [DF], proto TCP (6), length 57)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1025 (i=
ncorrect -> 0x875b), seq 36:41, ack 1567, win 1081, options [nop,nop,TS=
 val 4294857646 ecr 86368571], length 5
> 16:01:37.676911 IP (tos 0x0, ttl 57, id 1141, offset 0, flags [DF], p=
roto TCP (6), length 61)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x7223 (c=
orrect), seq 1567:1576, ack 41, win 46, options [nop,nop,TS val 8636858=
4 ecr 4294857646], length 9
> 16:01:37.677032 IP (tos 0x2,ECT(0), ttl 100, id 63123, offset 0, flag=
s [DF], proto TCP (6), length 60)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1028 (i=
ncorrect -> 0x537d), seq 41:49, ack 1576, win 1081, options [nop,nop,TS=
 val 4294857697 ecr 86368584], length 8
> 16:01:37.728484 IP (tos 0x0, ttl 57, id 1142, offset 0, flags [DF], p=
roto TCP (6), length 83)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0xf385 (c=
orrect), seq 1576:1607, ack 49, win 46, options [nop,nop,TS val 8636859=
7 ecr 4294857697], length 31
> 16:01:37.728631 IP (tos 0x2,ECT(0), ttl 100, id 63124, offset 0, flag=
s [DF], proto TCP (6), length 93)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1049 (i=
ncorrect -> 0x2b64), seq 49:90, ack 1607, win 1081, options [nop,nop,TS=
 val 4294857749 ecr 86368597], length 41
> 16:01:37.780113 IP (tos 0x0, ttl 57, id 1143, offset 0, flags [DF], p=
roto TCP (6), length 89)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x9d5d (c=
orrect), seq 1607:1644, ack 90, win 46, options [nop,nop,TS val 8636861=
0 ecr 4294857749], length 37
> 16:01:37.780247 IP (tos 0x2,ECT(0), ttl 100, id 63125, offset 0, flag=
s [DF], proto TCP (6), length 91)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1047 (i=
ncorrect -> 0x9579), seq 90:129, ack 1644, win 1081, options [nop,nop,T=
S val 4294857801 ecr 86368610], length 39
> 16:01:37.831756 IP (tos 0x0, ttl 57, id 1144, offset 0, flags [DF], p=
roto TCP (6), length 67)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0xae1f (c=
orrect), seq 1644:1659, ack 129, win 46, options [nop,nop,TS val 863686=
23 ecr 4294857801], length 15
> 16:01:37.831882 IP (tos 0x2,ECT(0), ttl 100, id 63126, offset 0, flag=
s [DF], proto TCP (6), length 58)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1026 (i=
ncorrect -> 0x7362), seq 129:135, ack 1659, win 1081, options [nop,nop,=
TS val 4294857852 ecr 86368623], length 6
> 16:01:37.883482 IP (tos 0x0, ttl 57, id 1145, offset 0, flags [DF], p=
roto TCP (6), length 104)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x6b16 (c=
orrect), seq 1659:1711, ack 135, win 46, options [nop,nop,TS val 863686=
36 ecr 4294857852], length 52
> 16:01:37.883589 IP (tos 0x0, ttl 100, id 45885, offset 0, flags [DF],=
 proto TCP (6), length 60)
>     AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [SEW], cksum 0x102=
8 (incorrect -> 0x234e), seq 1207822221, win 14600, options [mss 1460,s=
ackOK,TS val 4294857904 ecr 0,nop,wscale 4],=20
> length 0
> 16:01:37.923277 IP (tos 0x0, ttl 100, id 63127, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (in=
correct -> 0x236f), ack 1711, win 1081, options [nop,nop,TS val 4294857=
944 ecr 86368636], length 0
> 16:01:37.933260 IP (tos 0x0, ttl 57, id 0, offset 0, flags [DF], prot=
o TCP (6), length 60)
>     130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [S.E], cksum 0xe74=
4 (correct), seq 3516507796, ack 1207822222, win 5792, options [mss 146=
0,sackOK,TS val 86368649 ecr=20
> 4294857904,nop,wscale 7], length 0

> 16:01:37.933275 IP (tos 0x0, ttl 100, id 45886, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 =
(incorrect -> 0x292e), ack 1, win 913, options [nop,nop,TS val 42948579=
54 ecr 86368649], length 0
> 16:01:37.933425 IP (tos 0x2,ECT(0), ttl 100, id 63128, offset 0, flag=
s [DF], proto TCP (6), length 91)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1047 (i=
ncorrect -> 0x9b4d), seq 135:174, ack 1711, win 1081, options [nop,nop,=
TS val 4294857954 ecr 86368636], length 39
> 16:01:37.983255 IP (tos 0x0, ttl 57, id 18176, offset 0, flags [DF], =
proto TCP (6), length 1500)
>     130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x9529 =
(correct), seq 1:1449, ack 1, win 46, options [nop,nop,TS val 86368661 =
ecr 4294857954], length 1448
> 16:01:37.983272 IP (tos 0x0, ttl 100, id 45887, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 =
(incorrect -> 0x2293), ack 1449, win 1094, options [nop,nop,TS val 4294=
858004 ecr 86368661], length 0
> 16:01:37.983378 IP (tos 0x0, ttl 57, id 18177, offset 0, flags [DF], =
proto TCP (6), length 1500)
>     130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x2135 =
(correct), seq 1449:2897, ack 1, win 46, options [nop,nop,TS val 863686=
61 ecr 4294857954], length 1448
> 16:01:37.983388 IP (tos 0x0, ttl 100, id 45888, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 =
(incorrect -> 0x1c36), ack 2897, win 1275, options [nop,nop,TS val 4294=
858004 ecr 86368661], length 0
> 16:01:37.983500 IP (tos 0x0, ttl 57, id 18178, offset 0, flags [DF], =
proto TCP (6), length 1500)
>     130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x1b8d =
(correct), seq 2897:4345, ack 1, win 46, options [nop,nop,TS val 863686=
61 ecr 4294857954], length 1448
> 16:01:37.983509 IP (tos 0x0, ttl 100, id 45889, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 =
(incorrect -> 0x15d9), ack 4345, win 1456, options [nop,nop,TS val 4294=
858004 ecr 86368661], length 0
> 16:01:37.984985 IP (tos 0x0, ttl 57, id 1146, offset 0, flags [DF], p=
roto TCP (6), length 149)
>     130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x8cc1 (c=
orrect), seq 1711:1808, ack 174, win 46, options [nop,nop,TS val 863686=
61 ecr 4294857954], length 97
> 16:01:37.985019 IP (tos 0x0, ttl 100, id 63129, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (in=
correct -> 0x2291), ack 1808, win 1081, options [nop,nop,TS val 4294858=
005 ecr 86368661], length 0
> 16:01:38.033132 IP (tos 0x0, ttl 57, id 18179, offset 0, flags [DF], =
proto TCP (6), length 1500)
>     130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x15a6 =
(correct), seq 4345:5793, ack 1, win 46, options [nop,nop,TS val 863686=
74 ecr 4294858004], length 1448
> 16:01:38.033143 IP (tos 0x0, ttl 100, id 45890, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 =
(incorrect -> 0x0f3e), ack 5793, win 1637, options [nop,nop,TS val 4294=
858053 ecr 86368674], length 0
> 16:01:38.033255 IP (tos 0x0, ttl 57, id 18180, offset 0, flags [DF], =
proto TCP (6), length 1500)
>     130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x0ffe =
(correct), seq 5793:7241, ack 1, win 46, options [nop,nop,TS val 863686=
74 ecr 4294858004], length 1448
> 16:01:38.033267 IP (tos 0x0, ttl 100, id 45891, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 =
(incorrect -> 0x08e0), ack 7241, win 1818, options [nop,nop,TS val 4294=
858054 ecr 86368674], length 0
> 16:01:38.033377 IP (tos 0x0, ttl 57, id 18181, offset 0, flags [DF], =
proto TCP (6), length 1500)
>     130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x0a56 =
(correct), seq 7241:8689, ack 1, win 46, options [nop,nop,TS val 863686=
74 ecr 4294858004], length 1448
> 16:01:38.033385 IP (tos 0x0, ttl 100, id 45892, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 =
(incorrect -> 0x0283), ack 8689, win 1999, options [nop,nop,TS val 4294=
858054 ecr 86368674], length 0
> 16:01:38.033501 IP (tos 0x0, ttl 57, id 18182, offset 0, flags [DF], =
proto TCP (6), length 1500)
>     130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x04ae =
(correct), seq 8689:10137, ack 1, win 46, options [nop,nop,TS val 86368=
674 ecr 4294858004], length 1448
> 16:01:38.033509 IP (tos 0x0, ttl 100, id 45893, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 =
(incorrect -> 0xfc25), ack 10137, win 2180, options [nop,nop,TS val 429=
4858054 ecr 86368674], length 0
> 16:01:38.033629 IP (tos 0x0, ttl 57, id 18183, offset 0, flags [DF], =
proto TCP (6), length 1500)
>     130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xff05 =
(correct), seq 10137:11585, ack 1, win 46, options [nop,nop,TS val 8636=
8674 ecr 4294858004], length 1448
> 16:01:38.033642 IP (tos 0x0, ttl 100, id 45894, offset 0, flags [DF],=
 proto TCP (6), length 52)
>     AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 =
(incorrect -> 0xf5c8), ack 11585, win 2361, options [nop,nop,TS val 429=
4858054 ecr 86368674], length 0
