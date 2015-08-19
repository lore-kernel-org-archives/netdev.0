From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 2/4] vrf: remove unnecessary duplicate check
Date: Wed, 19 Aug 2015 06:27:08 +0300
Message-ID: <1439954830-24947-3-git-send-email-razor@blackwall.org>
References: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37335 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbbHSPAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 11:00:49 -0400
Received: by wibhh20 with SMTP id hh20so11017269wib.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 08:00:48 -0700 (PDT)
In-Reply-To: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

The upper/lower functions already check for duplicate slaves so no need
to do it again.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/vrf.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 01dc91562a88..9907550ff640 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -352,7 +352,6 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
 	struct net_vrf_dev *vrf_ptr = kmalloc(sizeof(*vrf_ptr), GFP_KERNEL);
 	struct slave *slave = kzalloc(sizeof(*slave), GFP_KERNEL);
-	struct slave *duplicate_slave;
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct slave_queue *queue = &vrf->queue;
 	int ret = -ENOMEM;
@@ -361,16 +360,9 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 		goto out_fail;
 
 	slave->dev = port_dev;
-
 	vrf_ptr->ifindex = dev->ifindex;
 	vrf_ptr->tb_id = vrf->tb_id;
 
-	duplicate_slave = __vrf_find_slave_dev(queue, port_dev);
-	if (duplicate_slave) {
-		ret = -EBUSY;
-		goto out_fail;
-	}
-
 	__vrf_insert_slave(queue, slave);
 
 	/* register the packet handler for slave ports */
-- 
2.4.3
