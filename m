From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] netlink: validate addr_len on bind
Date: Sun, 16 Dec 2012 02:42:19 +0100
Message-ID: <20121216014219.GB1528@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33695 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919Ab2LPBmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2012 20:42:20 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise an out of bounds read could happen.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/netlink/af_netlink.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index fdb7494..5321bab 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -669,6 +669,9 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 	struct sockaddr_nl *nladdr = (struct sockaddr_nl *)addr;
 	int err;
 
+	if (addr_len < sizeof(struct sockaddr_nl))
+		return -EINVAL;
+
 	if (nladdr->nl_family != AF_NETLINK)
 		return -EINVAL;
 
