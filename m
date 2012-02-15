From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x
 kernels
Date: Wed, 15 Feb 2012 14:49:45 +0100
Message-ID: <1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <5781419.24ZaHfTAxC@localhost.localdomain>
	 <1329280993.2555.21.camel@edumazet-laptop>
	 <4249109.nLB9JCi9YF@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:37627 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706Ab2BONtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 08:49:49 -0500
Received: by wics10 with SMTP id s10so523383wic.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 05:49:48 -0800 (PST)
In-Reply-To: <4249109.nLB9JCi9YF@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 05:44 -0800, alekcejk@googlemai=
l.com a
=C3=A9crit :
> =D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=A1=D1=80=D0=B5=D0=B4=D0=B0 15 =D1=84=D0=B5=D0=B2=D1=80=D0=B0=D0=
=BB=D1=8F 2012 05:43:13 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=
=D0=BB=D0=B8:
> > OK thanks, nothing seems wrong on receiver side.
> >=20
> > Could you try to force ECN enabled flows and send tcpdump, to check=
 if
> > we receive retransmits ?
> >=20
> > echo 1 >/proc/sys/net/ipv4/tcp_ecn
> 2 was there before I did it.
>=20
>=20
> > And check tcp can engage ECN : tcpdump SYN/SYNACK should look like:
> >=20
> > 05:41:17.943538 IP 192.168.1.97.45986 > 68.232.35.119.80: Flags [SE=
W],
> > seq 2109565072, win 14600, options [mss 1460,sackOK,TS val 8295492 =
ecr
> > 0,nop,wscale 6], length 0
> >=20
> > 05:41:17.980619 IP 68.232.35.119.80 > 192.168.1.97.45986: Flags [S.=
E],
> > seq 2519424885, ack 2109565073, win 14600, options [mss
> > 1452,nop,nop,sackOK,nop,wscale 6], length 0
>=20
> tcpdump: verbose output suppressed, use -v or -vv for full protocol d=
ecode
> listening on eth0, link-type EN10MB (Ethernet), capture size 65535 by=
tes
> 15:21:20.799077 IP AA.BB.CC.XY.55374 > 213.83.42.56.21: Flags [SEW], =
seq 1233000896, win 14600, options [mss 1460,sackOK,TS val 764819 ecr 0=
,nop,wscale 4], length 0
> 15:21:20.853575 IP 213.83.42.56.21 > AA.BB.CC.XY.55374: Flags [S.], s=
eq 3046667726, ack 1233000897, win 5792, options [mss 1460,sackOK,TS va=
l 3782118833 ecr 764819,nop,wscale 7], length=20
> 0

> 15:21:21.450884 IP AA.BB.CC.XY.53691 > 213.83.42.56.36139: Flags [SEW=
], seq 2740127335, win 14600, options [mss 1460,sackOK,TS val 765471 ec=
r 0,nop,wscale 4], length 0
> 15:21:21.505467 IP 213.83.42.56.36139 > AA.BB.CC.XY.53691: Flags [S.]=
, seq 3050262605, ack 2740127336, win 5792, options [mss 1460,sackOK,TS=
 val 3782119106 ecr 765471,nop,wscale 7],=20
> length 0


Unfortunately remote server doesnt negotiate ECN (we dont see E flag in
the SYNACK frame)

Try to find another one, and check SYNACK looks like : Flags [S.E]
