From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/26] tipc: Correct broadcast link peer info when displaying links
Date: Sun, 13 Mar 2011 17:33:50 -0400
Message-ID: <1300052054-7531-3-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49851 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755331Ab1CMVeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:31 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Fixes a typo in the calculation of the network address of a node's own
cluster when generating a response to the configuration command that
lists all of the node's links. The correct mask value for a <Z.C.N>
network address uses 1's for the 8-bit zone and 12-bit cluster parts
and 0's for the 12-bit node part.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/node.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index e4dba1d..d040d47 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -470,7 +470,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 
 	/* Add TLV for broadcast link */
 
-	link_info.dest = htonl(tipc_own_addr & 0xfffff00);
+	link_info.dest = htonl(tipc_own_addr & 0xfffff000);
 	link_info.up = htonl(1);
 	strlcpy(link_info.str, tipc_bclink_name, TIPC_MAX_LINK_NAME);
 	tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO, &link_info, sizeof(link_info));
-- 
1.7.3.3

