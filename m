From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 23/26] tipc: Remove bearer flag indicating existence of broadcast address
Date: Sun, 13 Mar 2011 17:34:11 -0400
Message-ID: <1300052054-7531-24-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49978 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932242Ab1CMVfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:35:01 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates the flag in the TIPC bearer structure that indicates if
the bearer supports broadcasting, since the flag is always set to 1
and serves no useful purpose.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |    7 ++-----
 net/tipc/bearer.h |    2 --
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index c9b5268..411719f 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -158,7 +158,6 @@ int  tipc_register_media(u32 media_type,
 	m_ptr->disable_bearer = disable;
 	m_ptr->addr2str = addr2str;
 	memcpy(&m_ptr->bcast_addr, bcast_addr, sizeof(*bcast_addr));
-	m_ptr->bcast = 1;
 	strcpy(m_ptr->name, name);
 	m_ptr->priority = bearer_priority;
 	m_ptr->tolerance = link_tolerance;
@@ -563,10 +562,8 @@ restart:
 	b_ptr->priority = priority;
 	INIT_LIST_HEAD(&b_ptr->cong_links);
 	INIT_LIST_HEAD(&b_ptr->links);
-	if (m_ptr->bcast) {
-		b_ptr->link_req = tipc_disc_init_link_req(b_ptr, &m_ptr->bcast_addr,
-							  disc_domain);
-	}
+	b_ptr->link_req = tipc_disc_init_link_req(b_ptr, &m_ptr->bcast_addr,
+						  disc_domain);
 	spin_lock_init(&b_ptr->lock);
 	write_unlock_bh(&tipc_net_lock);
 	info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 305b378..31d6172 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -70,7 +70,6 @@ struct tipc_bearer;
  * @disable_bearer: routine which disables a bearer
  * @addr2str: routine which converts bearer's address to string form
  * @bcast_addr: media address used in broadcasting
- * @bcast: non-zero if media supports broadcasting [currently mandatory]
  * @priority: default link (and bearer) priority
  * @tolerance: default time (in ms) before declaring link failure
  * @window: default window (in packets) before declaring link congestion
@@ -87,7 +86,6 @@ struct media {
 	char *(*addr2str)(struct tipc_media_addr *a,
 			  char *str_buf, int str_size);
 	struct tipc_media_addr bcast_addr;
-	int bcast;
 	u32 priority;
 	u32 tolerance;
 	u32 window;
-- 
1.7.3.3

