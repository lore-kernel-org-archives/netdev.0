From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x
 kernels
Date: Wed, 15 Feb 2012 14:53:13 +0100
Message-ID: <1329313993.2437.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <5781419.24ZaHfTAxC@localhost.localdomain>
	 <1329280993.2555.21.camel@edumazet-laptop>
	 <4249109.nLB9JCi9YF@localhost.localdomain>
	 <1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46140 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758884Ab2BONxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 08:53:19 -0500
Received: by wgbdt10 with SMTP id dt10so956482wgb.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 05:53:18 -0800 (PST)
In-Reply-To: <1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 14:49 +0100, Eric Dumazet a =C3=
=A9crit :

>=20
> Unfortunately remote server doesnt negotiate ECN (we dont see E flag =
in
> the SYNACK frame)
>=20
> Try to find another one, and check SYNACK looks like : Flags [S.E]
>=20
>=20

If you find one, please add -v option to tcpdump so that we can see
ECT(0) code points in traces:

# tcpdump -p -n -s 0 -v -i eth3 host 192.168.20.110 -c 100
tcpdump: listening on eth3, link-type EN10MB (Ethernet), capture size 6=
5535 bytes
14:52:05.859079 IP (tos 0x0, ttl 64, id 56260, offset 0, flags [DF], pr=
oto TCP (6), length 60)
    192.168.20.110.47146 > 192.168.20.108.12865: Flags [SEW], cksum 0xd=
b99 (correct), seq 3163559948, win 14600, options [mss 1460,sackOK,TS v=
al 94487496 ecr 0,nop,wscale 8], length 0
14:52:05.859092 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto =
TCP (6), length 60)
    192.168.20.108.12865 > 192.168.20.110.47146: Flags [S.E], cksum 0xa=
