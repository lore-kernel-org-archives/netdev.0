From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/28] tipc: Display meaningful peer interface name during link creation
Date: Sat, 17 Sep 2011 23:31:59 -0400
Message-ID: <1316316744-29514-4-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49960 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459Ab1IRDcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:42 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Sets the peer interface portion of the name of a newly created link
endpoint to "unknown". This ensures that state and statistics information
can be properly displayed during the time between the link endpoint's
creation and the time handshaking with its peer is completed.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 933764c..4cb500b 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -332,12 +332,12 @@ struct link *tipc_link_create(struct tipc_node *n_ptr,
 
 	l_ptr->addr = peer;
 	if_name = strchr(b_ptr->name, ':') + 1;
-	sprintf(l_ptr->name, "%u.%u.%u:%s-%u.%u.%u:",
+	sprintf(l_ptr->name, "%u.%u.%u:%s-%u.%u.%u:unknown",
 		tipc_zone(tipc_own_addr), tipc_cluster(tipc_own_addr),
 		tipc_node(tipc_own_addr),
 		if_name,
 		tipc_zone(peer), tipc_cluster(peer), tipc_node(peer));
-		/* note: peer i/f is appended to link name by reset/activate */
+		/* note: peer i/f name is updated by reset/activate message */
 	memcpy(&l_ptr->media_addr, media_addr, sizeof(*media_addr));
 	l_ptr->owner = n_ptr;
 	l_ptr->checkpoint = 1;
-- 
1.7.4.4
