From: "jungwon park" <jwpark2@whitecode.co.kr>
Subject: GRO issue with kernel 3.4.94 (icmp fragmentation needed)
Date: Fri, 27 Jun 2014 08:42:05 +0900
Message-ID: <000201cf9198$3cfa3200$b6ee9600$@whitecode.co.kr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.whitecode.co.kr ([211.63.65.34]:33674 "EHLO
	whitecode.co.kr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbaF0AGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 20:06:52 -0400
Received: from WOONG ([210.16.232.11])
	(authenticated bits=0)
	by whitecode.co.kr (8.14.4/8.14.3) with ESMTP id s5QNfYC5014851
	for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 08:41:35 +0900
References: 
In-Reply-To: 
Content-Language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using the linux router is turned on GRO, router send the 'fragmentation
needed' packets to the sender.
and the sender's packets are dropped.
The router seems to handle the larger than MTU(1500) with TCP segments by
GRO.

topology : [Host A] - [Linux Router] - [Host B] kernel : 3.4.94 GRO : on MTU
: 1500

tcpdmp :

10:36:36.592752 IP (tos 0x0, ttl 127, id 15685, offset 0, flags [DF], proto
TCP (6), length 198) x.x.x.x.49512 > x.x.x.x.445: P 908:1066(158) ack 587
win 254
10:36:36.592911 IP (tos 0x0, ttl 128, id 9712, offset 0, flags [DF], proto
TCP (6), length 117) x.x.x.x.445 > x.x.x.x.49512: P 587:664(77) ack 1066 win
252
10:36:36.594552 IP (tos 0x0, ttl 127, id 15686, offset 0, flags [DF], proto
TCP (6), length 390) x.x.x.x.49512 > x.x.x.x.445: P 1066:1416(350) ack 664
win 254
10:36:36.596544 IP (tos 0x0, ttl 128, id 9713, offset 0, flags [DF], proto
TCP (6), length 2960) x.x.x.x.445 > x.x.x.x.49512: . 664:3584(2920) ack 1416
win 251
10:36:36.596566 IP (tos 0xc0, ttl 64, id 8339, offset 0, flags [none], proto
ICMP (1), length 576) x.x.x.x > x.x.x.x: ICMP x.x.x.x unreachable - need to
frag (mtu 1500), length 556
	IP (tos 0x0, ttl 128, id 9713, offset 0, flags [DF], proto TCP (6),
length 2960) x.x.x.x.445 > x.x.x.x.49512:  tcp 2940 [bad hdr length 0 - too
short, < 20][|icmp]

When I turned off GRO, the router operate normally, and there is no problem.
and with 3.4.91 kernel, the router has no problem.

I doubt 'ipv4: ip_forward: fix inverted local_df test' patch.
(http://patchwork.ozlabs.org/patch/345509/)
When I revert this patch, the router has no problem.

(sorry my poor english.)
