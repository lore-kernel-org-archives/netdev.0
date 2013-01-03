From: Barry Grussling <barry@grussling.com>
Subject: [PATCH 3/4] DSA: Convert printk calls to netdev_info calls
Date: Wed,  2 Jan 2013 17:54:57 -0800
Message-ID: <1357178098-4057-4-git-send-email-barry@grussling.com>
References: <1357178098-4057-1-git-send-email-barry@grussling.com>
To: barry@grussling.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:53962 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752757Ab3ACBzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 20:55:36 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so8344742pad.16
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2013 17:55:35 -0800 (PST)
In-Reply-To: <1357178098-4057-1-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert DSA printk calls to netdev_info calls as recommended by
checkpatch.pl.

Signed-off-by: Barry Grussling <barry@grussling.com>
---
 drivers/net/dsa/mv88e6060.c |    4 ++--
 drivers/net/dsa/mv88e6xxx.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index fa6bc7d..dc8b4c1 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -237,7 +237,7 @@ static void mv88e6060_poll_link(struct dsa_switch *ds)
 
 		if (!link) {
 			if (netif_carrier_ok(dev)) {
-				printk(KERN_INFO "%s: link down\n", dev->name);
+				netdev_info(dev, "%s: link down\n", dev->name);
 				netif_carrier_off(dev);
 			}
 			continue;
@@ -248,7 +248,7 @@ static void mv88e6060_poll_link(struct dsa_switch *ds)
 		fc = ((port_status & 0xc000) == 0xc000) ? 1 : 0;
 
 		if (!netif_carrier_ok(dev)) {
-			printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex, "
+			netdev_info(dev, "%s: link up, %d Mb/s, %s duplex, "
 					 "flow control %sabled\n", dev->name,
 					 speed, duplex ? "full" : "half",
 					 fc ? "en" : "dis");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index a2f9e9b6..5260191 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -366,7 +366,7 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 
 		if (!link) {
 			if (netif_carrier_ok(dev)) {
-				printk(KERN_INFO "%s: link down\n", dev->name);
+				netdev_info(dev, "%s: link down\n", dev->name);
 				netif_carrier_off(dev);
 			}
 			continue;
@@ -390,7 +390,7 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 		fc = (port_status & 0x8000) ? 1 : 0;
 
 		if (!netif_carrier_ok(dev)) {
-			printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex, "
+			netdev_info(dev, "%s: link up, %d Mb/s, %s duplex, "
 					 "flow control %sabled\n", dev->name,
 					 speed, duplex ? "full" : "half",
 					 fc ? "en" : "dis");
-- 
1.7.9.5
