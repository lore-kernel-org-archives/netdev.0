From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 3/4] vrf: don't check for dstats and rth in uninit path
Date: Tue, 18 Aug 2015 20:28:03 +0300
Message-ID: <1439918884-13681-4-git-send-email-razor@blackwall.org>
References: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36555 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120AbbHRT3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 15:29:12 -0400
Received: by wicja10 with SMTP id ja10so102836155wic.1
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 12:29:11 -0700 (PDT)
In-Reply-To: <1439918884-13681-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

dstats and rth are always present because we fail the device registration
if they can't be allocated in vrf_init() (ndo_init) so drop the unnecessary
checks.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/vrf.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 3d7da0c6f827..97605eab14ae 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -265,8 +265,7 @@ static void vrf_rtable_destroy(struct net_vrf *vrf)
 {
 	struct dst_entry *dst = (struct dst_entry *)vrf->rth;
 
-	if (dst)
-		dst_destroy(dst);
+	dst_destroy(dst);
 	vrf->rth = NULL;
 }
 
@@ -455,8 +454,7 @@ static void vrf_dev_uninit(struct net_device *dev)
 	list_for_each_entry_safe(slave, next, head, list)
 		vrf_del_slave(dev, slave->dev);
 
-	if (dev->dstats)
-		free_percpu(dev->dstats);
+	free_percpu(dev->dstats);
 	dev->dstats = NULL;
 }
 
-- 
2.4.3
