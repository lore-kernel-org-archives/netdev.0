From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Mon, 13 Feb 2012 23:44:16 +0100
Message-ID: <1329173056.2523.14.camel@edumazet-laptop>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <1329164293.2523.0.camel@edumazet-laptop>
	 <1329167638.2523.2.camel@edumazet-laptop>
	 <3490386.xy2kafBK9b@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64308 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064Ab2BMWoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 17:44:23 -0500
Received: by wics10 with SMTP id s10so3790588wic.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 14:44:21 -0800 (PST)
In-Reply-To: <3490386.xy2kafBK9b@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 f=C3=A9vrier 2012 =C3=A0 23:58 +0200, alekcejk@googlemail.c=
om a
=C3=A9crit :
> =D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=9F=D0=BE=D0=BD=D0=B5=D0=B4=D0=B5=D0=BB=D1=8C=D0=BD=D0=B8=D0=BA =
13 =D1=84=D0=B5=D0=B2=D1=80=D0=B0=D0=BB=D1=8F 2012 22:13:58 =D0=B2=D1=8B=
 =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=D0=B8:
> > Le lundi 13 f=C3=A9vrier 2012 =C3=A0 21:18 +0100, Eric Dumazet a =C3=
=A9crit :
> > > Could you post "netstat -s" result ?
> >=20
> > I should have said, please post "netstat -s" before/after a transfe=
rt,
> > and possibly "ifconfig eth0" results as well.
>=20
> Now only for 3.2.3 kernel (2.6.42.3-2.fc15.i686).
>=20
> Before downloading:
>=20
> ifconfig eth0:
>=20
> eth0      Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE =20
>           inet addr:AA.BB.CC.XY  Bcast:AA.BB.CC.255  Mask:255.255.255=
=2E0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:12332 errors:0 dropped:6 overruns:0 frame:0
>           TX packets:5239 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000=20
>           RX bytes:767595 (749.6 KiB)  TX bytes:315241 (307.8 KiB)
>           Interrupt:22 Base address:0xec00=20
>=20
> I should notice that dropped RX packets is very old bug=20
> not related to this problem  https://bugzilla.redhat.com/show_bug.cgi=
?id=3D709551
>=20

This is not a bug.

Previous kernels were not accounting for these dropped packets (unknown
protocol for example). But they really were dropped.


I wonder if the other side of your link believes link is in half duplex
mode... Could you please check ?


There are some glitches in the tcpdump :

> >=20
> > tcpdump -p -n -s 0 -i eth0 -c 300
>=20
>=20


> listening on eth0, link-type EN10MB (Ethernet), capture size 65535 by=
tes
> 23:43:47.613877 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [S], se=
q 1269831019, win 14600, options [mss 1460,sackOK,TS val 4294885194 ecr=
 0,nop,wscale 4], length 0
