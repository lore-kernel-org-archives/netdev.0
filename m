From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 1/5] be2net: allow register dump only for PFs
Date: Mon, 18 Apr 2011 17:29:54 -0500
Message-ID: <20110418222954.GA9467@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:45942 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752800Ab1DRWaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 18:30:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_ethtool.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 28716a6..22523b9 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -161,7 +161,9 @@ be_get_reg_len(struct net_device *netdev)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	u32 log_size = 0;
 
-	be_cmd_get_reg_len(adapter, &log_size);
+	if (be_physfn(adapter))
+		be_cmd_get_reg_len(adapter, &log_size);
+
 	return log_size;
 }
 
@@ -170,8 +172,10 @@ be_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *buf)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
-	memset(buf, 0, regs->len);
-	be_cmd_get_regs(adapter, regs->len, buf);
+	if (be_physfn(adapter)) {
+		memset(buf, 0, regs->len);
+		be_cmd_get_regs(adapter, regs->len, buf);
+	}
 }
 
 static int
-- 
1.7.1

