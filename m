From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/23] tipc: Ignore neighbor discovery messages containing invalid address
Date: Tue, 27 Dec 2011 12:39:28 -0500
Message-ID: <1325007582-31610-10-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39397 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795Ab1L0RkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:00 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Adds a check to ensure that TIPC ignores an incoming neighbor discovery
message that specifies an invalid media address as its source. The check
ensures that the source address is a valid, non-broadcast address that
could legally be used by a neighboring link endpoint.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 1ea2d44..420e032 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -130,12 +130,15 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	u32 type = msg_type(msg);
 	int link_fully_up;
 
+	media_addr.broadcast = 1;
 	b_ptr->media->msg2addr(&media_addr, msg_media_addr(msg));
 	buf_discard(buf);
 
 	/* Validate discovery message from requesting node */
 	if (net_id != tipc_net_id)
 		return;
+	if (media_addr.broadcast)
+		return;
 	if (!tipc_addr_domain_valid(dest))
 		return;
 	if (!tipc_addr_node_valid(orig))
-- 
1.7.4.4
