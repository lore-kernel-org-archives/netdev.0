From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/14] tipc: Eliminate useless linked list initialization
Date: Tue, 17 Aug 2010 17:00:13 -0400
Message-ID: <1282078816-11844-12-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57142 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab0HQVA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:28 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminate the initialization of the port_list field of a newly created
TIPC port, since the port is immediately added to TIPC's global list
of ports (which alters the port_list field).

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index ebcbc21..4f4f763 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -253,7 +253,6 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 	k_init_timer(&p_ptr->timer, (Handler)port_timeout, ref);
 	spin_lock_bh(&tipc_port_list_lock);
 	INIT_LIST_HEAD(&p_ptr->publications);
-	INIT_LIST_HEAD(&p_ptr->port_list);
 	list_add_tail(&p_ptr->port_list, &ports);
 	spin_unlock_bh(&tipc_port_list_lock);
 	return &(p_ptr->publ);
-- 
1.7.2.1

