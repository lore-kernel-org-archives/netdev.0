From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 7/8] amd-xgbe-phy: Print out the auto-negotiation
 method used
Date: Tue, 29 Jul 2014 08:57:49 -0500
Message-ID: <20140729135749.2791.30684.stgit@tlendack-t1.amdoffice.net>
References: <20140729135707.2791.75918.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0185.outbound.protection.outlook.com ([207.46.163.185]:1924
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753807AbaG2N5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 09:57:53 -0400
In-Reply-To: <20140729135707.2791.75918.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a netdev_info statement detailing whether auto-negotiation was
completed through parallel detection or through the auto-negotiation
protocol.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index 39428e5..388e302 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -857,6 +857,7 @@ static void amd_xgbe_an_state_machine(struct work_struct *work)
 	struct phy_device *phydev = priv->phydev;
 	enum amd_xgbe_phy_an cur_state;
 	int sleep;
+	unsigned int an_supported = 0;
 
 	while (1) {
 		mutex_lock(&priv->an_mutex);
@@ -866,6 +867,7 @@ static void amd_xgbe_an_state_machine(struct work_struct *work)
 		switch (priv->an_state) {
 		case AMD_XGBE_AN_START:
 			priv->an_state = amd_xgbe_an_start(phydev);
+			an_supported = 0;
 			break;
 
 		case AMD_XGBE_AN_EVENT:
@@ -874,6 +876,7 @@ static void amd_xgbe_an_state_machine(struct work_struct *work)
 
 		case AMD_XGBE_AN_PAGE_RECEIVED:
 			priv->an_state = amd_xgbe_an_page_received(phydev);
+			an_supported++;
 			break;
 
 		case AMD_XGBE_AN_INCOMPAT_LINK:
@@ -881,6 +884,11 @@ static void amd_xgbe_an_state_machine(struct work_struct *work)
 			break;
 
 		case AMD_XGBE_AN_COMPLETE:
+			netdev_info(phydev->attached_dev, "%s successful\n",
+				    an_supported ? "Auto negotiation"
+						 : "Parallel detection");
+			/* fall through */
+
 		case AMD_XGBE_AN_NO_LINK:
 		case AMD_XGBE_AN_EXIT:
 			goto exit_unlock;
