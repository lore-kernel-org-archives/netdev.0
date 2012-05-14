From: Marco Berizzi <pupilla@hotmail.com>
Subject: =?windows-1256?Q?1500bytes_?= =?windows-1256?Q?packets_co?=
 =?windows-1256?Q?ming_out_f?= =?windows-1256?Q?rom_ipsec_?=
 =?windows-1256?Q?tunnel=FE?=
Date: Mon, 14 May 2012 11:51:25 +0200
Message-ID: <DUB108-W48B5A0B2CEAB56CC687AC6B21A0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1256
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc1-s32.dub0.hotmail.com ([157.55.0.231]:46573 "EHLO
	dub0-omc1-s32.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755179Ab2ENJv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 05:51:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Folks,

I'm running a linux box (3.3.5) as
an ipsec gateway/firewall. The are
some sporadic network connectivity
problems with some of our network
clients.

Here is a tcpdump capture taken
on the ipsec gateway:
=A0
12:26:20.889697 IP (tos 0x0, ttl 127, id 20667, offset 0, flags [DF], p=
roto: TCP (6), length: 52) 172.22.1.129.49772 > 10.16.178.113.80: S, ck=
sum 0x03cc (correct), 1431292197:1431292197(0) win 8192 <mss 1460,nop,w=
scale 2,nop,nop,sackOK>
12:26:20.932333 IP (tos 0x20, ttl 119, id 29189, offset 0, flags [none]=
, proto: TCP (6), length: 52) 10.16.178.113.80 > 172.16.128.1.49772: S,=
 cksum 0xacd3 (correct), 585947793:585947793(0) ack 1431292198 win 6424=
0 <mss 1460,nop,wscale 0,nop,nop,sackOK>
12:26:20.963983 IP (tos 0x0, ttl 127, id 20668, offset 0, flags [DF], p=
roto: TCP (6), length: 40) 172.22.1.129.49772 > 10.16.178.113.80: ., ck=
sum 0x25e2 (correct), ack 585947794 win 16680
12:26:20.972126 IP (tos 0x0, ttl 127, id 20669, offset 0, flags [DF], p=
roto: TCP (6), length: 1430) 172.22.1.129.49772 > 10.16.178.113.80: . 0=
:1390(1390) ack 1 win 16680
12:26:20.972563 IP (tos 0x0, ttl 127, id 20670, offset 0, flags [DF], p=
roto: TCP (6), length: 241) 172.22.1.129.49772 > 10.16.178.113.80: P 13=
90:1591(201) ack 1 win 16680
12:26:21.016955 IP (tos 0x20, ttl 119, id 29190, offset 0, flags [DF], =
proto: TCP (6), length: 40) 10.16.178.113.80 > 172.16.128.1.49772: ., c=
ksum 0xe767 (correct), ack 1592 win 64240
this is a 1500 bytes packet =3D=3D=3D=3D>>>>>> 12:26:21.020581 IP (tos =
0x20, ttl 119, id 29191, offset 0, flags [DF], proto: TCP (6), length: =
1500) 10.16.178.113.80 > 172.16.128.1.49772: . 1:1461(1460) ack 1592 wi=
n 64240
12:26:21.021155 IP (tos 0x20, ttl 119, id 29192, offset 0, flags [DF], =
proto: TCP (6), length: 429) 10.16.178.113.80 > 172.16.128.1.49772: P 1=
461:1850(389) ack 1592 win 64240
12:26:21.052193 IP (tos 0x0, ttl 127, id 20671, offset 0, flags [DF], p=
roto: TCP (6), length: 52) 172.22.1.129.49772 > 10.16.178.113.80: ., ck=
sum 0xe1a8 (correct), ack 1 win 16680 <nop,nop,sack 1 {1461:1850}>
12:26:24.061073 IP (tos 0x20, ttl 119, id 29321, offset 0, flags [DF], =
proto: TCP (6), length: 1500) 10.16.178.113.80 > 172.16.128.1.49772: . =
1:1461(1460) ack 1592 win 64240
12:26:29.995309 IP (tos 0x20, ttl 119, id 29621, offset 0, flags [DF], =
proto: TCP (6), length: 1500) 10.16.178.113.80 > 172.16.128.1.49772: . =
1:1461(1460) ack 1592 win 64240
12:26:40.438969 IP (tos 0x20, ttl 119, id 29874, offset 0, flags [DF], =
proto: TCP (6), length: 40) 10.16.178.113.80 > 172.16.128.1.49772: R, c=
ksum 0xdb1b (correct), 1850:1850(0) ack 1592 win 0
12:26:40.464618 IP (tos 0x0, ttl 127, id 20680, offset 0, flags [DF], p=
roto: TCP (6), length: 52) 172.22.1.129.49772 > 10.16.178.113.80: ., ck=
sum 0xe1a8 (correct), ack 1 win 16680 <nop,nop,sack 1 {1461:1850}>
12:26:40.504737 IP (tos 0x20, ttl 119, id 29879, offset 0, flags [none]=
, proto: TCP (6), length: 40) 10.16.178.113.80 > 172.16.128.1.49772: R,=
 cksum 0x0993 (correct), 585947794:585947794(0) win 0
=A0
Take a look at the 1500 bytes
packet: this packet comes out
from a des3/md5 ipsec tunnel.
Mtu for that tunnel is 1446.
How could this happen?
=A0
Nevermind, packet has been
delivered, but the linux box
must re-route that one in an
aes/sha1/ipcomp ipsec tunnel
where the mtu is 1430. This
packet is never delivered.
This is the tcpdump capture
on the final gateway:
=A0
12:26:20.907803 IP (tos 0x0, ttl 128, id 20667, offset 0, flags [DF], l=
ength: 52) 172.22.1.129.49772 > 10.16.178.113.80: S [tcp sum ok] 143129=
2197:1431292197(0) win 8192 <mss 1460,nop,wscale 2,nop,nop,sackOK>
12:26:20.982131 IP (tos 0x20, ttl 117, id 29189, offset 0, flags [none]=
, length: 52) 10.16.178.113.80 > 172.22.1.129.49772: S [tcp sum ok] 585=
947793:585947793(0) ack 1431292198 win 64240 <mss 1460,nop,wscale 0,nop=
,nop,sackOK>
12:26:20.982447 IP (tos 0x0, ttl 128, id 20668, offset 0, flags [DF], l=
ength: 40) 172.22.1.129.49772 > 10.16.178.113.80: . [tcp sum ok] ack 1 =
win 16680
12:26:20.983048 IP (tos 0x0, ttl 128, id 20669, offset 0, flags [DF], l=
ength: 1430) 172.22.1.129.49772 > 10.16.178.113.80: . 1:1391(1390) ack =
1 win 16680
12:26:20.983060 IP (tos 0x0, ttl 128, id 20670, offset 0, flags [DF], l=
ength: 241) 172.22.1.129.49772 > 10.16.178.113.80: P 1391:1592(201) ack=
 1 win 16680
12:26:21.060270 IP (tos 0x20, ttl 117, id 29190, offset 0, flags [DF], =
length: 40) 10.16.178.113.80 > 172.22.1.129.49772: . [tcp sum ok] ack 1=
592 win 64240
1500 bytes packet with id 29191 is missing
12:26:21.070229 IP (tos 0x20, ttl 117, id 29192, offset 0, flags [DF], =
length: 429) 10.16.178.113.80 > 172.22.1.129.49772: P 1461:1850(389) ac=
k 1592 win 64240
12:26:21.070642 IP (tos 0x0, ttl 128, id 20671, offset 0, flags [DF], l=
ength: 52) 172.22.1.129.49772 > 10.16.178.113.80: . [tcp sum ok] ack 1 =
win 16680 <nop,nop,sack sack 1 {1461:1850} >
12:26:40.483640 IP (tos 0x20, ttl 117, id 29874, offset 0, flags [DF], =
length: 40) 10.16.178.113.80 > 172.22.1.129.49772: R [tcp sum ok] 1850:=
1850(0) ack 1592 win 0
12:26:40.483989 IP (tos 0x0, ttl 128, id 20680, offset 0, flags [DF], l=
ength: 52) 172.22.1.129.49772 > 10.16.178.113.80: . [tcp sum ok] ack 1 =
win 16680 <nop,nop,sack sack 1 {1461:1850} >
12:26:40.570701 IP (tos 0x20, ttl 117, id 29879, offset 0, flags [none]=
, length: 40) 10.16.178.113.80 > 172.22.1.129.49772: R [tcp sum ok] 585=
947794:585947794(0) win 0
=A0
I have 'fixed' the problem
campling the mss on the final
gateway with:
=A0
iptables -t mangle -I FORWARD -s 172.22.1.0/24 \
-d 10.0.0.0/8 -p tcp --tcp-flags SYN,RST SYN \
-j TCPMSS --set-mss 1300

Any feedback are welcome
TIA
=A0
Here is the network schema (I hope it is clear):
=A0
=A0
customer private network 10.16.0.0/16
|
|
|
+ipsec customer gateway (checkpoint)
|
|
|
|---ipsec tunnel 10.16.0.0/16<->172.16.128.0/28 (des3/md5)
|
|=20
|
+linux 3.3.5 ipsec gateway (SNAT all packets from 172.22.1.0/24 to 172.=
16.128.1)
|=A0=A0=A0 this is the box where I got the first capture
|=A0=A0=A0 (where you see the 1500 bytes packet)
|=20
|---ipsec tunnel 10.16.0.0/16<->172.22.1.0/24 (aes/sha1/ipcomp)
|
|=20
|
+linux 2.6.28.8 ipsec gateway (final gateway)
|=A0=A0=A0 this is the box where I got the second capture
|=A0=A0=A0 (where the 1500 bytes packet was never delivered)
|
client windows 172.22.1.129

 		 	   		 =20