> 23:43:47.668519 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [S.], s=
eq 3225130008, ack 1269831020, win 5792, options [mss 1460,sackOK,TS va=
l 3722336136 ecr 4294885194,nop,wscale 7],=20
> length 0
> 23:43:47.668553 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [.], ac=
k 1, win 913, options [nop,nop,TS val 4294885249 ecr 3722336136], lengt=
h 0
> 23:43:56.139600 IP 46.237.89.73.3287 > AA.BB.CC.XY.445: Flags [S], se=
q 717230849, win 65535, options [mss 1460,nop,nop,sackOK], length 0
> 23:43:57.394960 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [P.], s=
eq 1:68, ack 1, win 46, options [nop,nop,TS val 3722340212 ecr 42948852=
49], length 67
> 23:43:57.394994 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [.], ac=
k 68, win 913, options [nop,nop,TS val 4294894975 ecr 3722340212], leng=
th 0
> 23:43:57.395082 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [P.], s=
eq 1:17, ack 68, win 913, options [nop,nop,TS val 4294894975 ecr 372234=
0212], length 16
> 23:43:57.449595 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [.], ac=
k 17, win 46, options [nop,nop,TS val 3722340235 ecr 4294894975], lengt=
h 0
> 23:43:57.453111 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [P.], s=
eq 68:143, ack 17, win 46, options [nop,nop,TS val 3722340237 ecr 42948=
94975], length 75
> 23:43:57.453149 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [P.], s=
eq 17:30, ack 143, win 913, options [nop,nop,TS val 4294895034 ecr 3722=
340237], length 13
> 23:43:57.513064 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [P.], s=
eq 143:166, ack 30, win 46, options [nop,nop,TS val 3722340262 ecr 4294=
895034], length 23
> 23:43:57.552139 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [.], ac=
k 166, win 913, options [nop,nop,TS val 4294895133 ecr 3722340262], len=
gth 0
> 23:43:57.606745 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [P.], s=
eq 166:393, ack 30, win 46, options [nop,nop,TS val 3722340301 ecr 4294=
895133], length 227
> 23:43:57.606756 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [.], ac=
k 393, win 980, options [nop,nop,TS val 4294895187 ecr 3722340301], len=
gth 0
> 23:43:57.606968 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [P.], s=
eq 30:36, ack 393, win 980, options [nop,nop,TS val 4294895187 ecr 3722=
340301], length 6
> 23:43:57.661548 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [P.], s=
eq 393:412, ack 36, win 46, options [nop,nop,TS val 3722340324 ecr 4294=
895187], length 19
> 23:43:57.661674 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [P.], s=
eq 36:41, ack 412, win 980, options [nop,nop,TS val 4294895242 ecr 3722=
340324], length 5
> 23:43:57.716303 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [P.], s=
eq 412:446, ack 41, win 46, options [nop,nop,TS val 3722340347 ecr 4294=
895242], length 34
> 23:43:57.716485 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [P.], s=
eq 41:49, ack 446, win 980, options [nop,nop,TS val 4294895297 ecr 3722=
340347], length 8
> 23:43:57.771261 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [P.], s=
eq 446:465, ack 49, win 46, options [nop,nop,TS val 3722340370 ecr 4294=
895297], length 19
> 23:43:57.771368 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [P.], s=
eq 49:87, ack 465, win 980, options [nop,nop,TS val 4294895352 ecr 3722=
340370], length 38
> 23:43:57.826141 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [P.], s=
eq 465:493, ack 87, win 46, options [nop,nop,TS val 3722340393 ecr 4294=
895352], length 28
> 23:43:57.826299 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [P.], s=
eq 87:130, ack 493, win 980, options [nop,nop,TS val 4294895407 ecr 372=
2340393], length 43
> 23:43:57.881034 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [P.], s=
eq 493:509, ack 130, win 46, options [nop,nop,TS val 3722340416 ecr 429=
4895407], length 16
> 23:43:57.881214 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [P.], s=
eq 130:136, ack 509, win 980, options [nop,nop,TS val 4294895462 ecr 37=
22340416], length 6
> 23:43:57.936081 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [P.], s=
eq 509:560, ack 136, win 46, options [nop,nop,TS val 3722340439 ecr 429=
4895462], length 51
> 23:43:57.936161 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [S],=
 seq 2087240368, win 14600, options [mss 1460,sackOK,TS val 4294895517 =
ecr 0,nop,wscale 4], length 0
> 23:43:57.975228 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [.], ac=
k 560, win 980, options [nop,nop,TS val 4294895556 ecr 3722340439], len=
gth 0
> 23:43:57.992393 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [S.]=
, seq 3469224966, ack 2087240369, win 5792, options [mss 1460,sackOK,TS=
 val 3722340463 ecr 4294895517,nop,wscale 7],=20
