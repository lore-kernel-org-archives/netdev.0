From: "R.Mielnik" <r.mielnik@rm-it.pl>
Subject: linux kernel and route mtu calculation
Date: Wed, 30 Dec 2015 14:00:26 +0100
Message-ID: <5683D56A.2030601@rm-it.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.punkt.pl ([213.218.124.66]:40559 "HELO mail.punkt.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754681AbbL3NHK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2015 08:07:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


debian, kernel 3.2.54/60/73. i'm using gre interfaces on top of ipsec=20
tunnels. these gre interfaces have mtu 1400 on my entire network.=20
normally i see this kind of tracepath output:

1?: [LOCALHOST]                                         pmtu 1500
  1:  10.xxx.101.1                                         13.625ms
  1:  10.xxx.101.1                                         13.178ms
  2:  10.xxx.101.1                                         13.973ms pmt=
u=20
1400
  2:  192.168.yyy.251                                      56.555ms
  3:  192.168.yyy.92                                      643.252ms
  4:  192.168.yyy.28                                      417.291ms
  5:  192.168.zzz.129                                     517.893ms rea=
ched

but for some reason i got one case when tracepath gives different resul=
t:

  1?: [LOCALHOST]                                         pmtu 1500
  1:  10.xxx.101.1                                         13.625ms
  1:  10.xxx.101.1                                         20.857ms
  2:  10.xxx.101.1                                         11.954ms pmt=
u=20
1400
  2:  192.168.yyy.251                                      46.456ms
  3:  192.168.yyy.251                                      45.563ms pmt=
u=20
1376
  3:  10.zzz.251.1                                         56.648ms
  4:  10.zzz.255.111                                       55.212ms rea=
ched

all gre interfaces on 192.168.yyy.251 have mtu 1400, all are configured=
=20
identically. the 10.zzz.251.1 router doesn't send any ICMP fragm needed=
=20
packets, gre interface of course with mtu 1400. 192.168.yyy.251=20
generates ICMP fragm needed but i have no clue why. ip route get=20
10.zzz.255.111 on 192.168.yyy.251 router shows:

10.zzz.255.111 from 10.xxx.101.253 tos lowdelay via 10.zzz.251.1 dev=20
GRE_OUTPUT_INTERFACE  src 192.168.yyy.251  mark 0x2071
     cache  expires 264sec ipid 0x607b mtu 1376 iif GRE_INPUT_INTERFACE

additionally from time to time (i suspect it depends on traffic) mtu of=
=20
the route changes and gets heavily lowered and for 10mins (mtu cache=20
expiry) i can't make any new connections that need bigger packets -- bu=
t=20
old established connections are working fine. so how the kernel=20
calculates mtu for routes? what else except mtu of outgoing interface i=
s=20
taking its part in pmtu calculation?




--=20
  ...  Rafa=C5=82 Mielnik
  ...  RM-IT Us=C5=82ugi Informatyczne
  ...  +48608025394
  ...  r.mielnik@rm-it.pl
