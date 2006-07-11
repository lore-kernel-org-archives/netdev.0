From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 11 Jul 2006 11:48:53 +0200
Message-ID: <BAY103-F404B281EA3A4954B89D5E3B2680@phx.gbl>
References: <20060711075943.GB1490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s16.bay0.hotmail.com ([65.54.246.216]:29183 "EHLO
	bay0-omc3-s16.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1750879AbWGKJs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 05:48:57 -0400
In-Reply-To: <20060711075943.GB1490@gondor.apana.org.au>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Another tricky behaviour:

root@Mimosa:/tmp# telnet 10.49.59.23 3218
Trying 10.49.59.23...
Connected to 10.49.59.23.
Escape character is '^]'.

Connection closed by foreign host.
root@Mimosa:/tmp# tcpdump -p -n -v ip host 10.49.59.23 > HERBERT-20060711 &
[1] 4797
root@Mimosa:/tmp# tcpdump: listening on eth0, link-type EN10MB (Ethernet), 
capture size 96 bytes

root@Mimosa:/tmp# telnet 10.49.59.23 3218
Trying 10.49.59.23...
Connected to 10.49.59.23.
Escape character is '^]'.


Connection closed by foreign host.
root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp# cat HERBERT-20060711
root@Mimosa:/tmp# fg
tcpdump -p -n -v ip host 10.49.59.23 >HERBERT-20060711
4 packets captured
4 packets received by filter
0 packets dropped by kernel
root@Mimosa:/tmp# cat HERBERT-20060711
11:38:27.795246 IP (tos 0x0, ttl  53, id 5339, offset 0, flags [none], 
length: 44) 10.49.59.23.3218 > 172.29.128.1.4743: S [tcp sum ok] 
2786256910:2786256910(0) ack 1185072116 win 65535 <mss 1406>
11:38:29.052501 IP (tos 0x0, ttl  53, id 5348, offset 0, flags [none], 
length: 40) 10.49.59.23.3218 > 172.29.128.1.4743: . [tcp sum ok] ack 3 win 
65535
11:38:29.303111 IP (tos 0x0, ttl  53, id 5349, offset 0, flags [none], 
length: 40) 10.49.59.23.3218 > 172.29.128.1.4743: F [tcp sum ok] 1:1(0) ack 
5 win 65535
11:38:29.369664 IP (tos 0x0, ttl  53, id 5350, offset 0, flags [none], 
length: 40) 10.49.59.23.3218 > 172.29.128.1.4743: . [tcp sum ok] ack 6 win 
65535

root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp#
root@Mimosa:/tmp# tcpdump -p -n -v ip host 10.16.24.117 > HERBERT-20060711 &
[1] 4801
root@Mimosa:/tmp# tcpdump: listening on eth0, link-type EN10MB (Ethernet), 
capture size 96 bytes

root@Mimosa:/tmp# telnet 10.16.24.117 3219
Trying 10.16.24.117...


[***while waiting, I run the same command from my box (172.16.1.247)***]

root@Mimosa:/tmp# fg
tcpdump -p -n -v ip host 10.16.24.117 >HERBERT-20060711
9 packets captured
9 packets received by filter
0 packets dropped by kernel
root@Mimosa:/tmp# cat HERBERT-20060711
11:39:10.792018 IP (tos 0x10, ttl  63, id 51971, offset 0, flags [DF], 
length: 60) 172.16.1.247.1953 > 10.16.24.117.3219: S [tcp sum ok] 
781753718:781753718(0) win 5840 <mss 1460,sackOK,timestamp 1857141 
0,nop,wscale 3>
11:39:10.825135 IP (tos 0x0, ttl  52, id 14748, offset 0, flags [none], 
length: 44) 10.16.24.117.3219 > 172.29.128.1.1953: S [tcp sum ok] 
1452857781:1452857781(0) ack 781753719 win 17520 <mss 1460>
11:39:10.852659 IP (tos 0x10, ttl  63, id 51972, offset 0, flags [DF], 
length: 40) 172.16.1.247.1953 > 10.16.24.117.3219: . [tcp sum ok] ack 
1452857782 win 5840
11:39:12.094752 IP (tos 0x10, ttl  63, id 51973, offset 0, flags [DF], 
length: 42) 172.16.1.247.1953 > 10.16.24.117.3219: P [tcp sum ok] 0:2(2) ack 
1 win 5840
11:39:12.270403 IP (tos 0x0, ttl  52, id 14764, offset 0, flags [none], 
length: 40) 10.16.24.117.3219 > 172.29.128.1.1953: . [tcp sum ok] ack 3 win 
17520
11:39:13.664803 IP (tos 0x10, ttl  63, id 51974, offset 0, flags [DF], 
length: 42) 172.16.1.247.1953 > 10.16.24.117.3219: P [tcp sum ok] 2:4(2) ack 
1 win 5840
11:39:13.733259 IP (tos 0x0, ttl  52, id 14771, offset 0, flags [none], 
length: 40) 10.16.24.117.3219 > 172.29.128.1.1953: F [tcp sum ok] 1:1(0) ack 
5 win 17520
11:39:13.774786 IP (tos 0x10, ttl  63, id 51975, offset 0, flags [DF], 
length: 40) 172.16.1.247.1953 > 10.16.24.117.3219: F [tcp sum ok] 4:4(0) ack 
2 win 5840
11:39:13.809809 IP (tos 0x0, ttl  52, id 14772, offset 0, flags [none], 
length: 40) 10.16.24.117.3219 > 172.29.128.1.1953: . [tcp sum ok] ack 6 win 
17520

root@Mimosa:/tmp# tcpdump -p -n -v ip host 10.16.24.117 > HERBERT-20060711 &
[1] 4804
root@Mimosa:/tmp# tcpdump: listening on eth0, link-type EN10MB (Ethernet), 
capture size 96 bytes

root@Mimosa:/tmp# telnet 10.16.24.117 3219
Trying 10.16.24.117...

root@Mimosa:/tmp# ping 10.16.24.117
PING 10.16.24.117 (10.16.24.117) 56(84) bytes of data.
64 bytes from 10.16.24.117: icmp_seq=1 ttl=247 time=32.6 ms
64 bytes from 10.16.24.117: icmp_seq=2 ttl=247 time=30.0 ms

--- 10.16.24.117 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 30.087/31.382/32.677/1.295 ms
root@Mimosa:/tmp# fg
tcpdump -p -n -v ip host 10.16.24.117 >HERBERT-20060711
2 packets captured
2 packets received by filter
0 packets dropped by kernel
root@Mimosa:/tmp# cat HERBERT-20060711
11:40:29.523461 IP (tos 0x0, ttl 247, id 15804, offset 0, flags [none], 
length: 84) 10.16.24.117 > 172.29.128.1: icmp 64: echo reply seq 1
11:40:30.521196 IP (tos 0x0, ttl 247, id 15810, offset 0, flags [none], 
length: 84) 10.16.24.117 > 172.29.128.1: icmp 64: echo reply seq 2

root@Mimosa:/tmp#


