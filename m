From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: 2.4.18 and out of window packets
Date: Tue, 14 May 2002 10:09:36 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0205101521110.31570-100000@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

Hello,

I administer ftp.kfki.hu [148.6.0.24] running Linux 2.4.18 - and wrote
the TCP window tracking patch for netfilter.

Some guys sent me a mail that they tried to measure the different
troughputs by setting different window scale values and using our ftp
server as target, but at a given value the transfer stopped completely.
Checking our firewall logs I saw that the firewall dropped the packets as
out of window ones.

148.6.0.24 runs 2.4.18 with the default TCP settings i.e no window scaling
enabled. The other side runs 2.4.18/2.4.19-pre3 with the following
setting:

echo "4096    895450   1747600" > /proc/sys/net/ipv4/tcp_rmem

tcpdumping the traffic on the internal side, the first four packets were:

11:28:34.212520 x.x.x.x.33299 > 148.6.0.24.39413: S [tcp sum ok]
	4065695110:4065695110(0) win 5840
	<mss 1460,sackOK,timestamp 90809727 0,nop,wscale 4>
	(DF) (ttl 44, id 12537, len 60)
11:28:34.212696 148.6.0.24.39413 > x.x.x.x.33299: S [tcp sum ok]
	4249346209:4249346209(0) ack 4065695111 win 5792
	<mss 1460,sackOK,timestamp 326603 90809727,nop,wscale 0>
	(DF) (ttl 63, id 0, len 60)
11:28:34.266715 x.x.x.x.33299 > 148.6.0.24.39413: . [tcp sum ok]
	4065695111:4065695111(0) ack 4249346210 win 365
	<nop,nop,timestamp 90809732 326603>
	(DF) (ttl 44, id 12538, len 52)
11:28:34.267237 148.6.0.24.39413 > x.x.x.x.33299: .
	4249346210:4249347658(1448) ack 4065695111 win 5792
	<nop,nop,timestamp 326608 90809732>
	(DF) [tos 0x8]  (ttl 63, id 7026, len 1500)

The fourth packet seems to be truly out of window.

How could the problem be fixed?

Regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@sunserv.kfki.hu
WWW-Home: http://www.kfki.hu/~kadlec
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
