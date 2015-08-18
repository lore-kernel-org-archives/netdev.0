From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 2/4] vrf: drop unused num_slaves member
Date: Tue, 18 Aug 2015 20:28:02 +0300
Message-ID: <1439918884-13681-3-git-send-email-razor@blackwall.org>
References: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34410 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbbHRT3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 15:29:12 -0400
Received: by wicne3 with SMTP id ne3so108919357wic.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 12:29:10 -0700 (PDT)
In-Reply-To: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

slave_queue has a num_slaves member which is unused, drop it.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/vrf.c | 2 --
 include/net/vrf.h | 1 -
 2 files changed, 3 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index cd4bc77f2e04..3d7da0c6f827 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -335,13 +335,11 @@ static struct slave *__vrf_find_slave_dev(struct slave_queue *queue,
 static void __vrf_remove_slave(struct slave_queue *queue, struct slave *slave)
 {
 	list_del(&slave->list);
-	queue->num_slaves--;
 }
 
 static void __vrf_insert_slave(struct slave_queue *queue, struct slave *slave)
 {
 	list_add(&slave->list, &queue->all_slaves);
-	queue->num_slaves++;
 }
 
 static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
diff --git a/include/net/vrf.h b/include/net/vrf.h
index 40e3793c7a05..3bb4af462ed6 100644
--- a/include/net/vrf.h
+++ b/include/net/vrf.h
@@ -24,7 +24,6 @@ struct slave {
 
 struct slave_queue {
 	struct list_head	all_slaves;
-	int			num_slaves;
 };
 
 struct net_vrf {
-- 
2.4.3