> length 0
> 23:43:57.992411 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 1, win 913, options [nop,nop,TS val 4294895573 ecr 3722340463], le=
ngth 0
> 23:43:57.992469 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [P.], s=
eq 136:179, ack 560, win 980, options [nop,nop,TS val 4294895573 ecr 37=
22340439], length 43
> 23:43:58.068808 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [.], ac=
k 179, win 46, options [nop,nop,TS val 3722340495 ecr 4294895573], leng=
th 0
> 23:43:59.118531 IP 46.237.89.73.3287 > AA.BB.CC.XY.445: Flags [S], se=
q 717230849, win 65535, options [mss 1460,nop,nop,sackOK], length 0
> 23:44:07.602080 IP 213.83.42.56.21 > AA.BB.CC.XY.51340: Flags [P.], s=
eq 560:661, ack 179, win 46, options [nop,nop,TS val 3722344490 ecr 429=
4895573], length 101
> 23:44:07.602111 IP AA.BB.CC.XY.51340 > 213.83.42.56.21: Flags [.], ac=
k 661, win 980, options [nop,nop,TS val 4294905182 ecr 3722344490], len=
gth 0
> 23:44:07.602298 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 1:1449, ack 1, win 46, options [nop,nop,TS val 3722344490 ecr 4294=
895573], length 1448
> 23:44:07.602313 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 1449, win 1094, options [nop,nop,TS val 4294905183 ecr 3722344490]=
, length 0
> 23:44:07.602410 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 1449:2897, ack 1, win 46, options [nop,nop,TS val 3722344490 ecr 4=
294895573], length 1448
> 23:44:07.602422 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 2897, win 1275, options [nop,nop,TS val 4294905183 ecr 3722344490]=
, length 0
> 23:44:07.658861 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 2897:4345, ack 1, win 46, options [nop,nop,TS val 3722344514 ecr 4=
294905183], length 1448
> 23:44:07.658872 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 4345, win 1456, options [nop,nop,TS val 4294905239 ecr 3722344514]=
, length 0
> 23:44:07.658985 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 4345:5793, ack 1, win 46, options [nop,nop,TS val 3722344514 ecr 4=
294905183], length 1448
> 23:44:07.658998 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 5793, win 1637, options [nop,nop,TS val 4294905239 ecr 3722344514]=
, length 0
> 23:44:07.659108 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 5793:7241, ack 1, win 46, options [nop,nop,TS val 3722344514 ecr 4=
294905183], length 1448
> 23:44:07.659119 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 7241, win 1818, options [nop,nop,TS val 4294905240 ecr 3722344514]=
, length 0
> 23:44:07.659231 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 7241:8689, ack 1, win 46, options [nop,nop,TS val 3722344514 ecr 4=
294905183], length 1448
> 23:44:07.659241 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 8689, win 1999, options [nop,nop,TS val 4294905240 ecr 3722344514]=
, length 0
> 23:44:07.715355 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 8689:10137, ack 1, win 46, options [nop,nop,TS val 3722344537 ecr =
4294905239], length 1448
> 23:44:07.715368 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 10137, win 2180, options [nop,nop,TS val 4294905296 ecr 3722344537=
], length 0
> 23:44:07.715674 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 10137:11585, ack 1, win 46, options [nop,nop,TS val 3722344537 ecr=
 4294905239], length 1448
> 23:44:07.715687 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 11585, win 2361, options [nop,nop,TS val 4294905296 ecr 3722344537=
], length 0
> 23:44:07.715797 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 11585:13033, ack 1, win 46, options [nop,nop,TS val 3722344537 ecr=
 4294905239], length 1448
> 23:44:07.715809 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 13033, win 2542, options [nop,nop,TS val 4294905296 ecr 3722344537=
], length 0
> 23:44:07.715919 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 13033:14481, ack 1, win 46, options [nop,nop,TS val 3722344537 ecr=
 4294905239], length 1448
> 23:44:07.715929 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 14481, win 2723, options [nop,nop,TS val 4294905296 ecr 3722344537=
], length 0
> 23:44:07.716048 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 14481:15929, ack 1, win 46, options [nop,nop,TS val 3722344537 ecr=
 4294905240], length 1448
> 23:44:07.716058 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 15929, win 2904, options [nop,nop,TS val 4294905296 ecr 3722344537=
], length 0
> 23:44:07.716165 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 15929:17377, ack 1, win 46, options [nop,nop,TS val 3722344537 ecr=
 4294905240], length 1448
> 23:44:07.716178 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 17377, win 3085, options [nop,nop,TS val 4294905297 ecr 3722344537=
], length 0
> 23:44:07.771895 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 17377:18825, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.771907 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 18825, win 3266, options [nop,nop,TS val 4294905352 ecr 3722344561=
], length 0
> 23:44:07.772019 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 18825:20273, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.772029 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 20273, win 3447, options [nop,nop,TS val 4294905352 ecr 3722344561=
], length 0
> 23:44:07.772150 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 20273:21721, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.772160 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 21721, win 3628, options [nop,nop,TS val 4294905353 ecr 3722344561=
], length 0
> 23:44:07.772266 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 21721:23169, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.772278 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 23169, win 3809, options [nop,nop,TS val 4294905353 ecr 3722344561=
], length 0
> 23:44:07.772388 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 23169:24617, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.772400 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 24617, win 3990, options [nop,nop,TS val 4294905353 ecr 3722344561=
], length 0
> 23:44:07.772511 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 24617:26065, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.772521 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 26065, win 3991, options [nop,nop,TS val 4294905353 ecr 3722344561=
], length 0
> 23:44:07.772637 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 26065:27513, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.772648 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 27513, win 3991, options [nop,nop,TS val 4294905353 ecr 3722344561=
], length 0
> 23:44:07.772757 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 27513:28961, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.772769 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 28961, win 3991, options [nop,nop,TS val 4294905353 ecr 3722344561=
], length 0
> 23:44:07.772880 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 28961:30409, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.772892 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 30409, win 3991, options [nop,nop,TS val 4294905353 ecr 3722344561=
], length 0
> 23:44:07.773003 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 30409:31857, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.773014 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 31857, win 3991, options [nop,nop,TS val 4294905353 ecr 3722344561=
], length 0
> 23:44:07.773131 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 31857:33305, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.773250 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 33305:34753, ack 1, win 46, options [nop,nop,TS val 3722344561 ecr=
 4294905296], length 1448
