From: Barry Grussling <barry@grussling.com>
Subject: [PATCH V2 3/4] DSA: Convert printk calls to netdev_info calls
Date: Tue,  8 Jan 2013 18:05:55 -0800
Message-ID: <1357697156-5767-4-git-send-email-barry@grussling.com>
References: <1357697156-5767-1-git-send-email-barry@grussling.com>
Cc: Barry Grussling <barry@grussling.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:64797 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab3AICGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 21:06:17 -0500
Received: by mail-pb0-f42.google.com with SMTP id rp2so617488pbb.1
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 18:06:17 -0800 (PST)
In-Reply-To: <1357697156-5767-1-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barry Grussling <barry@grussling.com>

Convert DSA printk calls to netdev_info calls as recommended by
checkpatch.pl.

Signed-off-by: Barry Grussling <barry@grussling.com>
---
 drivers/net/dsa/mv88e6060.c |   11 ++++++-----
 drivers/net/dsa/mv88e6xxx.c |   11 ++++++-----
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 8548f8d..7a54ec0 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -236,7 +236,7 @@ static void mv88e6060_poll_link(struct dsa_switch *ds)
 
 		if (!link) {
 			if (netif_carrier_ok(dev)) {
-				printk(KERN_INFO "%s: link down\n", dev->name);
+				netdev_info(dev, "link down\n");
 				netif_carrier_off(dev);
 			}
 			continue;
@@ -247,10 +247,11 @@ static void mv88e6060_poll_link(struct dsa_switch *ds)
 		fc = ((port_status & 0xc000) == 0xc000) ? 1 : 0;
 
 		if (!netif_carrier_ok(dev)) {
-			printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex, "
-					 "flow control %sabled\n", dev->name,
-					 speed, duplex ? "full" : "half",
-					 fc ? "en" : "dis");
+			netdev_info(dev,
+				    "link up, %d Mb/s, %s duplex, flow control %sabled\n",
+				    speed,
+				    duplex ? "full" : "half",
+				    fc ? "en" : "dis");
 			netif_carrier_on(dev);
 		}
 	}
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index afe7d80..3756c74 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -356,7 +356,7 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 
 		if (!link) {
 			if (netif_carrier_ok(dev)) {
-				printk(KERN_INFO "%s: link down\n", dev->name);
+				netdev_info(dev, "link down\n");
 				netif_carrier_off(dev);
 			}
 			continue;
@@ -380,10 +380,11 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 		fc = (port_status & 0x8000) ? 1 : 0;
 
 		if (!netif_carrier_ok(dev)) {
-			printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex, "
-					 "flow control %sabled\n", dev->name,
-					 speed, duplex ? "full" : "half",
-					 fc ? "en" : "dis");
+			netdev_info(dev,
+				    "link up, %d Mb/s, %s duplex, flow control %sabled\n",
+				    speed,
+				    duplex ? "full" : "half",
+				    fc ? "en" : "dis");
 			netif_carrier_on(dev);
 		}
 	}
-- 
1.7.9.5
