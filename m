From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: SFQ depth limit
Date: Sat, 28 Jun 2008 22:02:59 +0300
Message-ID: <200806282202.59581.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:41896 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbYF1TDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2008 15:03:02 -0400
Received: from localhost (unknown [195.69.208.251])
	by relay2.globalproof.net (Postfix) with ESMTP id A2B2C130506
	for <netdev@vger.kernel.org>; Sat, 28 Jun 2008 22:02:56 +0300 (EEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Is there any particular reason to limit SFQ depth to 127 packets?
#define SFQ_DEPTH               128

Just to buffer data on 1Gbps rate for 1 second i need 87k packets, let's say just for 10ms buffer - 873 packets, which is out of limit.
Also if i will use external SFQ flow classifier made by Patrick McHardy, let's say for 4096 ip's, i am not sure also if i hit this limit. 
As i understand, if i increase it - it will increase also data structures size in memory.

And probably i hit some unknown issue.
Example:
tc qdisc add dev eth0 handle 1 root sfq
tc filter add dev eth0 protocol ip pref 1 parent 1: handle 1 flow hash keys dst divisor 1024
MegaRouterCore-KARAM ~ #tc -s qdisc show dev eth0
qdisc sfq 1: root limit 127p quantum 1514b
 Sent 12062 bytes 89 pkt (dropped 3, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
MegaRouterCore-KARAM ~ #tc -s qdisc show dev eth0
qdisc sfq 1: root limit 127p quantum 1514b
 Sent 12824 bytes 94 pkt (dropped 3, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
MegaRouterCore-KARAM ~ #tc -s qdisc show dev eth0
qdisc sfq 1: root limit 127p quantum 1514b
 Sent 13586 bytes 99 pkt (dropped 3, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
MegaRouterCore-KARAM ~ #tc -s -d qdisc show dev eth0
qdisc sfq 1: root limit 127p quantum 1514b flows 127/1024
 Sent 15552 bytes 114 pkt (dropped 8, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
MegaRouterCore-KARAM ~ #tc -s -d qdisc show dev eth0
qdisc sfq 1: root limit 127p quantum 1514b flows 127/1024
 Sent 16232 bytes 118 pkt (dropped 9, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

after that host is dead...



-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