> 23:44:07.773262 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 34753, win 3991, options [nop,nop,TS val 4294905354 ecr 3722344561=
], length 0

~50 ms delay here from sender

> 23:44:07.828359 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 34753:36201, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905352], length 1448
> 23:44:07.828484 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 36201:37649, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905352], length 1448
> 23:44:07.828495 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 37649, win 3991, options [nop,nop,TS val 4294905409 ecr 3722344585=
], length 0
> 23:44:07.828611 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 37649:39097, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905352], length 1448
> 23:44:07.828729 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 39097:40545, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905352], length 1448
> 23:44:07.828741 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 40545, win 3991, options [nop,nop,TS val 4294905409 ecr 3722344585=
], length 0
> 23:44:07.828852 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 40545:41993, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.828975 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 41993:43441, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.828985 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 43441, win 3991, options [nop,nop,TS val 4294905409 ecr 3722344585=
], length 0
> 23:44:07.829100 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 43441:44889, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.829221 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 44889:46337, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.829233 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 46337, win 3991, options [nop,nop,TS val 4294905410 ecr 3722344585=
], length 0
> 23:44:07.829344 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 46337:47785, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.829468 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 47785:49233, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.829478 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 49233, win 3991, options [nop,nop,TS val 4294905410 ecr 3722344585=
], length 0
> 23:44:07.829595 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 49233:50681, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.829713 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 50681:52129, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.829725 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 52129, win 3991, options [nop,nop,TS val 4294905410 ecr 3722344585=
], length 0
> 23:44:07.829836 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 52129:53577, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.829959 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 53577:55025, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.829969 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 55025, win 3991, options [nop,nop,TS val 4294905410 ecr 3722344585=
], length 0
> 23:44:07.830091 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 55025:56473, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.830206 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 56473:57921, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.830216 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 57921, win 3991, options [nop,nop,TS val 4294905411 ecr 3722344585=
], length 0
> 23:44:07.830329 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 57921:59369, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.830452 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 59369:60817, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.830463 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 60817, win 3991, options [nop,nop,TS val 4294905411 ecr 3722344585=
], length 0
> 23:44:07.830578 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 60817:62265, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.830697 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 62265:63713, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.830708 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 63713, win 3991, options [nop,nop,TS val 4294905411 ecr 3722344585=
], length 0
> 23:44:07.830820 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 63713:65161, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.830943 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 65161:66609, ack 1, win 46, options [nop,nop,TS val 3722344585 ecr=
 4294905353], length 1448
> 23:44:07.830955 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 66609, win 3991, options [nop,nop,TS val 4294905411 ecr 3722344585=
], length 0

Here, ~50 ms delay from sender

> 23:44:07.885049 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 66609:68057, ack 1, win 46, options [nop,nop,TS val 3722344608 ecr=
 4294905409], length 1448
> 23:44:07.885171 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 68057:69505, ack 1, win 46, options [nop,nop,TS val 3722344608 ecr=
 4294905409], length 1448
> 23:44:07.885183 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 69505, win 3991, options [nop,nop,TS val 4294905466 ecr 3722344608=
], length 0
> 23:44:07.885298 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 69505:70953, ack 1, win 46, options [nop,nop,TS val 3722344608 ecr=
 4294905409], length 1448
> 23:44:07.885417 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 70953:72401, ack 1, win 46, options [nop,nop,TS val 3722344608 ecr=
 4294905409], length 1448
> 23:44:07.885429 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 72401, win 3991, options [nop,nop,TS val 4294905466 ecr 3722344608=
], length 0
> 23:44:07.885540 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 72401:73849, ack 1, win 46, options [nop,nop,TS val 3722344608 ecr=
 4294905409], length 1448
