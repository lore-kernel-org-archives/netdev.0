From: "pupilla@libero.it" <pupilla@libero.it>
Subject: R: RE: per route MTU settings
Date: Mon, 14 Jan 2013 09:51:53 +0100 (CET)
Message-ID: <30645799.1106291358153513079.JavaMail.defaultUser@defaultHost>
Reply-To: "pupilla@libero.it" <pupilla@libero.it>
Mime-Version: 1.0
Content-Type: text/plain;charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: <luky-37@hotmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outrelay02.libero.it ([212.52.84.102]:35652 "EHLO
	outrelay02.libero.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755495Ab3ANIvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 03:51:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

luky-37@hotmail.com wrote:
>I guess 10.81.104.1 has a 576B MTU route/interface towards
>10.81.105.109,

no, 10.81.104.1 is only a L3 switch.

>Running from both hosts pings with:
>-s 548
>-s 549
>-s 1422
>-s 1423
>
>and then analyzing the results will probably give us a better
>idea of what actually happens.

here is the results:

root@10.81.104.254:~# ip route add 10.81.105.121/32 via 10.81.104.1 mtu lock 
1450
root@10.81.104.254:~# ip r s | grep 10.81 | grep eth2
10.81.104.0/24 dev eth2  proto kernel  scope link  src 10.81.104.254 
10.81.104.0/21 via 10.81.104.1 dev eth2 
10.81.105.121 via 10.81.104.1 dev eth2  mtu lock 1450
root@10.81.104.254:~# ip route flush cache
root@10.81.104.254:~# ping -M do 10.81.105.121 -c 4 -s 548
PING 10.81.105.121 (10.81.105.121) 548(576) bytes of data.
556 bytes from 10.81.105.121: icmp_req=1 ttl=127 time=0.476 ms
556 bytes from 10.81.105.121: icmp_req=2 ttl=127 time=0.448 ms
556 bytes from 10.81.105.121: icmp_req=3 ttl=127 time=0.515 ms

root@10.81.104.254:~# ip route flush cache
root@10.81.104.254:~# ping -M do 10.81.105.121 -c 4 -s 549
PING 10.81.105.121 (10.81.105.121) 549(577) bytes of data.
557 bytes from 10.81.105.121: icmp_req=1 ttl=127 time=0.386 ms
557 bytes from 10.81.105.121: icmp_req=2 ttl=127 time=0.525 ms
557 bytes from 10.81.105.121: icmp_req=3 ttl=127 time=0.447 ms

root@10.81.104.254:~# ip route flush cache
root@10.81.104.254:~# ping -M do 10.81.105.121 -c 4 -s 1422
PING 10.81.105.121 (10.81.105.121) 1422(1450) bytes of data.
1430 bytes from 10.81.105.121: icmp_req=1 ttl=127 time=0.724 ms
1430 bytes from 10.81.105.121: icmp_req=2 ttl=127 time=0.785 ms
1430 bytes from 10.81.105.121: icmp_req=3 ttl=127 time=1.95 ms

root@10.81.104.254:~# ip route flush cache
root@10.81.104.254:~# ping -M do 10.81.105.121 -c 4 -s 1423
PING 10.81.105.121 (10.81.105.121) 1423(1451) bytes of data.
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 1450)

root@10.81.104.126:~# ip r s
default via 10.81.104.254 dev eth0  metric 1 
10.81.104.0/24 dev eth0  proto kernel  scope link  src 10.81.104.126 
127.0.0.0/8 dev lo  scope link 

root@10.81.104.126:~# ping -M do 10.81.105.121 -c 4 -s 548
PING 10.81.105.121 (10.81.105.121) 548(576) bytes of data.
556 bytes from 10.81.105.121: icmp_req=1 ttl=127 time=0.352 ms
556 bytes from 10.81.105.121: icmp_req=2 ttl=127 time=0.372 ms
556 bytes from 10.81.105.121: icmp_req=3 ttl=127 time=0.368 ms

root@10.81.104.126:~# ip route flush cache
root@10.81.104.126:~# ping -M do 10.81.105.121 -c 4 -s 549
PING 10.81.105.121 (10.81.105.121) 549(577) bytes of data.
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 576)

I don't undestand why 10.81.104.254 here, is reporting
that the mtu is 576 instead of 1450

>From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)
>From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)

root@10.81.104.126:~# ip route flush cache
root@10.81.104.126:~# ping -M do 10.81.105.121 -c 4 -s 1422
PING 10.81.105.121 (10.81.105.121) 1422(1450) bytes of data.
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 576)
>From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)
>From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)

root@10.81.104.126:~# ip route flush cache
root@10.81.104.126:~# ping -M do 10.81.105.121 -c 4 -s 1423
PING 10.81.105.121 (10.81.105.121) 1423(1451) bytes of data.
>From 10.81.104.254 icmp_seq=1 Frag needed and DF set (mtu = 576)
>From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)
>From 10.81.104.126 icmp_seq=2 Frag needed and DF set (mtu = 576)
