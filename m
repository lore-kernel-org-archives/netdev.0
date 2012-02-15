From: alekcejk@googlemail.com
Subject: Re: Re: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 16:11:52 +0200
Message-ID: <2687521.3ztN17SHUf@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <4249109.nLB9JCi9YF@localhost.localdomain> <1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54665 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757921Ab2BOOMK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 09:12:10 -0500
Received: by bkcjm19 with SMTP id jm19so957089bkc.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 06:12:08 -0800 (PST)
In-Reply-To: <1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=A1=D1=80=D0=B5=D0=B4=D0=B0 15 =D1=84=D0=B5=D0=B2=D1=80=D0=B0=D0=
=BB=D1=8F 2012 14:49:45 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=
=D0=BB=D0=B8:
> Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 05:44 -0800, alekcejk@googlem=
ail.com a
>=20
> =C3=A9crit :
> > =D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=
=D1=82 =D0=A1=D1=80=D0=B5=D0=B4=D0=B0 15 =D1=84=D0=B5=D0=B2=D1=80=D0=B0=
=D0=BB=D1=8F 2012 05:43:13 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=
=B0=D0=BB=D0=B8:
> > > OK thanks, nothing seems wrong on receiver side.
> > >=20
> > > Could you try to force ECN enabled flows and send tcpdump, to che=
ck if
> > > we receive retransmits ?
> > >=20
> > > echo 1 >/proc/sys/net/ipv4/tcp_ecn
> >=20
> > 2 was there before I did it.
> >=20
> > > And check tcp can engage ECN : tcpdump SYN/SYNACK should look lik=
e:
> > >=20
> > > 05:41:17.943538 IP 192.168.1.97.45986 > 68.232.35.119.80: Flags [=
SEW],
> > > seq 2109565072, win 14600, options [mss 1460,sackOK,TS val 829549=
2 ecr
> > > 0,nop,wscale 6], length 0
> > >=20
> > > 05:41:17.980619 IP 68.232.35.119.80 > 192.168.1.97.45986: Flags [=
S.E],
> > > seq 2519424885, ack 2109565073, win 14600, options [mss
> > > 1452,nop,nop,sackOK,nop,wscale 6], length 0
> >=20
> > tcpdump: verbose output suppressed, use -v or -vv for full protocol=
 decode
> > listening on eth0, link-type EN10MB (Ethernet), capture size 65535 =
bytes
> > 15:21:20.799077 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [SEW]=
, seq 1233000896, win 14600, options [mss 1460,sackOK,TS val 764819 ecr=
 0,nop,wscale 4], length 0
> > 15:21:20.853575 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [S.],=
 seq 3046667726, ack 1233000897, win 5792, options [mss 1460,sackOK,TS =
val 3782118833 ecr 764819,nop,wscale 7],
> > length 0
> >=20
> > 15:21:21.450884 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [S=
EW], seq 2740127335, win 14600, options [mss 1460,sackOK,TS val 765471 =
ecr 0,nop,wscale 4], length 0
> > 15:21:21.505467 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [S=
=2E], seq 3050262605, ack 2740127336, win 5792, options [mss 1460,sackO=
K,TS val 3782119106 ecr 765471,nop,wscale 7],
> > length 0
>=20
> Unfortunately remote server doesnt negotiate ECN (we dont see E flag =
in
> the SYNACK frame)
>=20
> Try to find another one, and check SYNACK looks like : Flags [S.E]

ftp.snt.utwente.nl - yet one server with download speed 11,2 Megabytes/=
s with 3.1.10 kernel
and 5,41 or 5,56 or 5,8 Megabytes/s with 3.2.6 kernel (maximum speed sh=
own by wget
may vary after restarting of download).

tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 6=
5535 bytes
16:01:37.313964 IP (tos 0x0, ttl 100, id 63113, offset 0, flags [DF], p=
roto TCP (6), length 60)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [SEW], cksum 0x1028 (in=
correct -> 0xe45b), seq 1339270399, win 14600, options [mss 1460,sackOK=
,TS val 4294857334 ecr 0,nop,wscale 4],=20
length 0
16:01:37.365919 IP (tos 0x0, ttl 57, id 0, offset 0, flags [DF], proto =
TCP (6), length 60)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [S.E], cksum 0xec12 (co=
rrect), seq 1335027049, ack 1339270400, win 5792, options [mss 1460,sac=
kOK,TS val 86368507 ecr=20
4294857334,nop,wscale 7], length 0
16:01:37.365942 IP (tos 0x0, ttl 100, id 63114, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (inco=
rrect -> 0x2dfa), ack 1, win 913, options [nop,nop,TS val 4294857386 ec=
r 86368507], length 0
16:01:37.418747 IP (tos 0x0, ttl 57, id 1133, offset 0, flags [DF], pro=
to TCP (6), length 116)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x4e71 (cor=
rect), seq 1:65, ack 1, win 46, options [nop,nop,TS val 86368520 ecr 42=
94857386], length 64
16:01:37.418764 IP (tos 0x0, ttl 100, id 63115, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (inco=
rrect -> 0x2d78), ack 65, win 913, options [nop,nop,TS val 4294857439 e=
cr 86368520], length 0
16:01:37.418771 IP (tos 0x0, ttl 57, id 1134, offset 0, flags [DF], pro=
to TCP (6), length 93)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x4a09 (cor=
rect), seq 65:106, ack 1, win 46, options [nop,nop,TS val 86368520 ecr =
4294857386], length 41
16:01:37.418783 IP (tos 0x0, ttl 100, id 63116, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (inco=
rrect -> 0x2d4f), ack 106, win 913, options [nop,nop,TS val 4294857439 =
ecr 86368520], length 0
16:01:37.418790 IP (tos 0x0, ttl 57, id 1135, offset 0, flags [DF], pro=
to TCP (6), length 93)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x8227 (cor=
rect), seq 106:147, ack 1, win 46, options [nop,nop,TS val 86368520 ecr=
 4294857386], length 41
16:01:37.418801 IP (tos 0x0, ttl 100, id 63117, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (inco=
rrect -> 0x2d26), ack 147, win 913, options [nop,nop,TS val 4294857439 =
ecr 86368520], length 0
16:01:37.470393 IP (tos 0x0, ttl 57, id 1136, offset 0, flags [DF], pro=
to TCP (6), length 1396)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x71a3 (cor=
rect), seq 147:1491, ack 1, win 46, options [nop,nop,TS val 86368533 ec=
r 4294857439], length 1344
16:01:37.470405 IP (tos 0x0, ttl 100, id 63118, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (inco=
rrect -> 0x26fd), ack 1491, win 1081, options [nop,nop,TS val 429485749=
1 ecr 86368533], length 0
16:01:37.470668 IP (tos 0x2,ECT(0), ttl 100, id 63119, offset 0, flags =
[DF], proto TCP (6), length 68)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1030 (inc=
orrect -> 0x9f08), seq 1:17, ack 1491, win 1081, options [nop,nop,TS va=
l 4294857491 ecr 86368533], length 16
16:01:37.522117 IP (tos 0x0, ttl 57, id 1137, offset 0, flags [DF], pro=
to TCP (6), length 52)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [.], cksum 0x2aeb (corr=
ect), ack 17, win 46, options [nop,nop,TS val 86368546 ecr 4294857491],=
 length 0
16:01:37.522129 IP (tos 0x0, ttl 57, id 1138, offset 0, flags [DF], pro=
to TCP (6), length 86)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0xe39f (cor=
rect), seq 1491:1525, ack 17, win 46, options [nop,nop,TS val 86368546 =
ecr 4294857491], length 34
16:01:37.522176 IP (tos 0x2,ECT(0), ttl 100, id 63120, offset 0, flags =
[DF], proto TCP (6), length 65)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x102d (inc=
orrect -> 0x3bca), seq 17:30, ack 1525, win 1081, options [nop,nop,TS v=
al 4294857543 ecr 86368546], length 13
16:01:37.573661 IP (tos 0x0, ttl 57, id 1139, offset 0, flags [DF], pro=
to TCP (6), length 75)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x48e3 (cor=
rect), seq 1525:1548, ack 30, win 46, options [nop,nop,TS val 86368559 =
ecr 4294857543], length 23
16:01:37.573826 IP (tos 0x2,ECT(0), ttl 100, id 63121, offset 0, flags =
[DF], proto TCP (6), length 58)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1026 (inc=
orrect -> 0x7260), seq 30:36, ack 1548, win 1081, options [nop,nop,TS v=
al 4294857594 ecr 86368559], length 6
16:01:37.625305 IP (tos 0x0, ttl 57, id 1140, offset 0, flags [DF], pro=
to TCP (6), length 71)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0xc2b3 (cor=
rect), seq 1548:1567, ack 36, win 46, options [nop,nop,TS val 86368571 =
ecr 4294857594], length 19
16:01:37.625425 IP (tos 0x2,ECT(0), ttl 100, id 63122, offset 0, flags =
[DF], proto TCP (6), length 57)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1025 (inc=
orrect -> 0x875b), seq 36:41, ack 1567, win 1081, options [nop,nop,TS v=
al 4294857646 ecr 86368571], length 5
16:01:37.676911 IP (tos 0x0, ttl 57, id 1141, offset 0, flags [DF], pro=
to TCP (6), length 61)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x7223 (cor=
rect), seq 1567:1576, ack 41, win 46, options [nop,nop,TS val 86368584 =
ecr 4294857646], length 9
16:01:37.677032 IP (tos 0x2,ECT(0), ttl 100, id 63123, offset 0, flags =
[DF], proto TCP (6), length 60)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1028 (inc=
orrect -> 0x537d), seq 41:49, ack 1576, win 1081, options [nop,nop,TS v=
al 4294857697 ecr 86368584], length 8
16:01:37.728484 IP (tos 0x0, ttl 57, id 1142, offset 0, flags [DF], pro=
to TCP (6), length 83)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0xf385 (cor=
rect), seq 1576:1607, ack 49, win 46, options [nop,nop,TS val 86368597 =
ecr 4294857697], length 31
16:01:37.728631 IP (tos 0x2,ECT(0), ttl 100, id 63124, offset 0, flags =
[DF], proto TCP (6), length 93)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1049 (inc=
orrect -> 0x2b64), seq 49:90, ack 1607, win 1081, options [nop,nop,TS v=
al 4294857749 ecr 86368597], length 41
16:01:37.780113 IP (tos 0x0, ttl 57, id 1143, offset 0, flags [DF], pro=
to TCP (6), length 89)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x9d5d (cor=
rect), seq 1607:1644, ack 90, win 46, options [nop,nop,TS val 86368610 =
ecr 4294857749], length 37
16:01:37.780247 IP (tos 0x2,ECT(0), ttl 100, id 63125, offset 0, flags =
[DF], proto TCP (6), length 91)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1047 (inc=
orrect -> 0x9579), seq 90:129, ack 1644, win 1081, options [nop,nop,TS =
val 4294857801 ecr 86368610], length 39
16:01:37.831756 IP (tos 0x0, ttl 57, id 1144, offset 0, flags [DF], pro=
to TCP (6), length 67)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0xae1f (cor=
rect), seq 1644:1659, ack 129, win 46, options [nop,nop,TS val 86368623=
 ecr 4294857801], length 15
16:01:37.831882 IP (tos 0x2,ECT(0), ttl 100, id 63126, offset 0, flags =
[DF], proto TCP (6), length 58)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1026 (inc=
orrect -> 0x7362), seq 129:135, ack 1659, win 1081, options [nop,nop,TS=
 val 4294857852 ecr 86368623], length 6
16:01:37.883482 IP (tos 0x0, ttl 57, id 1145, offset 0, flags [DF], pro=
to TCP (6), length 104)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x6b16 (cor=
rect), seq 1659:1711, ack 135, win 46, options [nop,nop,TS val 86368636=
 ecr 4294857852], length 52
16:01:37.883589 IP (tos 0x0, ttl 100, id 45885, offset 0, flags [DF], p=
roto TCP (6), length 60)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [SEW], cksum 0x1028 =
(incorrect -> 0x234e), seq 1207822221, win 14600, options [mss 1460,sac=
kOK,TS val 4294857904 ecr 0,nop,wscale 4],=20
length 0
16:01:37.923277 IP (tos 0x0, ttl 100, id 63127, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (inco=
rrect -> 0x236f), ack 1711, win 1081, options [nop,nop,TS val 429485794=
4 ecr 86368636], length 0
16:01:37.933260 IP (tos 0x0, ttl 57, id 0, offset 0, flags [DF], proto =
TCP (6), length 60)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [S.E], cksum 0xe744 =
(correct), seq 3516507796, ack 1207822222, win 5792, options [mss 1460,=
sackOK,TS val 86368649 ecr=20
4294857904,nop,wscale 7], length 0
16:01:37.933275 IP (tos 0x0, ttl 100, id 45886, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x292e), ack 1, win 913, options [nop,nop,TS val 4294857954=
 ecr 86368649], length 0
16:01:37.933425 IP (tos 0x2,ECT(0), ttl 100, id 63128, offset 0, flags =
[DF], proto TCP (6), length 91)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [P.], cksum 0x1047 (inc=
orrect -> 0x9b4d), seq 135:174, ack 1711, win 1081, options [nop,nop,TS=
 val 4294857954 ecr 86368636], length 39
16:01:37.983255 IP (tos 0x0, ttl 57, id 18176, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x9529 (c=
orrect), seq 1:1449, ack 1, win 46, options [nop,nop,TS val 86368661 ec=
r 4294857954], length 1448
16:01:37.983272 IP (tos 0x0, ttl 100, id 45887, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x2293), ack 1449, win 1094, options [nop,nop,TS val 429485=
8004 ecr 86368661], length 0
16:01:37.983378 IP (tos 0x0, ttl 57, id 18177, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x2135 (c=
orrect), seq 1449:2897, ack 1, win 46, options [nop,nop,TS val 86368661=
 ecr 4294857954], length 1448
16:01:37.983388 IP (tos 0x0, ttl 100, id 45888, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x1c36), ack 2897, win 1275, options [nop,nop,TS val 429485=
8004 ecr 86368661], length 0
16:01:37.983500 IP (tos 0x0, ttl 57, id 18178, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x1b8d (c=
orrect), seq 2897:4345, ack 1, win 46, options [nop,nop,TS val 86368661=
 ecr 4294857954], length 1448
16:01:37.983509 IP (tos 0x0, ttl 100, id 45889, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x15d9), ack 4345, win 1456, options [nop,nop,TS val 429485=
8004 ecr 86368661], length 0
16:01:37.984985 IP (tos 0x0, ttl 57, id 1146, offset 0, flags [DF], pro=
to TCP (6), length 149)
    130.89.149.20.21 > AA.BB.CC.XY.53896: Flags [P.], cksum 0x8cc1 (cor=
rect), seq 1711:1808, ack 174, win 46, options [nop,nop,TS val 86368661=
 ecr 4294857954], length 97
16:01:37.985019 IP (tos 0x0, ttl 100, id 63129, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.53896 > 130.89.149.20.21: Flags [.], cksum 0x1020 (inco=
rrect -> 0x2291), ack 1808, win 1081, options [nop,nop,TS val 429485800=
5 ecr 86368661], length 0
16:01:38.033132 IP (tos 0x0, ttl 57, id 18179, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x15a6 (c=
orrect), seq 4345:5793, ack 1, win 46, options [nop,nop,TS val 86368674=
 ecr 4294858004], length 1448
16:01:38.033143 IP (tos 0x0, ttl 100, id 45890, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x0f3e), ack 5793, win 1637, options [nop,nop,TS val 429485=
8053 ecr 86368674], length 0
16:01:38.033255 IP (tos 0x0, ttl 57, id 18180, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x0ffe (c=
orrect), seq 5793:7241, ack 1, win 46, options [nop,nop,TS val 86368674=
 ecr 4294858004], length 1448
16:01:38.033267 IP (tos 0x0, ttl 100, id 45891, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x08e0), ack 7241, win 1818, options [nop,nop,TS val 429485=
8054 ecr 86368674], length 0
16:01:38.033377 IP (tos 0x0, ttl 57, id 18181, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x0a56 (c=
orrect), seq 7241:8689, ack 1, win 46, options [nop,nop,TS val 86368674=
 ecr 4294858004], length 1448
16:01:38.033385 IP (tos 0x0, ttl 100, id 45892, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x0283), ack 8689, win 1999, options [nop,nop,TS val 429485=
8054 ecr 86368674], length 0
16:01:38.033501 IP (tos 0x0, ttl 57, id 18182, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x04ae (c=
orrect), seq 8689:10137, ack 1, win 46, options [nop,nop,TS val 8636867=
4 ecr 4294858004], length 1448
16:01:38.033509 IP (tos 0x0, ttl 100, id 45893, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xfc25), ack 10137, win 2180, options [nop,nop,TS val 42948=
58054 ecr 86368674], length 0
16:01:38.033629 IP (tos 0x0, ttl 57, id 18183, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xff05 (c=
orrect), seq 10137:11585, ack 1, win 46, options [nop,nop,TS val 863686=
74 ecr 4294858004], length 1448
16:01:38.033642 IP (tos 0x0, ttl 100, id 45894, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xf5c8), ack 11585, win 2361, options [nop,nop,TS val 42948=
58054 ecr 86368674], length 0
16:01:38.082999 IP (tos 0x0, ttl 57, id 18184, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xf920 (c=
orrect), seq 11585:13033, ack 1, win 46, options [nop,nop,TS val 863686=
86 ecr 4294858053], length 1448
16:01:38.083018 IP (tos 0x0, ttl 100, id 45895, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xef2e), ack 13033, win 2542, options [nop,nop,TS val 42948=
58103 ecr 86368686], length 0
16:01:38.083122 IP (tos 0x0, ttl 57, id 18185, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xf378 (c=
orrect), seq 13033:14481, ack 1, win 46, options [nop,nop,TS val 863686=
86 ecr 4294858053], length 1448
16:01:38.083131 IP (tos 0x0, ttl 100, id 45896, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xe8d1), ack 14481, win 2723, options [nop,nop,TS val 42948=
58103 ecr 86368686], length 0
16:01:38.083245 IP (tos 0x0, ttl 57, id 18186, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xedd0 (c=
orrect), seq 14481:15929, ack 1, win 46, options [nop,nop,TS val 863686=
86 ecr 4294858053], length 1448
16:01:38.083255 IP (tos 0x0, ttl 100, id 45897, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xe273), ack 15929, win 2904, options [nop,nop,TS val 42948=
58104 ecr 86368686], length 0
16:01:38.083368 IP (tos 0x0, ttl 57, id 18187, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xe827 (c=
orrect), seq 15929:17377, ack 1, win 46, options [nop,nop,TS val 863686=
86 ecr 4294858054], length 1448
16:01:38.083379 IP (tos 0x0, ttl 100, id 45898, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xdc16), ack 17377, win 3085, options [nop,nop,TS val 42948=
58104 ecr 86368686], length 0
16:01:38.083496 IP (tos 0x0, ttl 57, id 18188, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xe27f (c=
orrect), seq 17377:18825, ack 1, win 46, options [nop,nop,TS val 863686=
86 ecr 4294858054], length 1448
16:01:38.083507 IP (tos 0x0, ttl 100, id 45899, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xd5b9), ack 18825, win 3266, options [nop,nop,TS val 42948=
58104 ecr 86368686], length 0
16:01:38.083615 IP (tos 0x0, ttl 57, id 18189, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xdcd7 (c=
orrect), seq 18825:20273, ack 1, win 46, options [nop,nop,TS val 863686=
86 ecr 4294858054], length 1448
16:01:38.083627 IP (tos 0x0, ttl 100, id 45900, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xcf5c), ack 20273, win 3447, options [nop,nop,TS val 42948=
58104 ecr 86368686], length 0
16:01:38.083737 IP (tos 0x0, ttl 57, id 18190, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xd72f (c=
orrect), seq 20273:21721, ack 1, win 46, options [nop,nop,TS val 863686=
86 ecr 4294858054], length 1448
16:01:38.083750 IP (tos 0x0, ttl 100, id 45901, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xc8ff), ack 21721, win 3628, options [nop,nop,TS val 42948=
58104 ecr 86368686], length 0
16:01:38.083860 IP (tos 0x0, ttl 57, id 18191, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xd187 (c=
orrect), seq 21721:23169, ack 1, win 46, options [nop,nop,TS val 863686=
86 ecr 4294858054], length 1448
16:01:38.083871 IP (tos 0x0, ttl 100, id 45902, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xc2a2), ack 23169, win 3809, options [nop,nop,TS val 42948=
58104 ecr 86368686], length 0
16:01:38.083983 IP (tos 0x0, ttl 57, id 18192, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xcbdf (c=
orrect), seq 23169:24617, ack 1, win 46, options [nop,nop,TS val 863686=
86 ecr 4294858054], length 1448
16:01:38.083994 IP (tos 0x0, ttl 100, id 45903, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xbc45), ack 24617, win 3990, options [nop,nop,TS val 42948=
58104 ecr 86368686], length 0
16:01:38.132905 IP (tos 0x0, ttl 57, id 18193, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xc5f9 (c=
orrect), seq 24617:26065, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858103], length 1448
16:01:38.132916 IP (tos 0x0, ttl 100, id 45904, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xb65e), ack 26065, win 3991, options [nop,nop,TS val 42948=
58153 ecr 86368699], length 0
16:01:38.133028 IP (tos 0x0, ttl 57, id 18194, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xc051 (c=
orrect), seq 26065:27513, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858103], length 1448
16:01:38.133039 IP (tos 0x0, ttl 100, id 45905, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xb0b6), ack 27513, win 3991, options [nop,nop,TS val 42948=
58153 ecr 86368699], length 0
16:01:38.133150 IP (tos 0x0, ttl 57, id 18195, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xbaa9 (c=
orrect), seq 27513:28961, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858103], length 1448
16:01:38.133158 IP (tos 0x0, ttl 100, id 45906, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xab0e), ack 28961, win 3991, options [nop,nop,TS val 42948=
58153 ecr 86368699], length 0
16:01:38.133274 IP (tos 0x0, ttl 57, id 18196, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xb501 (c=
orrect), seq 28961:30409, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858103], length 1448
16:01:38.133285 IP (tos 0x0, ttl 100, id 45907, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xa565), ack 30409, win 3991, options [nop,nop,TS val 42948=
58154 ecr 86368699], length 0
16:01:38.133397 IP (tos 0x0, ttl 57, id 18197, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xaf58 (c=
orrect), seq 30409:31857, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858104], length 1448
16:01:38.133406 IP (tos 0x0, ttl 100, id 45908, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x9fbd), ack 31857, win 3991, options [nop,nop,TS val 42948=
58154 ecr 86368699], length 0
16:01:38.133526 IP (tos 0x0, ttl 57, id 18198, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x84c9 (c=
orrect), seq 31857:33305, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858104], length 1448
16:01:38.133644 IP (tos 0x0, ttl 57, id 18199, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x1498 (c=
orrect), seq 33305:34753, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858104], length 1448
16:01:38.133654 IP (tos 0x0, ttl 100, id 45909, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x946d), ack 34753, win 3991, options [nop,nop,TS val 42948=
58154 ecr 86368699], length 0
16:01:38.133767 IP (tos 0x0, ttl 57, id 18200, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xee92 (c=
orrect), seq 34753:36201, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858104], length 1448
16:01:38.133890 IP (tos 0x0, ttl 57, id 18201, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xd39d (c=
orrect), seq 36201:37649, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858104], length 1448
16:01:38.133900 IP (tos 0x0, ttl 100, id 45910, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x891d), ack 37649, win 3991, options [nop,nop,TS val 42948=
58154 ecr 86368699], length 0
16:01:38.134012 IP (tos 0x0, ttl 57, id 18202, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x70fb (c=
orrect), seq 37649:39097, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858104], length 1448
16:01:38.134135 IP (tos 0x0, ttl 57, id 18203, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x8d68 (c=
orrect), seq 39097:40545, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858104], length 1448
16:01:38.134146 IP (tos 0x0, ttl 100, id 45911, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x7dcd), ack 40545, win 3991, options [nop,nop,TS val 42948=
58154 ecr 86368699], length 0
16:01:38.134259 IP (tos 0x0, ttl 57, id 18204, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x87c0 (c=
orrect), seq 40545:41993, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858104], length 1448
16:01:38.134383 IP (tos 0x0, ttl 57, id 18205, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x8218 (c=
orrect), seq 41993:43441, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858104], length 1448
16:01:38.134393 IP (tos 0x0, ttl 100, id 45912, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x727c), ack 43441, win 3991, options [nop,nop,TS val 42948=
58155 ecr 86368699], length 0
16:01:38.134505 IP (tos 0x0, ttl 57, id 18206, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x7c70 (c=
orrect), seq 43441:44889, ack 1, win 46, options [nop,nop,TS val 863686=
99 ecr 4294858104], length 1448
16:01:38.174240 IP (tos 0x0, ttl 100, id 45913, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x6c9d), ack 44889, win 4006, options [nop,nop,TS val 42948=
58195 ecr 86368699], length 0
16:01:38.182767 IP (tos 0x0, ttl 57, id 18207, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x768b (c=
orrect), seq 44889:46337, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858153], length 1448
16:01:38.182890 IP (tos 0x0, ttl 57, id 18208, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x70e3 (c=
orrect), seq 46337:47785, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858153], length 1448
16:01:38.182902 IP (tos 0x0, ttl 100, id 45914, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x609c), ack 47785, win 4163, options [nop,nop,TS val 42948=
58203 ecr 86368711], length 0
16:01:38.183013 IP (tos 0x0, ttl 57, id 18209, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x6b3b (c=
orrect), seq 47785:49233, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858153], length 1448
16:01:38.183138 IP (tos 0x0, ttl 57, id 18210, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x6593 (c=
orrect), seq 49233:50681, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858153], length 1448
16:01:38.183150 IP (tos 0x0, ttl 100, id 45915, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x554c), ack 50681, win 4163, options [nop,nop,TS val 42948=
58203 ecr 86368711], length 0
16:01:38.183259 IP (tos 0x0, ttl 57, id 18211, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x5feb (c=
orrect), seq 50681:52129, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858153], length 1448
16:01:38.183383 IP (tos 0x0, ttl 57, id 18212, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x5a43 (c=
orrect), seq 52129:53577, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858153], length 1448
16:01:38.183394 IP (tos 0x0, ttl 100, id 45916, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x49fb), ack 53577, win 4163, options [nop,nop,TS val 42948=
58204 ecr 86368711], length 0
16:01:38.183506 IP (tos 0x0, ttl 57, id 18213, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x549b (c=
orrect), seq 53577:55025, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858153], length 1448
16:01:38.183629 IP (tos 0x0, ttl 57, id 18214, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x4ef3 (c=
orrect), seq 55025:56473, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858153], length 1448
16:01:38.183640 IP (tos 0x0, ttl 100, id 45917, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x3eab), ack 56473, win 4163, options [nop,nop,TS val 42948=
58204 ecr 86368711], length 0
16:01:38.183752 IP (tos 0x0, ttl 57, id 18215, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x494a (c=
orrect), seq 56473:57921, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858154], length 1448
16:01:38.183875 IP (tos 0x0, ttl 57, id 18216, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x43a2 (c=
orrect), seq 57921:59369, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858154], length 1448
16:01:38.183888 IP (tos 0x0, ttl 100, id 45918, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x335b), ack 59369, win 4163, options [nop,nop,TS val 42948=
58204 ecr 86368711], length 0
16:01:38.183998 IP (tos 0x0, ttl 57, id 18217, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x3dfa (c=
orrect), seq 59369:60817, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858154], length 1448
16:01:38.184122 IP (tos 0x0, ttl 57, id 18218, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x3852 (c=
orrect), seq 60817:62265, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858154], length 1448
16:01:38.184133 IP (tos 0x0, ttl 100, id 45919, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x280b), ack 62265, win 4163, options [nop,nop,TS val 42948=
58204 ecr 86368711], length 0
16:01:38.184243 IP (tos 0x0, ttl 57, id 18219, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x32aa (c=
orrect), seq 62265:63713, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858154], length 1448
16:01:38.184367 IP (tos 0x0, ttl 57, id 18220, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x2d02 (c=
orrect), seq 63713:65161, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858154], length 1448
16:01:38.184378 IP (tos 0x0, ttl 100, id 45920, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x1cba), ack 65161, win 4163, options [nop,nop,TS val 42948=
58205 ecr 86368711], length 0
16:01:38.184491 IP (tos 0x0, ttl 57, id 18221, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x9625 (c=
orrect), seq 65161:66609, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858154], length 1448
16:01:38.184613 IP (tos 0x0, ttl 57, id 18222, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x2a2b (c=
orrect), seq 66609:68057, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858154], length 1448
16:01:38.184624 IP (tos 0x0, ttl 100, id 45921, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x116a), ack 68057, win 4163, options [nop,nop,TS val 42948=
58205 ecr 86368711], length 0
16:01:38.184736 IP (tos 0x0, ttl 57, id 18223, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x187e (c=
orrect), seq 68057:69505, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858154], length 1448
16:01:38.184860 IP (tos 0x0, ttl 57, id 18224, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xa1bc (c=
orrect), seq 69505:70953, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858154], length 1448
16:01:38.184870 IP (tos 0x0, ttl 100, id 45922, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x061a), ack 70953, win 4163, options [nop,nop,TS val 42948=
58205 ecr 86368711], length 0
16:01:38.184982 IP (tos 0x0, ttl 57, id 18225, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x8ff5 (c=
orrect), seq 70953:72401, ack 1, win 46, options [nop,nop,TS val 863687=
11 ecr 4294858154], length 1448
16:01:38.185106 IP (tos 0x0, ttl 57, id 18226, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x07df (c=
orrect), seq 72401:73849, ack 1, win 46, options [nop,nop,TS val 863687=
12 ecr 4294858154], length 1448
16:01:38.185118 IP (tos 0x0, ttl 100, id 45923, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xfac9), ack 73849, win 4163, options [nop,nop,TS val 42948=
58205 ecr 86368711], length 0
16:01:38.185228 IP (tos 0x0, ttl 57, id 18227, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xfb73 (c=
orrect), seq 73849:75297, ack 1, win 46, options [nop,nop,TS val 863687=
12 ecr 4294858154], length 1448
16:01:38.185351 IP (tos 0x0, ttl 57, id 18228, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x6185 (c=
orrect), seq 75297:76745, ack 1, win 46, options [nop,nop,TS val 863687=
12 ecr 4294858154], length 1448
16:01:38.185362 IP (tos 0x0, ttl 100, id 45924, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xef77), ack 76745, win 4163, options [nop,nop,TS val 42948=
58206 ecr 86368712], length 0
16:01:38.224174 IP (tos 0x0, ttl 57, id 18229, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x1022 (c=
orrect), seq 76745:78193, ack 1, win 46, options [nop,nop,TS val 863687=
22 ecr 4294858195], length 1448
16:01:38.224297 IP (tos 0x0, ttl 57, id 18230, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xf43d (c=
orrect), seq 78193:79641, ack 1, win 46, options [nop,nop,TS val 863687=
22 ecr 4294858195], length 1448
16:01:38.224307 IP (tos 0x0, ttl 100, id 45925, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xe3f6), ack 79641, win 4163, options [nop,nop,TS val 42948=
58245 ecr 86368722], length 0
16:01:38.224419 IP (tos 0x0, ttl 57, id 18231, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xe491 (c=
orrect), seq 79641:81089, ack 1, win 46, options [nop,nop,TS val 863687=
22 ecr 4294858195], length 1448
16:01:38.224552 IP (tos 0x0, ttl 57, id 18232, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x2c56 (c=
orrect), seq 81089:82537, ack 1, win 46, options [nop,nop,TS val 863687=
22 ecr 4294858195], length 1448
16:01:38.224564 IP (tos 0x0, ttl 100, id 45926, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xd8a6), ack 82537, win 4163, options [nop,nop,TS val 42948=
58245 ecr 86368722], length 0
16:01:38.224666 IP (tos 0x0, ttl 57, id 18233, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xecce (c=
orrect), seq 82537:83985, ack 1, win 46, options [nop,nop,TS val 863687=
22 ecr 4294858195], length 1448
16:01:38.224790 IP (tos 0x0, ttl 57, id 18234, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x770b (c=
orrect), seq 83985:85433, ack 1, win 46, options [nop,nop,TS val 863687=
22 ecr 4294858195], length 1448
16:01:38.224802 IP (tos 0x0, ttl 100, id 45927, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xcd56), ack 85433, win 4163, options [nop,nop,TS val 42948=
58245 ecr 86368722], length 0
16:01:38.224912 IP (tos 0x0, ttl 57, id 18235, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xac94 (c=
orrect), seq 85433:86881, ack 1, win 46, options [nop,nop,TS val 863687=
22 ecr 4294858195], length 1448
16:01:38.225039 IP (tos 0x0, ttl 57, id 18236, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xe6b7 (c=
orrect), seq 86881:88329, ack 1, win 46, options [nop,nop,TS val 863687=
22 ecr 4294858195], length 1448
16:01:38.225050 IP (tos 0x0, ttl 100, id 45928, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xc206), ack 88329, win 4163, options [nop,nop,TS val 42948=
58245 ecr 86368722], length 0
16:01:38.233497 IP (tos 0x0, ttl 57, id 18237, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x1330 (c=
orrect), seq 88329:89777, ack 1, win 46, options [nop,nop,TS val 863687=
24 ecr 4294858204], length 1448
16:01:38.233620 IP (tos 0x0, ttl 57, id 18238, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x5a16 (c=
orrect), seq 89777:91225, ack 1, win 46, options [nop,nop,TS val 863687=
24 ecr 4294858204], length 1448
16:01:38.233631 IP (tos 0x0, ttl 100, id 45929, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xb6ab), ack 91225, win 4163, options [nop,nop,TS val 42948=
58254 ecr 86368724], length 0
16:01:38.233741 IP (tos 0x0, ttl 57, id 18239, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x77c6 (c=
orrect), seq 91225:92673, ack 1, win 46, options [nop,nop,TS val 863687=
24 ecr 4294858204], length 1448
16:01:38.233866 IP (tos 0x0, ttl 57, id 18240, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x9280 (c=
orrect), seq 92673:94121, ack 1, win 46, options [nop,nop,TS val 863687=
24 ecr 4294858204], length 1448
16:01:38.233879 IP (tos 0x0, ttl 100, id 45930, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xab5b), ack 94121, win 4163, options [nop,nop,TS val 42948=
58254 ecr 86368724], length 0
16:01:38.233989 IP (tos 0x0, ttl 57, id 18241, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x7a6e (c=
orrect), seq 94121:95569, ack 1, win 46, options [nop,nop,TS val 863687=
24 ecr 4294858204], length 1448
16:01:38.234113 IP (tos 0x0, ttl 57, id 18242, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x76f6 (c=
orrect), seq 95569:97017, ack 1, win 46, options [nop,nop,TS val 863687=
24 ecr 4294858204], length 1448
16:01:38.234125 IP (tos 0x0, ttl 100, id 45931, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xa00b), ack 97017, win 4163, options [nop,nop,TS val 42948=
58254 ecr 86368724], length 0
16:01:38.234235 IP (tos 0x0, ttl 57, id 18243, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xc750 (c=
orrect), seq 97017:98465, ack 1, win 46, options [nop,nop,TS val 863687=
24 ecr 4294858204], length 1448
16:01:38.234359 IP (tos 0x0, ttl 57, id 18244, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x4369 (c=
orrect), seq 98465:99913, ack 1, win 46, options [nop,nop,TS val 863687=
24 ecr 4294858204], length 1448
16:01:38.234371 IP (tos 0x0, ttl 100, id 45932, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x94ba), ack 99913, win 4163, options [nop,nop,TS val 42948=
58255 ecr 86368724], length 0
16:01:38.234481 IP (tos 0x0, ttl 57, id 18245, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xa4c6 (c=
orrect), seq 99913:101361, ack 1, win 46, options [nop,nop,TS val 86368=
724 ecr 4294858204], length 1448
16:01:38.234492 IP (tos 0x0, ttl 100, id 45933, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x8e5d), ack 101361, win 4344, options [nop,nop,TS val 4294=
858255 ecr 86368724], length 0
16:01:38.234604 IP (tos 0x0, ttl 57, id 18246, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x0692 (c=
orrect), seq 101361:102809, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858204], length 1448
16:01:38.234613 IP (tos 0x0, ttl 100, id 45934, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x8800), ack 102809, win 4525, options [nop,nop,TS val 4294=
858255 ecr 86368724], length 0
16:01:38.234728 IP (tos 0x0, ttl 57, id 18247, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xa1de (c=
orrect), seq 102809:104257, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858204], length 1448
16:01:38.234739 IP (tos 0x0, ttl 100, id 45935, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x81a3), ack 104257, win 4706, options [nop,nop,TS val 4294=
858255 ecr 86368724], length 0
16:01:38.234849 IP (tos 0x0, ttl 57, id 18248, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x7393 (c=
orrect), seq 104257:105705, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858204], length 1448
16:01:38.234860 IP (tos 0x0, ttl 100, id 45936, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x7b46), ack 105705, win 4887, options [nop,nop,TS val 4294=
858255 ecr 86368724], length 0
16:01:38.234978 IP (tos 0x0, ttl 57, id 18249, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xeb01 (c=
orrect), seq 105705:107153, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858204], length 1448
16:01:38.234989 IP (tos 0x0, ttl 100, id 45937, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x74e9), ack 107153, win 5068, options [nop,nop,TS val 4294=
858255 ecr 86368724], length 0
16:01:38.235097 IP (tos 0x0, ttl 57, id 18250, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x6620 (c=
orrect), seq 107153:108601, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858204], length 1448
16:01:38.235109 IP (tos 0x0, ttl 100, id 45938, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x6e8c), ack 108601, win 5249, options [nop,nop,TS val 4294=
858255 ecr 86368724], length 0
16:01:38.235219 IP (tos 0x0, ttl 57, id 18251, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x106e (c=
orrect), seq 108601:110049, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.235230 IP (tos 0x0, ttl 100, id 45939, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x682e), ack 110049, win 5430, options [nop,nop,TS val 4294=
858256 ecr 86368724], length 0
16:01:38.235343 IP (tos 0x0, ttl 57, id 18252, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x4f1b (c=
orrect), seq 110049:111497, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.235355 IP (tos 0x0, ttl 100, id 45940, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x61d1), ack 111497, win 5611, options [nop,nop,TS val 4294=
858256 ecr 86368724], length 0
16:01:38.235465 IP (tos 0x0, ttl 57, id 18253, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xb1e8 (c=
orrect), seq 111497:112945, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.235474 IP (tos 0x0, ttl 100, id 45941, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x5b74), ack 112945, win 5792, options [nop,nop,TS val 4294=
858256 ecr 86368724], length 0
16:01:38.235596 IP (tos 0x0, ttl 57, id 18254, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xa968 (c=
orrect), seq 112945:114393, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.235607 IP (tos 0x0, ttl 100, id 45942, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x5517), ack 114393, win 5973, options [nop,nop,TS val 4294=
858256 ecr 86368724], length 0
16:01:38.235712 IP (tos 0x0, ttl 57, id 18255, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xf849 (c=
orrect), seq 114393:115841, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.235724 IP (tos 0x0, ttl 100, id 45943, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x4eba), ack 115841, win 6154, options [nop,nop,TS val 4294=
858256 ecr 86368724], length 0
16:01:38.235835 IP (tos 0x0, ttl 57, id 18256, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xc0d0 (c=
orrect), seq 115841:117289, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.235846 IP (tos 0x0, ttl 100, id 45944, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x485d), ack 117289, win 6335, options [nop,nop,TS val 4294=
858256 ecr 86368724], length 0
16:01:38.235958 IP (tos 0x0, ttl 57, id 18257, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x5b79 (c=
orrect), seq 117289:118737, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.235970 IP (tos 0x0, ttl 100, id 45945, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x4200), ack 118737, win 6516, options [nop,nop,TS val 4294=
858256 ecr 86368724], length 0
16:01:38.236080 IP (tos 0x0, ttl 57, id 18258, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x22e2 (c=
orrect), seq 118737:120185, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.236089 IP (tos 0x0, ttl 100, id 45946, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x3ba3), ack 120185, win 6697, options [nop,nop,TS val 4294=
858256 ecr 86368724], length 0
16:01:38.236210 IP (tos 0x0, ttl 57, id 18259, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xdf18 (c=
orrect), seq 120185:121633, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.236327 IP (tos 0x0, ttl 57, id 18260, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x0895 (c=
orrect), seq 121633:123081, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.236337 IP (tos 0x0, ttl 100, id 45947, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x3052), ack 123081, win 6697, options [nop,nop,TS val 4294=
858257 ecr 86368724], length 0
16:01:38.236450 IP (tos 0x0, ttl 57, id 18261, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x3bd8 (c=
orrect), seq 123081:124529, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.236573 IP (tos 0x0, ttl 57, id 18262, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x5e4e (c=
orrect), seq 124529:125977, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.236583 IP (tos 0x0, ttl 100, id 45948, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x2502), ack 125977, win 6697, options [nop,nop,TS val 4294=
858257 ecr 86368724], length 0
16:01:38.236696 IP (tos 0x0, ttl 57, id 18263, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xf9c9 (c=
orrect), seq 125977:127425, ack 1, win 46, options [nop,nop,TS val 8636=
8724 ecr 4294858205], length 1448
16:01:38.274169 IP (tos 0x0, ttl 57, id 18264, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x33af (c=
orrect), seq 127425:128873, ack 1, win 46, options [nop,nop,TS val 8636=
8734 ecr 4294858245], length 1448
16:01:38.274182 IP (tos 0x0, ttl 100, id 45949, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x198c), ack 128873, win 6697, options [nop,nop,TS val 4294=
858295 ecr 86368724], length 0
16:01:38.274292 IP (tos 0x0, ttl 57, id 18265, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xef48 (c=
orrect), seq 128873:130321, ack 1, win 46, options [nop,nop,TS val 8636=
8734 ecr 4294858245], length 1448
16:01:38.274420 IP (tos 0x0, ttl 57, id 18266, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x8e0c (c=
orrect), seq 130321:131769, ack 1, win 46, options [nop,nop,TS val 8636=
8734 ecr 4294858245], length 1448
16:01:38.274433 IP (tos 0x0, ttl 100, id 45950, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x0e32), ack 131769, win 6697, options [nop,nop,TS val 4294=
858295 ecr 86368734], length 0
16:01:38.274538 IP (tos 0x0, ttl 57, id 18267, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x2285 (c=
orrect), seq 131769:133217, ack 1, win 46, options [nop,nop,TS val 8636=
8734 ecr 4294858245], length 1448
16:01:38.274662 IP (tos 0x0, ttl 57, id 18268, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x427a (c=
orrect), seq 133217:134665, ack 1, win 46, options [nop,nop,TS val 8636=
8734 ecr 4294858245], length 1448
16:01:38.274675 IP (tos 0x0, ttl 100, id 45951, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x02e2), ack 134665, win 6697, options [nop,nop,TS val 4294=
858295 ecr 86368734], length 0
16:01:38.274784 IP (tos 0x0, ttl 57, id 18269, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xd96c (c=
orrect), seq 134665:136113, ack 1, win 46, options [nop,nop,TS val 8636=
8734 ecr 4294858245], length 1448
16:01:38.274912 IP (tos 0x0, ttl 57, id 18270, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x4886 (c=
orrect), seq 136113:137561, ack 1, win 46, options [nop,nop,TS val 8636=
8734 ecr 4294858245], length 1448
16:01:38.274924 IP (tos 0x0, ttl 100, id 45952, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xf791), ack 137561, win 6697, options [nop,nop,TS val 4294=
858295 ecr 86368734], length 0
16:01:38.275032 IP (tos 0x0, ttl 57, id 18271, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x0c17 (c=
orrect), seq 137561:139009, ack 1, win 46, options [nop,nop,TS val 8636=
8734 ecr 4294858245], length 1448
16:01:38.275154 IP (tos 0x0, ttl 57, id 18272, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x61d0 (c=
orrect), seq 139009:140457, ack 1, win 46, options [nop,nop,TS val 8636=
8734 ecr 4294858245], length 1448
16:01:38.275166 IP (tos 0x0, ttl 100, id 45953, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xec41), ack 140457, win 6697, options [nop,nop,TS val 4294=
858295 ecr 86368734], length 0
16:01:38.283494 IP (tos 0x0, ttl 57, id 18273, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x4600 (c=
orrect), seq 140457:141905, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.283618 IP (tos 0x0, ttl 57, id 18274, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xfb13 (c=
orrect), seq 141905:143353, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.283630 IP (tos 0x0, ttl 100, id 45954, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xe0e6), ack 143353, win 6697, options [nop,nop,TS val 4294=
858304 ecr 86368736], length 0
16:01:38.283739 IP (tos 0x0, ttl 57, id 18275, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xbb4d (c=
orrect), seq 143353:144801, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.283864 IP (tos 0x0, ttl 57, id 18276, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x89ae (c=
orrect), seq 144801:146249, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.283875 IP (tos 0x0, ttl 100, id 45955, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xd596), ack 146249, win 6697, options [nop,nop,TS val 4294=
858304 ecr 86368736], length 0
16:01:38.283987 IP (tos 0x0, ttl 57, id 18277, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xd244 (c=
orrect), seq 146249:147697, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.284110 IP (tos 0x0, ttl 57, id 18278, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xe215 (c=
orrect), seq 147697:149145, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.284120 IP (tos 0x0, ttl 100, id 45956, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xca46), ack 149145, win 6697, options [nop,nop,TS val 4294=
858304 ecr 86368736], length 0
16:01:38.284232 IP (tos 0x0, ttl 57, id 18279, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x9231 (c=
orrect), seq 149145:150593, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.284356 IP (tos 0x0, ttl 57, id 18280, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xedf8 (c=
orrect), seq 150593:152041, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.284367 IP (tos 0x0, ttl 100, id 45957, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xbef5), ack 152041, win 6697, options [nop,nop,TS val 4294=
858305 ecr 86368736], length 0
16:01:38.284479 IP (tos 0x0, ttl 57, id 18281, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x9401 (c=
orrect), seq 152041:153489, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.284602 IP (tos 0x0, ttl 57, id 18282, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x9329 (c=
orrect), seq 153489:154937, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.284614 IP (tos 0x0, ttl 100, id 45958, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xb3a5), ack 154937, win 6697, options [nop,nop,TS val 4294=
858305 ecr 86368736], length 0
16:01:38.284725 IP (tos 0x0, ttl 57, id 18283, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x7431 (c=
orrect), seq 154937:156385, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.284848 IP (tos 0x0, ttl 57, id 18284, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x175f (c=
orrect), seq 156385:157833, ack 1, win 46, options [nop,nop,TS val 8636=
8736 ecr 4294858254], length 1448
16:01:38.284861 IP (tos 0x0, ttl 100, id 45959, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xa855), ack 157833, win 6697, options [nop,nop,TS val 4294=
858305 ecr 86368736], length 0
16:01:38.284971 IP (tos 0x0, ttl 57, id 18285, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x8c5c (c=
orrect), seq 157833:159281, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858255], length 1448
16:01:38.285094 IP (tos 0x0, ttl 57, id 18286, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xd3de (c=
orrect), seq 159281:160729, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858255], length 1448
16:01:38.285106 IP (tos 0x0, ttl 100, id 45960, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x9d04), ack 160729, win 6697, options [nop,nop,TS val 4294=
858305 ecr 86368737], length 0
16:01:38.285216 IP (tos 0x0, ttl 57, id 18287, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xef44 (c=
orrect), seq 160729:162177, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858255], length 1448
16:01:38.285340 IP (tos 0x0, ttl 57, id 18288, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x390b (c=
orrect), seq 162177:163625, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858255], length 1448
16:01:38.285351 IP (tos 0x0, ttl 100, id 45961, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x91b3), ack 163625, win 6697, options [nop,nop,TS val 4294=
858306 ecr 86368737], length 0
16:01:38.285463 IP (tos 0x0, ttl 57, id 18289, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xb804 (c=
orrect), seq 163625:165073, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858255], length 1448
16:01:38.285586 IP (tos 0x0, ttl 57, id 18290, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xffa8 (c=
orrect), seq 165073:166521, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858255], length 1448
16:01:38.285597 IP (tos 0x0, ttl 100, id 45962, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x8663), ack 166521, win 6697, options [nop,nop,TS val 4294=
858306 ecr 86368737], length 0
16:01:38.285709 IP (tos 0x0, ttl 57, id 18291, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x9c0e (c=
orrect), seq 166521:167969, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858255], length 1448
16:01:38.285833 IP (tos 0x0, ttl 57, id 18292, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x50ed (c=
orrect), seq 167969:169417, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858255], length 1448
16:01:38.285843 IP (tos 0x0, ttl 100, id 45963, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x7b13), ack 169417, win 6697, options [nop,nop,TS val 4294=
858306 ecr 86368737], length 0
16:01:38.285955 IP (tos 0x0, ttl 57, id 18293, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xe878 (c=
orrect), seq 169417:170865, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858255], length 1448
16:01:38.286078 IP (tos 0x0, ttl 57, id 18294, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x5431 (c=
orrect), seq 170865:172313, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858255], length 1448
16:01:38.286089 IP (tos 0x0, ttl 100, id 45964, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x6fc3), ack 172313, win 6697, options [nop,nop,TS val 4294=
858306 ecr 86368737], length 0
16:01:38.286202 IP (tos 0x0, ttl 57, id 18295, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [P.], cksum 0xc4a4 (=
correct), seq 172313:173761, ack 1, win 46, options [nop,nop,TS val 863=
68737 ecr 4294858255], length 1448
16:01:38.286324 IP (tos 0x0, ttl 57, id 18296, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x92a6 (c=
orrect), seq 173761:175209, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.286335 IP (tos 0x0, ttl 100, id 45965, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x63bd), ack 175209, win 6878, options [nop,nop,TS val 4294=
858307 ecr 86368737], length 0
16:01:38.286448 IP (tos 0x0, ttl 57, id 18297, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xb726 (c=
orrect), seq 175209:176657, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.286460 IP (tos 0x0, ttl 100, id 45966, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x5d60), ack 176657, win 7059, options [nop,nop,TS val 4294=
858307 ecr 86368737], length 0
16:01:38.286571 IP (tos 0x0, ttl 57, id 18298, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x1388 (c=
orrect), seq 176657:178105, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.286583 IP (tos 0x0, ttl 100, id 45967, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x5703), ack 178105, win 7240, options [nop,nop,TS val 4294=
858307 ecr 86368737], length 0
16:01:38.286694 IP (tos 0x0, ttl 57, id 18299, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x6a83 (c=
orrect), seq 178105:179553, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.286705 IP (tos 0x0, ttl 100, id 45968, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x50a6), ack 179553, win 7421, options [nop,nop,TS val 4294=
858307 ecr 86368737], length 0
16:01:38.286816 IP (tos 0x0, ttl 57, id 18300, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x0ecc (c=
orrect), seq 179553:181001, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.286827 IP (tos 0x0, ttl 100, id 45969, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x4a49), ack 181001, win 7602, options [nop,nop,TS val 4294=
858307 ecr 86368737], length 0
16:01:38.286944 IP (tos 0x0, ttl 57, id 18301, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x02fd (c=
orrect), seq 181001:182449, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.286955 IP (tos 0x0, ttl 100, id 45970, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x43ec), ack 182449, win 7783, options [nop,nop,TS val 4294=
858307 ecr 86368737], length 0
16:01:38.287063 IP (tos 0x0, ttl 57, id 18302, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x666e (c=
orrect), seq 182449:183897, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.287075 IP (tos 0x0, ttl 100, id 45971, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x3d8f), ack 183897, win 7964, options [nop,nop,TS val 4294=
858307 ecr 86368737], length 0
16:01:38.287187 IP (tos 0x0, ttl 57, id 18303, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xfc66 (c=
orrect), seq 183897:185345, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.287198 IP (tos 0x0, ttl 100, id 45972, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x3731), ack 185345, win 8145, options [nop,nop,TS val 4294=
858308 ecr 86368737], length 0
16:01:38.287309 IP (tos 0x0, ttl 57, id 18304, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xbd8c (c=
orrect), seq 185345:186793, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.287321 IP (tos 0x0, ttl 100, id 45973, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x30d4), ack 186793, win 8326, options [nop,nop,TS val 4294=
858308 ecr 86368737], length 0
16:01:38.287431 IP (tos 0x0, ttl 57, id 18305, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x0846 (c=
orrect), seq 186793:188241, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.287440 IP (tos 0x0, ttl 100, id 45974, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x2a77), ack 188241, win 8507, options [nop,nop,TS val 4294=
858308 ecr 86368737], length 0
16:01:38.287555 IP (tos 0x0, ttl 57, id 18306, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x49e9 (c=
orrect), seq 188241:189689, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.287565 IP (tos 0x0, ttl 100, id 45975, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x241a), ack 189689, win 8688, options [nop,nop,TS val 4294=
858308 ecr 86368737], length 0
16:01:38.287683 IP (tos 0x0, ttl 57, id 18307, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xc416 (c=
orrect), seq 189689:191137, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.287693 IP (tos 0x0, ttl 100, id 45976, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x1dbd), ack 191137, win 8869, options [nop,nop,TS val 4294=
858308 ecr 86368737], length 0
16:01:38.287801 IP (tos 0x0, ttl 57, id 18308, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xc8d3 (c=
orrect), seq 191137:192585, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.287813 IP (tos 0x0, ttl 100, id 45977, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x1760), ack 192585, win 9050, options [nop,nop,TS val 4294=
858308 ecr 86368737], length 0
16:01:38.287924 IP (tos 0x0, ttl 57, id 18309, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xd3d8 (c=
orrect), seq 192585:194033, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.287935 IP (tos 0x0, ttl 100, id 45978, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x1103), ack 194033, win 9231, options [nop,nop,TS val 4294=
858308 ecr 86368737], length 0
16:01:38.288047 IP (tos 0x0, ttl 57, id 18310, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x87af (c=
orrect), seq 194033:195481, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.288172 IP (tos 0x0, ttl 57, id 18311, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x5c33 (c=
orrect), seq 195481:196929, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.288182 IP (tos 0x0, ttl 100, id 45979, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x05b2), ack 196929, win 9231, options [nop,nop,TS val 4294=
858309 ecr 86368737], length 0
16:01:38.288293 IP (tos 0x0, ttl 57, id 18312, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xe297 (c=
orrect), seq 196929:198377, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.288416 IP (tos 0x0, ttl 57, id 18313, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x09d0 (c=
orrect), seq 198377:199825, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.288426 IP (tos 0x0, ttl 100, id 45980, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xfa61), ack 199825, win 9231, options [nop,nop,TS val 4294=
858309 ecr 86368737], length 0
16:01:38.288540 IP (tos 0x0, ttl 57, id 18314, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x51e0 (c=
orrect), seq 199825:201273, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.288662 IP (tos 0x0, ttl 57, id 18315, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x145e (c=
orrect), seq 201273:202721, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.288674 IP (tos 0x0, ttl 100, id 45981, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xef11), ack 202721, win 9231, options [nop,nop,TS val 4294=
858309 ecr 86368737], length 0
16:01:38.288786 IP (tos 0x0, ttl 57, id 18316, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x30f2 (c=
orrect), seq 202721:204169, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.288908 IP (tos 0x0, ttl 57, id 18317, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x7777 (c=
orrect), seq 204169:205617, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.288920 IP (tos 0x0, ttl 100, id 45982, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xe3c1), ack 205617, win 9231, options [nop,nop,TS val 4294=
858309 ecr 86368737], length 0
16:01:38.289031 IP (tos 0x0, ttl 57, id 18318, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xe665 (c=
orrect), seq 205617:207065, ack 1, win 46, options [nop,nop,TS val 8636=
8737 ecr 4294858256], length 1448
16:01:38.324047 IP (tos 0x0, ttl 57, id 18319, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x4a0b (c=
orrect), seq 207065:208513, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.324060 IP (tos 0x0, ttl 100, id 45983, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xd84e), ack 208513, win 9231, options [nop,nop,TS val 4294=
858344 ecr 86368737], length 0
16:01:38.324170 IP (tos 0x0, ttl 57, id 18320, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xe8d4 (c=
orrect), seq 208513:209961, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.324297 IP (tos 0x0, ttl 57, id 18321, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xffde (c=
orrect), seq 209961:211409, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.324310 IP (tos 0x0, ttl 100, id 45984, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xccf3), ack 211409, win 9231, options [nop,nop,TS val 4294=
858345 ecr 86368747], length 0
16:01:38.324416 IP (tos 0x0, ttl 57, id 18322, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x46aa (c=
orrect), seq 211409:212857, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.324539 IP (tos 0x0, ttl 57, id 18323, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x768a (c=
orrect), seq 212857:214305, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.324551 IP (tos 0x0, ttl 100, id 45985, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xc1a3), ack 214305, win 9231, options [nop,nop,TS val 4294=
858345 ecr 86368747], length 0
16:01:38.324662 IP (tos 0x0, ttl 57, id 18324, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x1c9a (c=
orrect), seq 214305:215753, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.324788 IP (tos 0x0, ttl 57, id 18325, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xb753 (c=
orrect), seq 215753:217201, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.324801 IP (tos 0x0, ttl 100, id 45986, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xb653), ack 217201, win 9231, options [nop,nop,TS val 4294=
858345 ecr 86368747], length 0
16:01:38.324908 IP (tos 0x0, ttl 57, id 18326, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x34ad (c=
orrect), seq 217201:218649, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.325031 IP (tos 0x0, ttl 57, id 18327, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xfb0f (c=
orrect), seq 218649:220097, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.325044 IP (tos 0x0, ttl 100, id 45987, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0xab03), ack 220097, win 9231, options [nop,nop,TS val 4294=
858345 ecr 86368747], length 0
16:01:38.325154 IP (tos 0x0, ttl 57, id 18328, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x4049 (c=
orrect), seq 220097:221545, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.325277 IP (tos 0x0, ttl 57, id 18329, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x5dba (c=
orrect), seq 221545:222993, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.325289 IP (tos 0x0, ttl 100, id 45988, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x9fb2), ack 222993, win 9231, options [nop,nop,TS val 4294=
858346 ecr 86368747], length 0
16:01:38.325401 IP (tos 0x0, ttl 57, id 18330, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xfde1 (c=
orrect), seq 222993:224441, ack 1, win 46, options [nop,nop,TS val 8636=
8747 ecr 4294858295], length 1448
16:01:38.333499 IP (tos 0x0, ttl 57, id 18331, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x64d5 (c=
orrect), seq 224441:225889, ack 1, win 46, options [nop,nop,TS val 8636=
8749 ecr 4294858304], length 1448
16:01:38.333509 IP (tos 0x0, ttl 100, id 45989, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x945a), ack 225889, win 9231, options [nop,nop,TS val 4294=
858354 ecr 86368747], length 0
16:01:38.333622 IP (tos 0x0, ttl 57, id 18332, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xddc2 (c=
orrect), seq 225889:227337, ack 1, win 46, options [nop,nop,TS val 8636=
8749 ecr 4294858304], length 1448
16:01:38.333749 IP (tos 0x0, ttl 57, id 18333, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x22b9 (c=
orrect), seq 227337:228785, ack 1, win 46, options [nop,nop,TS val 8636=
8749 ecr 4294858304], length 1448
16:01:38.333759 IP (tos 0x0, ttl 100, id 45990, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x8908), ack 228785, win 9231, options [nop,nop,TS val 4294=
858354 ecr 86368749], length 0
16:01:38.333867 IP (tos 0x0, ttl 57, id 18334, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0x52c1 (c=
orrect), seq 228785:230233, ack 1, win 46, options [nop,nop,TS val 8636=
8749 ecr 4294858304], length 1448
16:01:38.333991 IP (tos 0x0, ttl 57, id 18335, offset 0, flags [DF], pr=
oto TCP (6), length 1500)
    130.89.149.20.45565 > AA.BB.CC.XY.42171: Flags [.], cksum 0xb074 (c=
orrect), seq 230233:231681, ack 1, win 46, options [nop,nop,TS val 8636=
8749 ecr 4294858304], length 1448
16:01:38.334002 IP (tos 0x0, ttl 100, id 45991, offset 0, flags [DF], p=
roto TCP (6), length 52)
    AA.BB.CC.XY.42171 > 130.89.149.20.45565: Flags [.], cksum 0x1020 (i=
ncorrect -> 0x7db8), ack 231681, win 9231, options [nop,nop,TS val 4294=
858354 ecr 86368749], length 0
300 packets captured
301 packets received by filter
0 packets dropped by kernel
