From: Jeremy Jackson <jerj@coplanar.net>
Subject: PF_PACKET or nfnetlink logging of skb->priority
Date: Wed, 18 Feb 2009 15:51:48 -0500
Message-ID: <1234990308.18165.68.camel@ragnarok>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.coplanar.net ([70.47.139.2]:48773 "EHLO
	titan.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbZBRUv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 15:51:59 -0500
Received: from [70.47.139.174] (ragnarok.coplanar.net [70.47.139.174] (may be forged))
	(authenticated bits=0)
	by titan.coplanar.net (8.14.2/8.14.2/Debian-2build1) with ESMTP id n1IKpu4O017425
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 15:51:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems that there is nothing that can capture the skb->priority
outside the kernel. 

There is an iptables *target* "CLASSIFY", which can *set* skb->priority,
but there is no iptables *match* based on it.

tcpdump/pcap/PF_PACKET are oblivious to skb->priority.

netfilter netlink queue can export the skb->mark like the right
mechanism, but it doesn't touch skb->priority anywhere.   Perhaps there
needs to be a another one in include/linux/netfilter/nfnetlink_queue.h:

enum nfqnl_attr_type {
        NFQA_UNSPEC,
        NFQA_PACKET_HDR,
        NFQA_VERDICT_HDR,               /* nfqnl_msg_verdict_hrd */
        NFQA_MARK,   
... etc
	NFQA_SKBPRIORITY

The specific use I'm thinking of now, is troubleshooting priority
queueing with "tc" by being able to log or tcpdump traffic for a
specific qdisc/class.

It might also be nice to be able to tcpdump and/or log packets going
into or out of a specific qdisc/class, but I'd settle for dumping
packets based on skb->priority.

-- 
Jeremy Jackson
Coplanar Networks
(519)489-4903
http://www.coplanar.net
jerj@coplanar.net

