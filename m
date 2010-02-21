From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH next] eepro: fix netdev_mc_count conversion
Date: Sun, 21 Feb 2010 05:37:16 +0300
Message-ID: <1266719836-22416-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:31997 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756308Ab0BUCh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2010 21:37:29 -0500
Received: by fg-out-1718.google.com with SMTP id e21so62852fga.1
        for <netdev@vger.kernel.org>; Sat, 20 Feb 2010 18:37:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix commit 4cd24eaf0 (net: use netdev_mc_count and netdev_mc_empty when
appropriate)

Cc: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/eepro.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 488bc13..5f73ab2 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -1288,7 +1288,7 @@ set_multicast_list(struct net_device *dev)
 	short ioaddr = dev->base_addr;
 	unsigned short mode;
 	struct dev_mc_list *dmi=dev->mc_list;
-	int mc_count = mc_count;
+	int mc_count = netdev_mc_count(dev);
 
 	if (dev->flags&(IFF_ALLMULTI|IFF_PROMISC) || mc_count > 63)
 	{
-- 
1.7.0

