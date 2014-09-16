From: Daniele Orlandi <daniele@orlandi.com>
Subject: Issue with ping source address display
Date: Tue, 16 Sep 2014 18:01:05 +0200
Message-ID: <54185EC1.6030303@orlandi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from submission.geniusware.it ([62.212.12.144]:35947 "EHLO
	submission.geniusware.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754424AbaIPQNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:13:50 -0400
Received: from localhost (localhost [127.0.0.1])
	by submission.orlandi.com (Postfix) with ESMTP id A60BF4C16D1
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 18:04:13 +0200 (CEST)
Received: from submission.orlandi.com ([127.0.0.1])
	by localhost (submission.orlandi.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id k9sFFJD5T31J for <netdev@vger.kernel.org>;
	Tue, 16 Sep 2014 18:01:16 +0200 (CEST)
Received: from [IPv6:2a02:20:20:cafe:a54d:c65d:d221:340c] (unknown [IPv6:2a02:20:20:cafe:a54d:c65d:d221:340c])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: daniele@orlandi.com)
	by submission.orlandi.com (Postfix) with ESMTPSA id F397A4C16AF
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 18:01:15 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

I noticed that when ping receives ICMP messages from different sources 
the first IP address is always used and displayed:


vihai@seviolab:~$ ping -V
ping utility, iputils-s20121221

This is a (simulated) flapping route:

vihai@seviolab:~$ ping 10.254.10.140
PING 10.254.10.140 (10.254.10.140) 56(84) bytes of data.
 From 192.168.1.1 icmp_seq=1 Destination Host Unreachable
 From 192.168.1.1 icmp_seq=2 Destination Host Unreachable
 From 192.168.1.1 icmp_seq=3 Destination Host Unreachable
64 bytes from 192.168.1.1: icmp_seq=4 ttl=61 time=24.7 ms
64 bytes from 192.168.1.1: icmp_seq=5 ttl=61 time=25.6 ms
64 bytes from 192.168.1.1: icmp_seq=6 ttl=61 time=69.6 ms
 From 192.168.1.1 icmp_seq=7 Destination Host Unreachable
 From 192.168.1.1 icmp_seq=8 Destination Host Unreachable
 From 192.168.1.1 icmp_seq=9 Destination Host Unreachable
^C
--- 10.254.10.140 ping statistics ---
9 packets transmitted, 3 received, +6 errors, 66% packet loss, time 8001ms
rtt min/avg/max/mdev = 24.797/40.061/69.692/20.955 ms


The sources, however are different:

vihai@seviolab:~$ sudo tcpdump -n icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
^[OA^[OA^[OA17:09:55.932981 IP 192.168.1.21 > 10.254.10.140: ICMP echo 
request, id 9278, seq 1, length 64
17:09:55.933234 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140 
unreachable, length 92
17:09:56.933169 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id 
9278, seq 2, length 64
17:09:56.933416 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140 
unreachable, length 92
17:09:57.933160 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id 
9278, seq 3, length 64
17:09:57.933404 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140 
unreachable, length 92
17:09:58.933163 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id 
9278, seq 4, length 64
17:09:58.957939 IP 10.254.10.140 > 192.168.1.21: ICMP echo reply, id 
9278, seq 4, length 64
17:09:59.935050 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id 
9278, seq 5, length 64
17:09:59.960724 IP 10.254.10.140 > 192.168.1.21: ICMP echo reply, id 
9278, seq 5, length 64
17:10:00.936177 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id 
9278, seq 6, length 64
17:10:01.005849 IP 10.254.10.140 > 192.168.1.21: ICMP echo reply, id 
9278, seq 6, length 64
17:10:01.936313 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id 
9278, seq 7, length 64
17:10:01.936626 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140 
unreachable, length 92
17:10:02.935321 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id 
9278, seq 8, length 64
17:10:02.935591 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140 
unreachable, length 92
17:10:03.934322 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id 
9278, seq 9, length 64
17:10:03.934613 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140 
unreachable, length 92




Tried with a different ping implementation (RouterOS) and the behaviour 
seems correct:

[vihai@SevioLab SW1] > ping 10.254.10.140
HOST                                     SIZE TTL TIME  STATUS 

192.168.1.1                                84  64 0ms   host unreachable 

192.168.1.1                                84  64 0ms   host unreachable 

192.168.1.1                                84  64 0ms   host unreachable 

10.254.10.140                              56  61 20ms
10.254.10.140                              56  61 46ms
10.254.10.140                              56  61 37ms
192.168.1.1                                84  64 0ms   host unreachable 

192.168.1.1                                84  64 0ms   host unreachable 

192.168.1.1                                84  64 0ms   host unreachable 

     sent=9 received=3 packet-loss=66% min-rtt=20ms avg-rtt=34ms 
max-rtt=46ms


I think you may be interested as this issue caught me in a 
troubleshooting session introducing strangeness and might do the same to 
you too :)

Bye,