> 23:44:07.885663 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 73849:75297, ack 1, win 46, options [nop,nop,TS val 3722344608 ecr=
 4294905409], length 1448
> 23:44:07.885674 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 75297, win 3991, options [nop,nop,TS val 4294905466 ecr 3722344608=
], length 0
> 23:44:07.885787 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 75297:76745, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905409], length 1448
> 23:44:07.885909 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 76745:78193, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905409], length 1448
> 23:44:07.885921 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 78193, win 3991, options [nop,nop,TS val 4294905466 ecr 3722344609=
], length 0
> 23:44:07.886033 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 78193:79641, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905409], length 1448
> 23:44:07.886156 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 79641:81089, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905409], length 1448
> 23:44:07.886166 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 81089, win 3991, options [nop,nop,TS val 4294905467 ecr 3722344609=
], length 0
> 23:44:07.886279 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 81089:82537, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905409], length 1448
> 23:44:07.886402 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 82537:83985, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905409], length 1448
> 23:44:07.886414 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 83985, win 3991, options [nop,nop,TS val 4294905467 ecr 3722344609=
], length 0
> 23:44:07.886524 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 83985:85433, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905410], length 1448
> 23:44:07.886647 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 85433:86881, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905410], length 1448
> 23:44:07.886658 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 86881, win 3991, options [nop,nop,TS val 4294905467 ecr 3722344609=
], length 0
> 23:44:07.886771 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 86881:88329, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905410], length 1448
> 23:44:07.886894 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 88329:89777, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905410], length 1448
> 23:44:07.886905 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 89777, win 3991, options [nop,nop,TS val 4294905467 ecr 3722344609=
], length 0
> 23:44:07.887017 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 89777:91225, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905410], length 1448
> 23:44:07.887140 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 91225:92673, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905410], length 1448
> 23:44:07.887150 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 92673, win 3991, options [nop,nop,TS val 4294905468 ecr 3722344609=
], length 0
> 23:44:07.887263 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 92673:94121, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905410], length 1448
> 23:44:07.887386 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 94121:95569, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905410], length 1448
> 23:44:07.887398 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 95569, win 3991, options [nop,nop,TS val 4294905468 ecr 3722344609=
], length 0
> 23:44:07.887508 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 95569:97017, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905410], length 1448
> 23:44:07.887632 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 97017:98465, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905411], length 1448
> 23:44:07.887642 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 98465, win 3991, options [nop,nop,TS val 4294905468 ecr 3722344609=
], length 0
> 23:44:07.887760 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 98465:99913, ack 1, win 46, options [nop,nop,TS val 3722344609 ecr=
 4294905411], length 1448
> 23:44:07.887878 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 99913:101361, ack 1, win 46, options [nop,nop,TS val 3722344609 ec=
r 4294905411], length 1448
> 23:44:07.887889 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 101361, win 3991, options [nop,nop,TS val 4294905468 ecr 372234460=
9], length 0
> 23:44:07.888001 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 101361:102809, ack 1, win 46, options [nop,nop,TS val 3722344609 e=
cr 4294905411], length 1448
> 23:44:07.888012 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 102809, win 4187, options [nop,nop,TS val 4294905468 ecr 372234460=
9], length 0
> 23:44:07.888124 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 102809:104257, ack 1, win 46, options [nop,nop,TS val 3722344609 e=
cr 4294905411], length 1448
> 23:44:07.888135 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 104257, win 4368, options [nop,nop,TS val 4294905469 ecr 372234460=
9], length 0
> 23:44:07.888249 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 104257:105705, ack 1, win 46, options [nop,nop,TS val 3722344609 e=
cr 4294905411], length 1448
> 23:44:07.888261 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 105705, win 4549, options [nop,nop,TS val 4294905469 ecr 372234460=
9], length 0
> 23:44:07.888370 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 105705:107153, ack 1, win 46, options [nop,nop,TS val 3722344609 e=
cr 4294905411], length 1448
> 23:44:07.888382 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 107153, win 4730, options [nop,nop,TS val 4294905469 ecr 372234460=
9], length 0
> 23:44:07.888493 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 107153:108601, ack 1, win 46, options [nop,nop,TS val 3722344609 e=
cr 4294905411], length 1448
> 23:44:07.888504 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 108601, win 4911, options [nop,nop,TS val 4294905469 ecr 372234460=
9], length 0
> 23:44:07.888616 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 108601:110049, ack 1, win 46, options [nop,nop,TS val 3722344609 e=
cr 4294905411], length 1448
> 23:44:07.888626 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 110049, win 5092, options [nop,nop,TS val 4294905469 ecr 372234460=
9], length 0
> 23:44:07.888740 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 110049:111497, ack 1, win 46, options [nop,nop,TS val 3722344609 e=
cr 4294905411], length 1448
> 23:44:07.888752 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 111497, win 5273, options [nop,nop,TS val 4294905469 ecr 372234460=
9], length 0
> 23:44:07.888862 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 111497:112945, ack 1, win 46, options [nop,nop,TS val 3722344609 e=
cr 4294905411], length 1448
> 23:44:07.888874 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 112945, win 5454, options [nop,nop,TS val 4294905469 ecr 372234460=
9], length 0
> 23:44:07.888986 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 112945:114393, ack 1, win 46, options [nop,nop,TS val 3722344609 e=
cr 4294905411], length 1448
> 23:44:07.888996 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 114393, win 5635, options [nop,nop,TS val 4294905469 ecr 372234460=
9], length 0

