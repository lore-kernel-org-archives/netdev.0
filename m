From: Olon <olon@verizon.net>
Subject: Re: 2.6.27 seems to break something with DSL (fwd)
Date: Fri, 17 Oct 2008 16:11:43 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0810171611100.2939@olon.olon.net>
Reply-To: olon@verizon.net
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms044pub.verizon.net ([206.46.252.44]:61597 "EHLO
	vms044pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbYJQURW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 16:17:22 -0400
Received: from pool-96-246-106-2.nycmny.east.verizon.net ([96.246.106.2])
 by vms044.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0K8W00HCVGCD3MC4@vms044.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 17 Oct 2008 15:17:11 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hi there,

I can confirm this issue.
I'm using a westell dsl modem, and going from 2.6.26.5 to .27.  I found that I 
couldn't connect to most websites either.
This modem is in passthrough mode and not nat.

Here is a dump of my attempt to connect to port 80 on gnu.org

tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
14:14:27.213995 IP (tos 0x0, ttl  64, id 44805, offset 0, flags [DF], proto: 
TCP (6), length: 52) 96.246.106.2.34127 > 199.232.41.10.80: F, cksum 0x6b68 
(correct), 1665374024:1665374024(0) ack 1967527671 win 183 <nop,nop,timestamp 
2701875 3655675399>
14:14:27.277189 IP (tos 0x0, ttl  51, id 15270, offset 0, flags [DF], proto: 
TCP (6), length: 52) 199.232.41.10.80 > 96.246.106.2.34127: ., cksum 0x3eed 
(correct), 2897:2897(0) ack 1 win 2892 <nop,nop,timestamp 3655681181 2701875>
14:14:29.082243 IP (tos 0x0, ttl  64, id 34370, offset 0, flags [DF], proto: 
TCP (6), length: 60) 96.246.106.2.59921 > 199.232.41.10.80: S, cksum 0x1638 
(correct), 1808254781:1808254781(0) win 5840 <sackOK,timestamp 2703743 0,mss 
1460,nop,wscale 5>
14:14:29.129687 IP (tos 0x0, ttl  51, id 0, offset 0, flags [DF], proto: TCP 
(6), length: 60) 199.232.41.10.80 > 96.246.106.2.59921: S, cksum 0xb3fe 
(correct), 1977796289:1977796289(0) ack 1808254782 win 5792 <mss 
1452,sackOK,timestamp 3655683033 2703743,nop,wscale 2>
14:14:29.129708 IP (tos 0x0, ttl  64, id 34371, offset 0, flags [DF], proto: 
TCP (6), length: 52) 96.246.106.2.59921 > 199.232.41.10.80: ., cksum 0xf876 
(correct), 1:1(0) ack 1 win 183 <nop,nop,timestamp 2703791 3655683033>
14:14:29.130587 IP (tos 0x0, ttl  64, id 34372, offset 0, flags [DF], proto: 
TCP (6), length: 1492) 96.246.106.2.59921 > 199.232.41.10.80: . 1:1441(1440) 
ack 1 win 183 <nop,nop,timestamp 2703791 3655683033>
14:14:29.130776 IP (tos 0x0, ttl  64, id 34373, offset 0, flags [DF], proto: 
TCP (6), length: 1033) 96.246.106.2.59921 > 199.232.41.10.80: P 1441:2422(981) 
ack 1 win 183 <nop,nop,timestamp 2703792 3655683033>
14:14:29.336008 IP (tos 0x0, ttl  51, id 35550, offset 0, flags [DF], proto: 
TCP (6), length: 52) 199.232.41.10.80 > 96.246.106.2.59921: ., cksum 0xea41 
(correct), 1:1(0) ack 1441 win 2172 <nop,nop,timestamp 3655683241 2703791>
14:14:29.422389 IP (tos 0x0, ttl  51, id 35552, offset 0, flags [DF], proto: 
TCP (6), length: 52) 199.232.41.10.80 > 96.246.106.2.59921: ., cksum 0xe345 
(correct), 1:1(0) ack 2422 win 2892 <nop,nop,timestamp 3655683327 2703792>

however, I can send+receive icmp

ping www.gnu.org
PING gnu.org (199.232.41.10) 56(84) bytes of data.
64 bytes from www.gnu.org (199.232.41.10): icmp_seq=1 ttl=51 time=50.5 ms
64 bytes from www.gnu.org (199.232.41.10): icmp_seq=2 ttl=51 time=36.9 ms
64 bytes from www.gnu.org (199.232.41.10): icmp_seq=3 ttl=51 time=34.7 ms
64 bytes from www.gnu.org (199.232.41.10): icmp_seq=4 ttl=51 time=37.4 ms
64 bytes from www.gnu.org (199.232.41.10): icmp_seq=5 ttl=51 time=35.5 ms

ping -s 1000 gnu.org
PING gnu.org (199.232.41.10) 1000(1028) bytes of data.
1008 bytes from www.gnu.org (199.232.41.10): icmp_seq=1 ttl=51 time=147 ms
1008 bytes from www.gnu.org (199.232.41.10): icmp_seq=2 ttl=51 time=102 ms
1008 bytes from www.gnu.org (199.232.41.10): icmp_seq=3 ttl=51 time=101 ms
1008 bytes from www.gnu.org (199.232.41.10): icmp_seq=4 ttl=51 time=100 ms
1008 bytes from www.gnu.org (199.232.41.10): icmp_seq=5 ttl=51 time=102 ms


tcpdump not port 22 -nvvv
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
14:26:30.791235 IP (tos 0x0, ttl  64, id 17580, offset 0, flags [DF], proto: 
UDP (17), length: 53) 96.246.106.2.50098 > 192.168.1.1.53: [udp sum ok]  3605+ 
A? gnu.org. (25)
14:26:30.793290 IP (tos 0x0, ttl  64, id 3163, offset 0, flags [none], proto: 
UDP (17), length: 69) 192.168.1.1.53 > 96.246.106.2.50098: [udp sum ok]  3605 
q: A? gnu.org. 1/0/0 gnu.org. A 199.232.41.10 (41)
14:26:30.793789 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], proto: ICMP 
(1), length: 1028) 96.246.106.2 > 199.232.41.10: ICMP echo request, id 37656, 
seq 1, length 1008
14:26:30.941269 IP (tos 0x0, ttl  51, id 59350, offset 0, flags [none], proto: 
ICMP (1), length: 1028) 199.232.41.10 > 96.246.106.2: ICMP echo reply, id 
37656, seq 1, length 1008
14:26:30.941769 IP (tos 0x0, ttl  64, id 17731, offset 0, flags [DF], proto: 
UDP (17), length: 72) 96.246.106.2.37518 > 192.168.1.1.53: [udp sum ok]  1788+ 
PTR? 10.41.232.199.in-addr.arpa. (44)
14:26:30.943781 IP (tos 0x0, ttl  64, id 3164, offset 0, flags [none], proto: 
UDP (17), length: 122) 192.168.1.1.53 > 96.246.106.2.37518:  1788 q: PTR? 
10.41.232.199.in-addr.arpa. 2/0/0 10.41.232.199.in-addr.arpa.[|domain]
14:26:31.794694 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], proto: ICMP 
(1), length: 1028) 96.246.106.2 > 199.232.41.10: ICMP echo request, id 37656, 
seq 2, length 1008
14:26:31.897004 IP (tos 0x0, ttl  51, id 59351, offset 0, flags [none], proto: 
ICMP (1), length: 1028) 199.232.41.10 > 96.246.106.2: ICMP echo reply, id 
37656, seq 2, length 1008
14:26:31.897424 IP (tos 0x0, ttl  64, id 18686, offset 0, flags [DF], proto: 
UDP (17), length: 72) 96.246.106.2.53838 > 192.168.1.1.53: [udp sum ok]  61713+ 
PTR? 10.41.232.199.in-addr.arpa. (44)
14:26:31.899461 IP (tos 0x0, ttl  64, id 3165, offset 0, flags [none], proto: 
UDP (17), length: 122) 192.168.1.1.53 > 96.246.106.2.53838:  61713 q: PTR? 
10.41.232.199.in-addr.arpa. 2/0/0 10.41.232.199.in-addr.arpa.[|domain]
14:26:32.795702 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], proto: ICMP 
(1), length: 1028) 96.246.106.2 > 199.232.41.10: ICMP echo request, id 37656, 
seq 3, length 1008
14:26:32.896773 IP (tos 0x0, ttl  51, id 59352, offset 0, flags [none], proto: 
ICMP (1), length: 1028) 199.232.41.10 > 96.246.106.2: ICMP echo reply, id 
37656, seq 3, length 1008
14:26:32.897175 IP (tos 0x0, ttl  64, id 19686, offset 0, flags [DF], proto: 
UDP (17), length: 72) 96.246.106.2.51768 > 192.168.1.1.53: [udp sum ok]  50002+ 
PTR? 10.41.232.199.in-addr.arpa. (44)
14:26:32.899209 IP (tos 0x0, ttl  64, id 3166, offset 0, flags [none], proto: 
UDP (17), length: 122) 192.168.1.1.53 > 96.246.106.2.51768:  50002 q: PTR? 
10.41.232.199.in-addr.arpa. 2/0/0 10.41.232.199.in-addr.arpa.[|domain]
14:26:33.796709 IP (tos 0x0, ttl  64, id 0, offset 0, flags [DF], proto: ICMP 
(1), length: 1028) 96.246.106.2 > 199.232.41.10: ICMP echo request, id 37656, 
seq 4, length 1008
14:26:33.896804 IP (tos 0x0, ttl  51, id 59353, offset 0, flags [none], proto: 
ICMP (1), length: 1028) 199.232.41.10 > 96.246.106.2: ICMP echo reply, id 
37656, seq 4, length 1008
14:26:33.897202 IP (tos 0x0, ttl  64, id 20686, offset 0, flags [DF], proto: 
UDP (17), length: 72) 96.246.106.2.53984 > 192.168.1.1.53: [udp sum ok]  40904+ 
PTR? 10.41.232.199.in-addr.arpa. (44)
14:26:33.899239 IP (tos 0x0, ttl  64, id 3167, offset 0, flags [none], proto: 
UDP (17), length: 122) 192.168.1.1.53 > 96.246.106.2.53984:  40904 q: PTR? 
10.41.232.199.in-addr.arpa. 2/0/0 10.41.232.199.in-addr.arpa.[|domain]

