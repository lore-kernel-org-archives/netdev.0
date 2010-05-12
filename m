From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/16] tipc: Eliminate obsolete port's "congested_link" field
Date: Tue, 11 May 2010 20:30:03 -0400
Message-ID: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35209 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366Ab0ELAaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:25 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UOWT000084
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:24 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminate a field of the TIPC port structure that is populated,
but never referenced.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    2 --
 net/tipc/port.c |    1 -
 net/tipc/port.h |    2 --
 3 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index c76e82e..0b86f6a 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -561,7 +561,6 @@ static int link_schedule_port(struct link *l_ptr, u32 origport, u32 sz)
 			goto exit;
 		if (!list_empty(&p_ptr->wait_list))
 			goto exit;
-		p_ptr->congested_link = l_ptr;
 		p_ptr->publ.congested = 1;
 		p_ptr->waiting_pkts = 1 + ((sz - 1) / link_max_pkt(l_ptr));
 		list_add_tail(&p_ptr->wait_list, &l_ptr->waiting_ports);
@@ -592,7 +591,6 @@ void tipc_link_wakeup_ports(struct link *l_ptr, int all)
 		if (win <= 0)
 			break;
 		list_del_init(&p_ptr->wait_list);
-		p_ptr->congested_link = NULL;
 		spin_lock_bh(p_ptr->publ.lock);
 		p_ptr->publ.congested = 0;
 		p_ptr->wakeup(&p_ptr->publ);
diff --git a/net/tipc/port.c b/net/tipc/port.c
index e70d27e..c703ecb 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -247,7 +247,6 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 	p_ptr->sent = 1;
 	INIT_LIST_HEAD(&p_ptr->wait_list);
 	INIT_LIST_HEAD(&p_ptr->subscription.nodesub_list);
-	p_ptr->congested_link = NULL;
 	p_ptr->dispatcher = dispatcher;
 	p_ptr->wakeup = wakeup;
 	p_ptr->user_port = NULL;
diff --git a/net/tipc/port.h b/net/tipc/port.h
index ff31ee4..8d1652a 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -75,7 +75,6 @@ struct user_port {
  * @wakeup: ptr to routine to call when port is no longer congested
  * @user_port: ptr to user port associated with port (if any)
  * @wait_list: adjacent ports in list of ports waiting on link congestion
- * @congested_link: ptr to congested link port is waiting on
  * @waiting_pkts:
  * @sent:
  * @acked:
@@ -95,7 +94,6 @@ struct port {
 	void (*wakeup)(struct tipc_port *);
 	struct user_port *user_port;
 	struct list_head wait_list;
-	struct link *congested_link;
 	u32 waiting_pkts;
 	u32 sent;
 	u32 acked;
-- 
1.7.1.rc2

