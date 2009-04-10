From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 1/6] ariadne: convert to net_device_ops
Date: Fri, 10 Apr 2009 07:24:07 +0400
Message-ID: <20090410032407.GA9004@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-m68k@lists.linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:36072 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761730AbZDJDYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 23:24:13 -0400
Received: by fk-out-0910.google.com with SMTP id 18so398056fkq.5
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2009 20:24:11 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/ariadne.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ariadne.c b/drivers/net/ariadne.c
index e1d72e0..6c5826a 100644
--- a/drivers/net/ariadne.c
+++ b/drivers/net/ariadne.c
@@ -155,6 +155,18 @@ static struct zorro_driver ariadne_driver = {
     .remove	= __devexit_p(ariadne_remove_one),
 };
 
+static const struct net_device_ops ariadne_netdev_ops = {
+	.ndo_open		= ariadne_open,
+	.ndo_stop		= ariadne_close,
+	.ndo_start_xmit		= ariadne_start_xmit,
+	.ndo_tx_timeout		= ariadne_tx_timeout,
+	.ndo_get_stats		= ariadne_get_stats,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __devinit ariadne_init_one(struct zorro_dev *z,
 				      const struct zorro_device_id *ent)
 {
@@ -197,13 +209,8 @@ static int __devinit ariadne_init_one(struct zorro_dev *z,
     dev->mem_start = ZTWO_VADDR(mem_start);
     dev->mem_end = dev->mem_start+ARIADNE_RAM_SIZE;
 
-    dev->open = &ariadne_open;
-    dev->stop = &ariadne_close;
-    dev->hard_start_xmit = &ariadne_start_xmit;
-    dev->tx_timeout = &ariadne_tx_timeout;
+    dev->netdev_ops = &ariadne_netdev_ops;;
     dev->watchdog_timeo = 5*HZ;
-    dev->get_stats = &ariadne_get_stats;
-    dev->set_multicast_list = &set_multicast_list;
 
     err = register_netdev(dev);
     if (err) {