-------------------------------------------------------------------------------------------------------------------
attempting to get to kernel.org


tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
14:33:37.394450 IP (tos 0x0, ttl  64, id 50967, offset 0, flags [DF], proto: 
UDP (17), length: 56) 96.246.106.2.57769 > 192.168.1.1.53: [udp sum ok]  23128+ 
A? kernel.org. (28)
14:33:37.537163 IP (tos 0x0, ttl  64, id 3180, offset 0, flags [none], proto: 
UDP (17), length: 88) 192.168.1.1.53 > 96.246.106.2.57769:  23128 q: A? 
kernel.org. 2/0/0 kernel.org. A 204.152.191.5, kernel.org. (60)
14:33:37.539985 IP (tos 0x0, ttl  64, id 51113, offset 0, flags [DF], proto: 
UDP (17), length: 56) 96.246.106.2.48629 > 192.168.1.1.53: [udp sum ok]  53919+ 
A? kernel.org. (28)
14:33:37.542025 IP (tos 0x0, ttl  64, id 3181, offset 0, flags [none], proto: 
UDP (17), length: 88) 192.168.1.1.53 > 96.246.106.2.48629:  53919 q: A? 
kernel.org. 2/0/0 kernel.org. A 204.152.191.5, kernel.org. (60)
14:33:37.542964 IP (tos 0x0, ttl  64, id 53172, offset 0, flags [DF], proto: 
TCP (6), length: 60) 96.246.106.2.58789 > 204.152.191.5.80: S, cksum 0x88bf 
(correct), 2615609368:2615609368(0) win 5840 <sackOK,timestamp 3852204 0,mss 
1460,nop,wscale 5>
14:33:37.740973 IP (tos 0x0, ttl  55, id 0, offset 0, flags [DF], proto: TCP 
(6), length: 60) 204.152.191.5.80 > 96.246.106.2.58789: S, cksum 0x89d1 
(correct), 2581817972:2581817972(0) ack 2615609369 win 5792 <mss 
1452,sackOK,timestamp 759090556 3852204,nop,wscale 7>
14:33:37.740998 IP (tos 0x0, ttl  64, id 53173, offset 0, flags [DF], proto: 
TCP (6), length: 52) 96.246.106.2.58789 > 204.152.191.5.80: ., cksum 0xcdb8 
(correct), 1:1(0) ack 1 win 183 <nop,nop,timestamp 3852402 759090556>
14:33:37.741908 IP (tos 0x0, ttl  64, id 53174, offset 0, flags [DF], proto: 
TCP (6), length: 1492) 96.246.106.2.58789 > 204.152.191.5.80: . 1:1441(1440) 
ack 1 win 183 <nop,nop,timestamp 3852403 759090556>
14:33:37.742076 IP (tos 0x0, ttl  64, id 53175, offset 0, flags [DF], proto: 
TCP (6), length: 1032) 96.246.106.2.58789 > 204.152.191.5.80: P 1441:2421(980) 
ack 1 win 183 <nop,nop,timestamp 3852403 759090556>
14:33:37.980932 IP (tos 0x0, ttl  55, id 42008, offset 0, flags [DF], proto: 
TCP (6), length: 52) 204.152.191.5.80 > 96.246.106.2.58789: ., cksum 0xc799 
(correct), 1:1(0) ack 1441 win 68 <nop,nop,timestamp 759090797 3852403>
14:33:38.066904 IP (tos 0x0, ttl  55, id 42009, offset 0, flags [DF], proto: 
TCP (6), length: 52) 204.152.191.5.80 > 96.246.106.2.58789: ., cksum 0xc358 
(correct), 1:1(0) ack 2421 win 91 <nop,nop,timestamp 759090883 3852403>
14:33:54.621879 IP (tos 0x0, ttl  64, id 53176, offset 0, flags [DF], proto: 
TCP (6), length: 52) 96.246.106.2.58789 > 204.152.191.5.80: F, cksum 0x810b 
(correct), 2421:2421(0) ack 1 win 183 <nop,nop,timestamp 3869283 759090883>
14:33:54.792368 IP (tos 0x0, ttl  55, id 42016, offset 0, flags [DF], proto: 
TCP (6), length: 52) 204.152.191.5.80 > 96.246.106.2.58789: ., cksum 0x34c0 
(correct), 2897:2897(0) ack 2422 win 91 <nop,nop,timestamp 759107610 3869283>