Here , 50ms delay from sender

> 23:44:07.941738 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 114393:115841, ack 1, win 46, options [nop,nop,TS val 3722344632 e=
cr 4294905466], length 1448
> 23:44:07.941749 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 115841, win 5816, options [nop,nop,TS val 4294905522 ecr 372234463=
2], length 0
> 23:44:07.941861 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 115841:117289, ack 1, win 46, options [nop,nop,TS val 3722344632 e=
cr 4294905466], length 1448
> 23:44:07.941873 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 117289, win 5997, options [nop,nop,TS val 4294905522 ecr 372234463=
2], length 0
> 23:44:07.941985 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 117289:118737, ack 1, win 46, options [nop,nop,TS val 3722344632 e=
cr 4294905466], length 1448
> 23:44:07.941995 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 118737, win 6178, options [nop,nop,TS val 4294905522 ecr 372234463=
2], length 0
> 23:44:07.942108 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 118737:120185, ack 1, win 46, options [nop,nop,TS val 3722344632 e=
cr 4294905466], length 1448
> 23:44:07.942118 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 120185, win 6359, options [nop,nop,TS val 4294905523 ecr 372234463=
2], length 0
> 23:44:07.942231 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 120185:121633, ack 1, win 46, options [nop,nop,TS val 3722344632 e=
cr 4294905466], length 1448
> 23:44:07.942241 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 121633, win 6540, options [nop,nop,TS val 4294905523 ecr 372234463=
2], length 0
> 23:44:07.942353 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 121633:123081, ack 1, win 46, options [nop,nop,TS val 3722344632 e=
cr 4294905466], length 1448
> 23:44:07.942365 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 123081, win 6721, options [nop,nop,TS val 4294905523 ecr 372234463=
2], length 0
> 23:44:07.942476 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [P.]=
, seq 123081:124529, ack 1, win 46, options [nop,nop,TS val 3722344632 =
ecr 4294905466], length 1448
> 23:44:07.942488 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 124529, win 6902, options [nop,nop,TS val 4294905523 ecr 372234463=
2], length 0
> 23:44:07.942600 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 124529:125977, ack 1, win 46, options [nop,nop,TS val 3722344632 e=
cr 4294905466], length 1448
> 23:44:07.942610 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 125977, win 7083, options [nop,nop,TS val 4294905523 ecr 372234463=
2], length 0
> 23:44:07.942722 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 125977:127425, ack 1, win 46, options [nop,nop,TS val 3722344632 e=
cr 4294905466], length 1448
> 23:44:07.942733 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 127425, win 7264, options [nop,nop,TS val 4294905523 ecr 372234463=
2], length 0
> 23:44:07.942845 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 127425:128873, ack 1, win 46, options [nop,nop,TS val 3722344632 e=
cr 4294905466], length 1448
> 23:44:07.942857 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 128873, win 7445, options [nop,nop,TS val 4294905523 ecr 372234463=
2], length 0
> 23:44:07.942968 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 128873:130321, ack 1, win 46, options [nop,nop,TS val 3722344632 e=
cr 4294905466], length 1448
> 23:44:07.942980 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 130321, win 7626, options [nop,nop,TS val 4294905523 ecr 372234463=
2], length 0
> 23:44:07.943093 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 130321:131769, ack 1, win 46, options [nop,nop,TS val 3722344632 e=
cr 4294905466], length 1448
> 23:44:07.943103 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 131769, win 7807, options [nop,nop,TS val 4294905524 ecr 372234463=
2], length 0
> 23:44:07.943215 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 131769:133217, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.943225 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 133217, win 7988, options [nop,nop,TS val 4294905524 ecr 372234463=
3], length 0
> 23:44:07.943338 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 133217:134665, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.943350 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 134665, win 8145, options [nop,nop,TS val 4294905524 ecr 372234463=
3], length 0
> 23:44:07.943461 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 134665:136113, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.943584 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 136113:137561, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.943594 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 137561, win 8145, options [nop,nop,TS val 4294905524 ecr 372234463=
3], length 0
> 23:44:07.943707 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 137561:139009, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.943830 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 139009:140457, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.943842 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 140457, win 8145, options [nop,nop,TS val 4294905524 ecr 372234463=
3], length 0
> 23:44:07.943953 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 140457:141905, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.944076 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 141905:143353, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.944085 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 143353, win 8145, options [nop,nop,TS val 4294905524 ecr 372234463=
3], length 0
> 23:44:07.944206 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 143353:144801, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.944329 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 144801:146249, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.944341 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 146249, win 8145, options [nop,nop,TS val 4294905525 ecr 372234463=
3], length 0
> 23:44:07.944452 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 146249:147697, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.944575 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 147697:149145, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.944585 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 149145, win 8145, options [nop,nop,TS val 4294905525 ecr 372234463=
3], length 0
> 23:44:07.944698 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 149145:150593, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.944821 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 150593:152041, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.944832 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 152041, win 8145, options [nop,nop,TS val 4294905525 ecr 372234463=
3], length 0
> 23:44:07.944945 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 152041:153489, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905467], length 1448
> 23:44:07.945067 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 153489:154937, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905468], length 1448
> 23:44:07.945077 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 154937, win 8145, options [nop,nop,TS val 4294905525 ecr 372234463=
3], length 0
> 23:44:07.945190 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 154937:156385, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905468], length 1448
> 23:44:07.945313 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 156385:157833, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905468], length 1448
> 23:44:07.945325 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 157833, win 8145, options [nop,nop,TS val 4294905526 ecr 372234463=
3], length 0
> 23:44:07.945436 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 157833:159281, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905468], length 1448
> 23:44:07.945560 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 159281:160729, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905468], length 1448
> 23:44:07.945570 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 160729, win 8145, options [nop,nop,TS val 4294905526 ecr 372234463=
3], length 0
> 23:44:07.945682 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 160729:162177, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905468], length 1448
> 23:44:07.945805 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 162177:163625, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905468], length 1448
> 23:44:07.945817 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 163625, win 8145, options [nop,nop,TS val 4294905526 ecr 372234463=
3], length 0
> 23:44:07.945929 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 163625:165073, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905468], length 1448
> 23:44:07.946052 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 165073:166521, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905468], length 1448
> 23:44:07.946062 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 166521, win 8145, options [nop,nop,TS val 4294905526 ecr 372234463=
3], length 0
> 23:44:07.946175 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 166521:167969, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905468], length 1448
> 23:44:07.946298 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 167969:169417, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905468], length 1448
> 23:44:07.946310 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 169417, win 8145, options [nop,nop,TS val 4294905527 ecr 372234463=
3], length 0
> 23:44:07.946421 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 169417:170865, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905469], length 1448
> 23:44:07.946544 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 170865:172313, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905469], length 1448
> 23:44:07.946555 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 172313, win 8326, options [nop,nop,TS val 4294905527 ecr 372234463=
3], length 0
> 23:44:07.946667 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 172313:173761, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905469], length 1448
> 23:44:07.946678 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 173761, win 8507, options [nop,nop,TS val 4294905527 ecr 372234463=
3], length 0
> 23:44:07.946789 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 173761:175209, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905469], length 1448
> 23:44:07.946801 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 175209, win 8688, options [nop,nop,TS val 4294905527 ecr 372234463=
3], length 0
> 23:44:07.946913 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 175209:176657, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905469], length 1448
> 23:44:07.947036 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 176657:178105, ack 1, win 46, options [nop,nop,TS val 3722344633 e=
cr 4294905469], length 1448
> 23:44:07.947046 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 178105, win 8688, options [nop,nop,TS val 4294905527 ecr 372234463=
3], length 0
> 23:44:07.947159 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 178105:179553, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448
> 23:44:07.947283 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 179553:181001, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448
> 23:44:07.947295 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 181001, win 8688, options [nop,nop,TS val 4294905528 ecr 372234463=
4], length 0
> 23:44:07.947405 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 181001:182449, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448
> 23:44:07.947528 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 182449:183897, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448
> 23:44:07.947539 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 183897, win 8688, options [nop,nop,TS val 4294905528 ecr 372234463=
4], length 0
> 23:44:07.947651 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 183897:185345, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448
> 23:44:07.947774 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 185345:186793, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448
> 23:44:07.947786 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 186793, win 8688, options [nop,nop,TS val 4294905528 ecr 372234463=
4], length 0
> 23:44:07.947897 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [P.]=
, seq 186793:188241, ack 1, win 46, options [nop,nop,TS val 3722344634 =
ecr 4294905469], length 1448
> 23:44:07.948020 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 188241:189689, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448
> 23:44:07.948030 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 189689, win 8688, options [nop,nop,TS val 4294905528 ecr 372234463=
4], length 0
> 23:44:07.948143 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 189689:191137, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448
> 23:44:07.948267 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 191137:192585, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448
> 23:44:07.948279 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 192585, win 8688, options [nop,nop,TS val 4294905529 ecr 372234463=
4], length 0
> 23:44:07.948389 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 192585:194033, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448
> 23:44:07.948512 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 194033:195481, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448
> 23:44:07.948523 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 195481, win 8688, options [nop,nop,TS val 4294905529 ecr 372234463=
4], length 0
> 23:44:07.948635 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 195481:196929, ack 1, win 46, options [nop,nop,TS val 3722344634 e=
cr 4294905469], length 1448