a59 (incorrect -> 0x8fae), seq 3902753423, ack 3163559949, win 14480, o=
ptions [mss 1460,sackOK,TS val 79566055 ecr 94487496,nop,wscale 6], len=
gth 0
14:52:05.859172 IP (tos 0x0, ttl 64, id 56261, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.110.47146 > 192.168.20.108.12865: Flags [.], cksum 0xf70=
f (correct), ack 1, win 58, options [nop,nop,TS val 94487496 ecr 795660=
55], length 0
14:52:05.859218 IP (tos 0x2,ECT(0), ttl 64, id 56262, offset 0, flags [=
DF], proto TCP (6), length 708)
    192.168.20.110.47146 > 192.168.20.108.12865: Flags [P.], cksum 0xf2=
1f (correct), seq 1:657, ack 1, win 58, options [nop,nop,TS val 9448749=
6 ecr 79566055], length 656
14:52:05.859379 IP (tos 0x0, ttl 64, id 24183, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.108.12865 > 192.168.20.110.47146: Flags [.], cksum 0xaa5=
1 (incorrect -> 0xf3c2), ack 657, win 247, options [nop,nop,TS val 7956=
6055 ecr 94487496], length 0
14:52:05.859414 IP (tos 0x2,ECT(0), ttl 64, id 24184, offset 0, flags [=
DF], proto TCP (6), length 708)
    192.168.20.108.12865 > 192.168.20.110.47146: Flags [P.], cksum 0xac=
e1 (incorrect -> 0x0527), seq 1:657, ack 657, win 247, options [nop,nop=
,TS val 79566055 ecr 94487496], length 656
14:52:05.859519 IP (tos 0x0, ttl 64, id 56263, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.110.47146 > 192.168.20.108.12865: Flags [.], cksum 0xf1e=
9 (correct), ack 657, win 63, options [nop,nop,TS val 94487497 ecr 7956=
6055], length 0
14:52:05.859890 IP (tos 0x2,ECT(0), ttl 64, id 56264, offset 0, flags [=
DF], proto TCP (6), length 708)
    192.168.20.110.47146 > 192.168.20.108.12865: Flags [P.], cksum 0x6b=
99 (correct), seq 657:1313, ack 657, win 63, options [nop,nop,TS val 94=
487497 ecr 79566055], length 656
14:52:05.864923 IP (tos 0x2,ECT(0), ttl 64, id 24185, offset 0, flags [=
DF], proto TCP (6), length 708)
    192.168.20.108.12865 > 192.168.20.110.47146: Flags [P.], cksum 0xac=
e1 (incorrect -> 0x6a91), seq 657:1313, ack 1313, win 268, options [nop=
,nop,TS val 79566060 ecr 94487497], length 656
14:52:05.865046 IP (tos 0x0, ttl 64, id 56385, offset 0, flags [DF], pr=
oto TCP (6), length 60)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [SEW], cksum 0x3=
a0a (correct), seq 4121763727, win 14600, options [mss 1460,sackOK,TS v=
al 94487502 ecr 0,nop,wscale 8], length 0
14:52:05.865053 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto =
TCP (6), length 60)
    192.168.20.108.51265 > 192.168.20.110.33555: Flags [S.E], cksum 0xa=
a59 (incorrect -> 0x3a75), seq 2704557470, ack 4121763728, win 14480, o=
ptions [mss 1460,sackOK,TS val 79566061 ecr 94487502,nop,wscale 6], len=
gth 0
14:52:05.865129 IP (tos 0x0, ttl 64, id 56386, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0xa1d=
6 (correct), ack 1, win 58, options [nop,nop,TS val 94487502 ecr 795660=
61], length 0
14:52:05.865182 IP (tos 0x2,ECT(0), ttl 64, id 56387, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x62c=
b (correct), seq 1:1449, ack 1, win 58, options [nop,nop,TS val 9448750=
2 ecr 79566061], length 1448
14:52:05.865205 IP (tos 0x2,ECT(0), ttl 64, id 56388, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x5d2=
3 (correct), seq 1449:2897, ack 1, win 58, options [nop,nop,TS val 9448=
7502 ecr 79566061], length 1448
14:52:05.865230 IP (tos 0x2,ECT(0), ttl 64, id 56389, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x577=
b (correct), seq 2897:4345, ack 1, win 58, options [nop,nop,TS val 9448=
7502 ecr 79566061], length 1448
14:52:05.865233 IP (tos 0x2,ECT(0), ttl 64, id 56390, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x51d=
3 (correct), seq 4345:5793, ack 1, win 58, options [nop,nop,TS val 9448=
7502 ecr 79566061], length 1448
14:52:05.865254 IP (tos 0x2,ECT(0), ttl 64, id 56391, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x4c2=
b (correct), seq 5793:7241, ack 1, win 58, options [nop,nop,TS val 9448=
7502 ecr 79566061], length 1448
14:52:05.865257 IP (tos 0x2,ECT(0), ttl 64, id 56392, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x468=
3 (correct), seq 7241:8689, ack 1, win 58, options [nop,nop,TS val 9448=
7502 ecr 79566061], length 1448
14:52:05.865278 IP (tos 0x2,ECT(0), ttl 64, id 56393, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x40d=
b (correct), seq 8689:10137, ack 1, win 58, options [nop,nop,TS val 944=
87502 ecr 79566061], length 1448
14:52:05.865281 IP (tos 0x2,ECT(0), ttl 64, id 56394, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x3b3=
3 (correct), seq 10137:11585, ack 1, win 58, options [nop,nop,TS val 94=
487502 ecr 79566061], length 1448
14:52:05.865301 IP (tos 0x2,ECT(0), ttl 64, id 56395, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x358=
b (correct), seq 11585:13033, ack 1, win 58, options [nop,nop,TS val 94=
487502 ecr 79566061], length 1448
14:52:05.865305 IP (tos 0x2,ECT(0), ttl 64, id 56396, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [P.], cksum 0x2f=
db (correct), seq 13033:14481, ack 1, win 58, options [nop,nop,TS val 9=
4487502 ecr 79566061], length 1448
14:52:05.865349 IP (tos 0x0, ttl 64, id 20850, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.108.51265 > 192.168.20.110.33555: Flags [.], cksum 0xaa5=
1 (incorrect -> 0x9b58), ack 1449, win 272, options [nop,nop,TS val 795=
66061 ecr 94487502], length 0
14:52:05.865473 IP (tos 0x2,ECT(0), ttl 64, id 56397, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x2a3=
a (correct), seq 14481:15929, ack 1, win 58, options [nop,nop,TS val 94=
487503 ecr 79566061], length 1448
14:52:05.865508 IP (tos 0x0, ttl 64, id 20851, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.108.51265 > 192.168.20.110.33555: Flags [.], cksum 0xaa5=
1 (incorrect -> 0x9583), ack 2897, win 317, options [nop,nop,TS val 795=
66061 ecr 94487502], length 0
14:52:05.865668 IP (tos 0x0, ttl 64, id 20852, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.108.51265 > 192.168.20.110.33555: Flags [.], cksum 0xaa5=
1 (incorrect -> 0x8fae), ack 4345, win 362, options [nop,nop,TS val 795=
66061 ecr 94487502], length 0
14:52:05.865827 IP (tos 0x0, ttl 64, id 20853, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.108.51265 > 192.168.20.110.33555: Flags [.], cksum 0xaa5=
1 (incorrect -> 0x89d8), ack 5793, win 408, options [nop,nop,TS val 795=
66061 ecr 94487502], length 0
14:52:05.865990 IP (tos 0x0, ttl 64, id 20854, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.108.51265 > 192.168.20.110.33555: Flags [.], cksum 0xaa5=
1 (incorrect -> 0x8402), ack 7241, win 453, options [nop,nop,TS val 795=
66062 ecr 94487502], length 0
14:52:05.866111 IP (tos 0x2,ECT(0), ttl 64, id 56398, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x249=
1 (correct), seq 15929:17377, ack 1, win 58, options [nop,nop,TS val 94=
487503 ecr 79566062], length 1448
14:52:05.866135 IP (tos 0x2,ECT(0), ttl 64, id 56399, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x1ee=
9 (correct), seq 17377:18825, ack 1, win 58, options [nop,nop,TS val 94=
487503 ecr 79566062], length 1448
14:52:05.866152 IP (tos 0x0, ttl 64, id 20855, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.108.51265 > 192.168.20.110.33555: Flags [.], cksum 0xaa5=
1 (incorrect -> 0x7e2d), ack 8689, win 498, options [nop,nop,TS val 795=
66062 ecr 94487502], length 0
14:52:05.866158 IP (tos 0x2,ECT(0), ttl 64, id 56400, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x194=
1 (correct), seq 18825:20273, ack 1, win 58, options [nop,nop,TS val 94=
487503 ecr 79566062], length 1448
14:52:05.866163 IP (tos 0x2,ECT(0), ttl 64, id 56401, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x139=
9 (correct), seq 20273:21721, ack 1, win 58, options [nop,nop,TS val 94=
487503 ecr 79566062], length 1448
14:52:05.866310 IP (tos 0x0, ttl 64, id 20856, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.108.51265 > 192.168.20.110.33555: Flags [.], cksum 0xaa5=
1 (incorrect -> 0x7858), ack 10137, win 543, options [nop,nop,TS val 79=
566062 ecr 94487502], length 0
14:52:05.866432 IP (tos 0x2,ECT(0), ttl 64, id 56402, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [.], cksum 0x0df=
0 (correct), seq 21721:23169, ack 1, win 58, options [nop,nop,TS val 94=
487504 ecr 79566062], length 1448
14:52:05.866463 IP (tos 0x2,ECT(0), ttl 64, id 56403, offset 0, flags [=
DF], proto TCP (6), length 1500)
    192.168.20.110.33555 > 192.168.20.108.51265: Flags [P.], cksum 0x08=
40 (correct), seq 23169:24617, ack 1, win 58, options [nop,nop,TS val 9=
4487504 ecr 79566062], length 1448
14:52:05.866471 IP (tos 0x0, ttl 64, id 20857, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.108.51265 > 192.168.20.110.33555: Flags [.], cksum 0xaa5=
1 (incorrect -> 0x7282), ack 11585, win 589, options [nop,nop,TS val 79=
566062 ecr 94487502], length 0
14:52:05.866629 IP (tos 0x0, ttl 64, id 20858, offset 0, flags [DF], pr=
oto TCP (6), length 52)
    192.168.20.108.51265 > 192.168.20.110.33555: Flags [.], cksum 0xaa5=
1 (incorrect -> 0x6cad), ack 13033, win 634, options [nop,nop,TS val 79=
566062 ecr 94487502], length 0
