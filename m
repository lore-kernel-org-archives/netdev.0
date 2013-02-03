From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: per route MTU settings
Date: Sun, 3 Feb 2013 12:22:17 +0100
Message-ID: <DUB107-W29F168D84D4238014B639ED020@phx.gbl>
References: <DUB107-W269A7F1946A7B27212F3F8ED2D0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: <pupilla@libero.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc1-s32.dub0.hotmail.com ([157.55.0.231]:37659 "EHLO
	dub0-omc1-s32.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752099Ab3BCLWT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Feb 2013 06:22:19 -0500
In-Reply-To: <DUB107-W269A7F1946A7B27212F3F8ED2D0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


=46YI, Steffens fix is in 3.8-rc6 now and it works for me.


root@ubuntuvm:~# cat /proc/version
Linux version 3.8.0-030800rc6-generic (root@gomeisa) (gcc version 4.6.3=
 (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #201301312135 SMP Fri Feb 1 02:36:25 =
UTC 2013
root@ubuntuvm:~# echo 1 > /proc/sys/net/ipv4/ip_forward
root@ubuntuvm:~# echo 0 > /proc/sys/net/ipv4/conf/eth0/send_redirects
root@ubuntuvm:~# echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
root@ubuntuvm:~# ip route add 8.8.8.0/24 via 10.0.0.254 mtu lock 1200
root@ubuntuvm:~# ip route add 8.8.4.0/24 via 10.0.0.254 mtu lock 1200
root@ubuntuvm:~#
root@ubuntuvm:~# tcpdump -nvvv icmp -i eth0
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 6=
5535 bytes
12:17:19.085868 IP (tos 0x0, ttl 128, id 3161, offset 0, flags [DF], pr=
oto ICMP (1), length 1428)
=A0=A0=A0 10.0.0.3 > 8.8.4.4: ICMP echo request, id 1, seq 38744, lengt=
h 1408
12:17:19.085910 IP (tos 0xc0, ttl 64, id 53508, offset 0, flags [none],=
 proto ICMP (1), length 576)
=A0=A0=A0 10.0.0.55 > 10.0.0.3: ICMP 8.8.4.4 unreachable - need to frag=
 (mtu 1200), length 556
=A0=A0=A0=A0=A0=A0=A0 IP (tos 0x0, ttl 128, id 3161, offset 0, flags [D=
=46], proto ICMP (1), length 1428)
=A0=A0=A0 10.0.0.3 > 8.8.4.4: ICMP echo request, id 1, seq 38744, lengt=
h 1408
^C
2 packets captured
2 packets received by filter
0 packets dropped by kernel
root@ubuntuvm:~#



 		 	   		  