~40 ms delay (we lost a frame and send our delack)

> 23:44:07.988227 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 196929, win 8688, options [nop,nop,TS val 4294905569 ecr 372234463=
4], length 0
> 23:44:07.998428 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 196929:198377, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905522], length 1448
> 23:44:07.998552 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 198377:199825, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905522], length 1448
> 23:44:07.998564 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 199825, win 8688, options [nop,nop,TS val 4294905579 ecr 372234465=
6], length 0
> 23:44:07.998674 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 199825:201273, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905522], length 1448
> 23:44:07.998798 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 201273:202721, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905522], length 1448
> 23:44:07.998809 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 202721, win 8688, options [nop,nop,TS val 4294905579 ecr 372234465=
6], length 0
> 23:44:07.998920 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 202721:204169, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:07.999043 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 204169:205617, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:07.999055 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 205617, win 8688, options [nop,nop,TS val 4294905579 ecr 372234465=
6], length 0
> 23:44:07.999167 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 205617:207065, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:07.999296 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 207065:208513, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:07.999307 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 208513, win 8688, options [nop,nop,TS val 4294905580 ecr 372234465=
6], length 0
> 23:44:07.999433 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 208513:209961, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:07.999556 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 209961:211409, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:07.999568 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 211409, win 8688, options [nop,nop,TS val 4294905580 ecr 372234465=
6], length 0
> 23:44:07.999681 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 211409:212857, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:07.999802 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 212857:214305, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:07.999812 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 214305, win 8688, options [nop,nop,TS val 4294905580 ecr 372234465=
6], length 0
> 23:44:07.999924 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 214305:215753, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:08.000048 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 215753:217201, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:08.000060 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 217201, win 8688, options [nop,nop,TS val 4294905580 ecr 372234465=
6], length 0
> 23:44:08.000171 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 217201:218649, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:08.000294 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 218649:220097, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:08.000304 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 220097, win 8688, options [nop,nop,TS val 4294905581 ecr 372234465=
6], length 0
> 23:44:08.000417 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 220097:221545, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:08.000540 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 221545:222993, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:08.000552 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 222993, win 8688, options [nop,nop,TS val 4294905581 ecr 372234465=
6], length 0
> 23:44:08.000663 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 222993:224441, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:08.000786 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 224441:225889, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905523], length 1448
> 23:44:08.000797 IP AA.BB.CC.XY.44100 > 213.83.42.56.55777: Flags [.],=
 ack 225889, win 8688, options [nop,nop,TS val 4294905581 ecr 372234465=
6], length 0
> 23:44:08.000909 IP 213.83.42.56.55777 > AA.BB.CC.XY.44100: Flags [.],=
 seq 225889:227337, ack 1, win 46, options [nop,nop,TS val 3722344656 e=
cr 4294905524], length 1448
> 300 packets captured
> 300 packets received by filter
> 0 packets dropped by kernel