attempting to get to www.news.com

tcpdump not port 22 -nvvv
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
14:30:21.287441 IP (tos 0x0, ttl  64, id 51468, offset 0, flags [DF], proto: 
UDP (17), length: 58) 96.246.106.2.53783 > 192.168.1.1.53: [udp sum ok]  22653+ 
A? www.news.com. (30)
14:30:21.354417 IP (tos 0x0, ttl  64, id 3172, offset 0, flags [none], proto: 
UDP (17), length: 134) 192.168.1.1.53 > 96.246.106.2.53783:  22653 q: A? 
www.news.com. 2/0/0 www.news.com. CNAME[|domain]
14:30:21.376541 IP (tos 0x0, ttl  64, id 51557, offset 0, flags [DF], proto: 
UDP (17), length: 58) 96.246.106.2.46616 > 192.168.1.1.53: [udp sum ok]  21293+ 
A? www.news.com. (30)
14:30:21.378559 IP (tos 0x0, ttl  64, id 3173, offset 0, flags [none], proto: 
UDP (17), length: 134) 192.168.1.1.53 > 96.246.106.2.46616:  21293 q: A? 
www.news.com. 2/0/0 www.news.com. CNAME[|domain]
14:30:21.379443 IP (tos 0x0, ttl  64, id 1194, offset 0, flags [DF], proto: TCP 
(6), length: 60) 96.246.106.2.39802 > 216.239.122.102.80: S, cksum 0xfa15 
(correct), 3852520898:3852520898(0) win 5840 <sackOK,timestamp 3656040 0,mss 
1460,nop,wscale 5>
14:30:21.499309 IP (tos 0x0, ttl 245, id 55551, offset 0, flags [none], proto: 
TCP (6), length: 44) 216.239.122.102.80 > 96.246.106.2.39802: S, cksum 0x91bd 
(correct), 3608125909:3608125909(0) ack 3852520899 win 8190 <mss 1452>
14:30:21.499338 IP (tos 0x0, ttl  64, id 1195, offset 0, flags [DF], proto: TCP 
(6), length: 40) 96.246.106.2.39802 > 216.239.122.102.80: ., cksum 0xb2a0 
(correct), 1:1(0) ack 1 win 5840
14:30:21.500228 IP (tos 0x0, ttl  64, id 1196, offset 0, flags [DF], proto: TCP 
(6), length: 1492) 96.246.106.2.39802 > 216.239.122.102.80: . 1:1453(1452) ack 
1 win 5840
14:30:21.500241 IP (tos 0x0, ttl  64, id 1197, offset 0, flags [DF], proto: TCP 
(6), length: 1010) 96.246.106.2.39802 > 216.239.122.102.80: P 1453:2423(970) 
ack 1 win 5840
14:30:21.765831 IP (tos 0x0, ttl  54, id 29130, offset 0, flags [DF], proto: 
TCP (6), length: 40) 216.239.122.102.80 > 96.246.106.2.39802: ., cksum 0x8742 
(correct), 1:1(0) ack 2423 win 14520
14:30:21.771801 IP (tos 0x0, ttl  54, id 64782, offset 0, flags [DF], proto: 
TCP (6), length: 514) 216.239.122.102.80 > 96.246.106.2.39802: FP 1:475(474) 
ack 2423 win 14520
14:30:21.773059 IP (tos 0x0, ttl  64, id 1198, offset 0, flags [DF], proto: TCP 
(6), length: 40) 96.246.106.2.39802 > 216.239.122.102.80: F, cksum 0xa4fe 
(correct), 2423:2423(0) ack 476 win 6432
14:30:21.909802 IP (tos 0x0, ttl 245, id 59929, offset 0, flags [none], proto: 
TCP (6), length: 40) 216.239.122.102.80 > 96.246.106.2.39802: ., cksum 0x8566 
(correct), 476:476(0) ack 2424 win 14520
14:30:23.775805 IP (tos 0x0, ttl  64, id 53957, offset 0, flags [DF], proto: 
UDP (17), length: 59) 96.246.106.2.37171 > 192.168.1.1.53: [udp sum ok]  43291+ 
A? news.cnet.com. (31)
14:30:23.825751 IP (tos 0x0, ttl  64, id 3175, offset 0, flags [none], proto: 
UDP (17), length: 150) 192.168.1.1.53 > 96.246.106.2.37171:  43291 q: A? 
news.cnet.com. 3/0/0 news.cnet.com. CNAME[|domain]
14:30:23.826693 IP (tos 0x0, ttl  64, id 48226, offset 0, flags [DF], proto: 
TCP (6), length: 60) 96.246.106.2.36303 > 216.239.122.178.80: S, cksum 0x5aff 
(correct), 3886968474:3886968474(0) win 5840 <sackOK,timestamp 3658488 0,mss 
1460,nop,wscale 5>
14:30:23.929033 IP (tos 0x0, ttl 245, id 22268, offset 0, flags [none], proto: 
TCP (6), length: 44) 216.239.122.178.80 > 96.246.106.2.36303: S, cksum 0x4f4d 
(correct), 1379128219:1379128219(0) ack 3886968475 win 8190 <mss 1452>
14:30:23.929062 IP (tos 0x0, ttl  64, id 48227, offset 0, flags [DF], proto: 
TCP (6), length: 40) 96.246.106.2.36303 > 216.239.122.178.80: ., cksum 0x7030 
(correct), 1:1(0) ack 1 win 5840
14:30:23.929938 IP (tos 0x0, ttl  64, id 48228, offset 0, flags [DF], proto: 
TCP (6), length: 1492) 96.246.106.2.36303 > 216.239.122.178.80: . 1:1453(1452) 
ack 1 win 5840
14:30:23.930101 IP (tos 0x0, ttl  64, id 48229, offset 0, flags [DF], proto: 
TCP (6), length: 1011) 96.246.106.2.36303 > 216.239.122.178.80: P 
1453:2424(971) ack 1 win 5840
14:30:24.215020 IP (tos 0x0, ttl  54, id 8484, offset 0, flags [DF], proto: TCP 
(6), length: 40) 216.239.122.178.80 > 96.246.106.2.36303: ., cksum 0x11c5 
(correct), 1:1(0) ack 2424 win 27588
14:30:24.262465 IP (tos 0x0, ttl 245, id 22541, offset 0, flags [+], proto: TCP 
(6), length: 764) 216.239.122.178.80 > 96.246.106.2.36303: P 1461:2185(724) ack 
2424 win 27588
14:30:24.270508 IP (tos 0x0, ttl 245, id 22541, offset 744, flags [none], 
proto: TCP (6), length: 756) 216.239.122.178 > 96.246.106.2: tcp
14:30:24.270535 IP (tos 0x0, ttl  64, id 48230, offset 0, flags [DF], proto: 
TCP (6), length: 40) 96.246.106.2.36303 > 216.239.122.178.80: ., cksum 0x66b9 
(correct), 2424:2424(0) ack 1 win 5840
14:30:24.278940 IP (tos 0x0, ttl 245, id 22797, offset 0, flags [+], proto: TCP 
(6), length: 764) 216.239.122.178.80 > 96.246.106.2.36303: P 2921:3645(724) ack 
2424 win 27588
14:30:24.287262 IP (tos 0x0, ttl 245, id 22797, offset 744, flags [none], 
proto: TCP (6), length: 756) 216.239.122.178 > 96.246.106.2: tcp
14:30:24.287288 IP (tos 0x0, ttl  64, id 48231, offset 0, flags [DF], proto: 
TCP (6), length: 40) 96.246.106.2.36303 > 216.239.122.178.80: ., cksum 0x66b9 
(correct), 2424:2424(0) ack 1 win 5840
14:30:24.295696 IP (tos 0x0, ttl 245, id 23053, offset 0, flags [+], proto: TCP 
(6), length: 764) 216.239.122.178.80 > 96.246.106.2.36303: P 4381:5105(724) ack 
2424 win 27588
14:30:24.304030 IP (tos 0x0, ttl 245, id 23053, offset 744, flags [none], 
proto: TCP (6), length: 756) 216.239.122.178 > 96.246.106.2: tcp
14:30:24.304056 IP (tos 0x0, ttl  64, id 48232, offset 0, flags [DF], proto: 
TCP (6), length: 40) 96.246.106.2.36303 > 216.239.122.178.80: ., cksum 0x66b9 
(correct), 2424:2424(0) ack 1 win 5840

