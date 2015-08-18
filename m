From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 1/4] vrf: drop unnecessary dev refcnt changes
Date: Tue, 18 Aug 2015 20:28:01 +0300
Message-ID: <1439918884-13681-2-git-send-email-razor@blackwall.org>
References: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36529 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbbHRT3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 15:29:10 -0400
Received: by wicja10 with SMTP id ja10so102835410wic.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 12:29:09 -0700 (PDT)
In-Reply-To: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

netdev_master_upper_dev_link/unlink already do a dev_hold/put on the
devices being linked, so no need to take another reference.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/vrf.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 95097cb79354..cd4bc77f2e04 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -334,14 +334,12 @@ static struct slave *__vrf_find_slave_dev(struct slave_queue *queue,
 /* inverse of __vrf_insert_slave */
 static void __vrf_remove_slave(struct slave_queue *queue, struct slave *slave)
 {
-	dev_put(slave->dev);
 	list_del(&slave->list);
 	queue->num_slaves--;
 }
 
 static void __vrf_insert_slave(struct slave_queue *queue, struct slave *slave)
 {
-	dev_hold(slave->dev);
 	list_add(&slave->list, &queue->all_slaves);
 	queue->num_slaves++;
 }
-- 
2.4.3
