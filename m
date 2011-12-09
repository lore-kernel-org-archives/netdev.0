From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 0/13] Implement dumping udp sockets via sock_diag netlink
Date: Fri, 09 Dec 2011 20:20:49 +0400
Message-ID: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:34336 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785Ab1LIQU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:20:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This is an extension of inet_diag module and the new udp_diag one. Plus
the patch for iproute's ss to dump udp sockets via netlink (applies on top
of previous patch for new NETLINK_SOCK_DIAG API [1]).

The overall idea is:

Patch the inet_diag module so that the protocol level handlers are called
indirectly from the very beginning, not just for getting the tcp_info bits.
Implement the udp_diag module that provides callbacks for IPPROTO_UDP and
IPPROTO_UDPLITE protocols.

The existing inet request packet (inet_diag_req) format used to request for
TCP/DCCP sockets is used for UDP socket as well, although not all the state
bits matter for UDP.

When sending back the reply the existing format (inet_diag_message) is used
as well. Some bits on this struct are meaningless for UDP, but I hope that
setting these to 0 and wasting some space on reply skb worth the saved amount
of new code on both -- the kernel side and the userspace side (i.e. ss tool).
The data that is stored in an nl attribute but doesn't exist for UDP is just
not provided.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

[1] http://www.spinics.net/lists/netdev/msg182467.html