now I can get to one website, lynx.isc.org:

tcpdump not port 22 -nvvv
tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
14:33:00.815961 IP (tos 0x0, ttl  64, id 14389, offset 0, flags [DF], proto: 
UDP (17), length: 58) 96.246.106.2.43004 > 192.168.1.1.53: [udp sum ok]  21912+ 
A? lynx.isc.org. (30)
14:33:00.862999 IP (tos 0x0, ttl  64, id 3178, offset 0, flags [none], proto: 
UDP (17), length: 74) 192.168.1.1.53 > 96.246.106.2.43004: [udp sum ok]  21912 
q: A? lynx.isc.org. 1/0/0 lynx.isc.org. A 204.152.184.112 (46)
14:33:00.863999 IP (tos 0x0, ttl  64, id 26362, offset 0, flags [DF], proto: 
TCP (6), length: 60) 96.246.106.2.36959 > 204.152.184.112.80: S, cksum 0x3f78 
(correct), 2043305631:2043305631(0) win 5840 <sackOK,timestamp 3815525 0,mss 
1460,nop,wscale 5>
14:33:01.023448 IP (tos 0x0, ttl  55, id 40963, offset 0, flags [DF], proto: 
TCP (6), length: 64) 204.152.184.112.80 > 96.246.106.2.36959: S, cksum 0x4861 
(correct), 3326481792:3326481792(0) ack 2043305632 win 65535 <mss 
1452,nop,wscale 0,nop,nop,timestamp 134158359 3815525,nop,nop,sackOK>
14:33:01.023495 IP (tos 0x0, ttl  64, id 26363, offset 0, flags [DF], proto: 
TCP (6), length: 52) 96.246.106.2.36959 > 204.152.184.112.80: ., cksum 0x87ce 
(correct), 1:1(0) ack 1 win 183 <nop,nop,timestamp 3815684 134158359>
14:33:01.024431 IP (tos 0x0, ttl  64, id 26364, offset 0, flags [DF], proto: 
TCP (6), length: 1492) 96.246.106.2.36959 > 204.152.184.112.80: . 1:1441(1440) 
ack 1 win 183 <nop,nop,timestamp 3815685 134158359>
14:33:01.024596 IP (tos 0x0, ttl  64, id 26365, offset 0, flags [DF], proto: 
TCP (6), length: 1034) 96.246.106.2.36959 > 204.152.184.112.80: P 
1441:2423(982) ack 1 win 183 <nop,nop,timestamp 3815685 134158359>
14:33:01.267089 IP (tos 0x0, ttl  55, id 41119, offset 0, flags [DF], proto: 
TCP (6), length: 52) 204.152.184.112.80 > 96.246.106.2.36959: ., cksum 0x843b 
(correct), 1:1(0) ack 1441 win 65168 <nop,nop,timestamp 134158383 3815685>
14:33:01.353318 IP (tos 0x0, ttl  55, id 41204, offset 0, flags [DF], proto: 
TCP (6), length: 52) 204.152.184.112.80 > 96.246.106.2.36959: ., cksum 0x7eed 
(correct), 1:1(0) ack 2423 win 65535 <nop,nop,timestamp 134158392 3815685>
14:33:01.360548 IP (tos 0x0, ttl  55, id 41206, offset 0, flags [DF], proto: 
TCP (6), length: 607) 204.152.184.112.80 > 96.246.106.2.36959: P 1449:2004(555) 
ack 2423 win 65535 <nop,nop,timestamp 134158392 3815685>
14:33:01.360566 IP (tos 0x0, ttl  64, id 26366, offset 0, flags [DF], proto: 
TCP (6), length: 64) 96.246.106.2.36959 > 204.152.184.112.80: ., cksum 0x81c4 
(correct), 2423:2423(0) ack 1 win 183 <nop,nop,timestamp 3816021 
134158392,nop,nop,sack 1 {1449:2004}>
14:33:01.361317 IP (tos 0x0, ttl  55, id 41214, offset 0, flags [DF], proto: 
TCP (6), length: 52) 204.152.184.112.80 > 96.246.106.2.36959: F, cksum 0x7719 
(correct), 2004:2004(0) ack 2423 win 65535 <nop,nop,timestamp 134158392 
3815685>
14:33:01.361332 IP (tos 0x0, ttl  64, id 26367, offset 0, flags [DF], proto: 
TCP (6), length: 64) 96.246.106.2.36959 > 204.152.184.112.80: ., cksum 0x81c2 
(correct), 2423:2423(0) ack 1 win 183 <nop,nop,timestamp 3816022 
134158392,nop,nop,sack 1 {1449:2005}>
14:33:01.445861 IP (tos 0x0, ttl  55, id 41251, offset 0, flags [DF], proto: 
TCP (6), length: 1492) 204.152.184.112.80 > 96.246.106.2.36959: . 1:1441(1440) 
ack 2423 win 65535 <nop,nop,timestamp 134158400 3815685>
14:33:01.445893 IP (tos 0x0, ttl  64, id 26368, offset 0, flags [DF], proto: 
TCP (6), length: 64) 96.246.106.2.36959 > 204.152.184.112.80: ., cksum 0x7b6b 
(correct), 2423:2423(0) ack 1441 win 273 <nop,nop,timestamp 3816107 
134158400,nop,nop,sack 1 {1449:2005}>
14:33:01.452430 IP (tos 0x0, ttl  55, id 41252, offset 0, flags [DF], proto: 
TCP (6), length: 615) 204.152.184.112.80 > 96.246.106.2.36959: FP 
1441:2004(563) ack 2423 win 65535 <nop,nop,timestamp 134158400 3815685>
14:33:01.453235 IP (tos 0x0, ttl  64, id 26369, offset 0, flags [DF], proto: 
TCP (6), length: 52) 96.246.106.2.36959 > 204.152.184.112.80: F, cksum 0x73f8 
(correct), 2423:2423(0) ack 2005 win 363 <nop,nop,timestamp 3816114 134158400>
14:33:01.674509 IP (tos 0x0, ttl  55, id 41380, offset 0, flags [DF], proto: 
TCP (6), length: 52) 204.152.184.112.80 > 96.246.106.2.36959: ., cksum 0x754c 
(correct), 2005:2005(0) ack 2424 win 65534 <nop,nop,timestamp 134158424 
3816114>


-olon
