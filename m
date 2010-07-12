From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next] cxgb4: exclude registers with read side effects from register dumps
Date: Sun, 11 Jul 2010 17:28:32 -0700
Message-ID: <1278894512-6358-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:19184 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168Ab0GLA2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 20:28:33 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o6C0SWuG022452
	for <netdev@vger.kernel.org>; Sun, 11 Jul 2010 17:28:32 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few registers have side effects on reads, eg FIFO pointers that
auto advance or mailboxes which change ownership when read.  They are
unsafe to read so exclude them from ethtool register dumps.

Bump ethtool_regs.version to indicate the changed register set.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 110843c..0af6d67 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1050,10 +1050,11 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
  * Return a version number to identify the type of adapter.  The scheme is:
  * - bits 0..9: chip version
  * - bits 10..15: chip revision
+ * - bits 16..23: register dump version
  */
 static inline unsigned int mk_adap_vers(const struct adapter *ap)
 {
-	return 4 | (ap->params.rev << 10);
+	return 4 | (ap->params.rev << 10) | (1 << 16);
 }
 
 static void reg_block_dump(struct adapter *ap, void *buf, unsigned int start,
@@ -1128,7 +1129,9 @@ static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		0xdfc0, 0xdfe0,
 		0xe000, 0xea7c,
 		0xf000, 0x11190,
-		0x19040, 0x19124,
+		0x19040, 0x1906c,
+		0x19078, 0x19080,
+		0x1908c, 0x19124,
 		0x19150, 0x191b0,
 		0x191d0, 0x191e8,
 		0x19238, 0x1924c,
@@ -1141,49 +1144,49 @@ static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		0x1a190, 0x1a1c4,
 		0x1a1fc, 0x1a1fc,
 		0x1e040, 0x1e04c,
-		0x1e240, 0x1e28c,
+		0x1e284, 0x1e28c,
 		0x1e2c0, 0x1e2c0,
 		0x1e2e0, 0x1e2e0,
 		0x1e300, 0x1e384,
 		0x1e3c0, 0x1e3c8,
 		0x1e440, 0x1e44c,
-		0x1e640, 0x1e68c,
+		0x1e684, 0x1e68c,
 		0x1e6c0, 0x1e6c0,
 		0x1e6e0, 0x1e6e0,
 		0x1e700, 0x1e784,
 		0x1e7c0, 0x1e7c8,
 		0x1e840, 0x1e84c,
-		0x1ea40, 0x1ea8c,
+		0x1ea84, 0x1ea8c,
 		0x1eac0, 0x1eac0,
 		0x1eae0, 0x1eae0,
 		0x1eb00, 0x1eb84,
 		0x1ebc0, 0x1ebc8,
 		0x1ec40, 0x1ec4c,
-		0x1ee40, 0x1ee8c,
+		0x1ee84, 0x1ee8c,
 		0x1eec0, 0x1eec0,
 		0x1eee0, 0x1eee0,
 		0x1ef00, 0x1ef84,
 		0x1efc0, 0x1efc8,
 		0x1f040, 0x1f04c,
-		0x1f240, 0x1f28c,
+		0x1f284, 0x1f28c,
 		0x1f2c0, 0x1f2c0,
 		0x1f2e0, 0x1f2e0,
 		0x1f300, 0x1f384,
 		0x1f3c0, 0x1f3c8,
 		0x1f440, 0x1f44c,
-		0x1f640, 0x1f68c,
+		0x1f684, 0x1f68c,
 		0x1f6c0, 0x1f6c0,
 		0x1f6e0, 0x1f6e0,
 		0x1f700, 0x1f784,
 		0x1f7c0, 0x1f7c8,
 		0x1f840, 0x1f84c,
-		0x1fa40, 0x1fa8c,
+		0x1fa84, 0x1fa8c,
 		0x1fac0, 0x1fac0,
 		0x1fae0, 0x1fae0,
 		0x1fb00, 0x1fb84,
 		0x1fbc0, 0x1fbc8,
 		0x1fc40, 0x1fc4c,
-		0x1fe40, 0x1fe8c,
+		0x1fe84, 0x1fe8c,
 		0x1fec0, 0x1fec0,
 		0x1fee0, 0x1fee0,
 		0x1ff00, 0x1ff84,
-- 
1.5.4

