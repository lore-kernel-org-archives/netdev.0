From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/6] qede: Add support for nway_reset
Date: Mon, 30 Nov 2015 12:25:05 +0200
Message-ID: <1448879106-12321-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Sudarsana.Kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:33398 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753613AbbK3K0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 05:26:24 -0500
In-Reply-To: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>

Signed-off-by: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index b90d880..9b0bf12 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -322,6 +322,30 @@ static void qede_set_msglevel(struct net_device *ndev, u32 level)
 					 dp_module, dp_level);
 }
 
+static int qede_nway_reset(struct net_device *dev)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	struct qed_link_output current_link;
+	struct qed_link_params link_params;
+
+	if (!netif_running(dev))
+		return 0;
+
+	memset(&current_link, 0, sizeof(current_link));
+	edev->ops->common->get_link(edev->cdev, &current_link);
+	if (!current_link.link_up)
+		return 0;
+
+	/* Toggle the link */
+	memset(&link_params, 0, sizeof(link_params));
+	link_params.link_up = false;
+	edev->ops->common->set_link(edev->cdev, &link_params);
+	link_params.link_up = true;
+	edev->ops->common->set_link(edev->cdev, &link_params);
+
+	return 0;
+}
+
 static u32 qede_get_link(struct net_device *dev)
 {
 	struct qede_dev *edev = netdev_priv(dev);
@@ -493,6 +517,7 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.get_drvinfo = qede_get_drvinfo,
 	.get_msglevel = qede_get_msglevel,
 	.set_msglevel = qede_set_msglevel,
+	.nway_reset = qede_nway_reset,
 	.get_link = qede_get_link,
 	.get_ringparam = qede_get_ringparam,
 	.set_ringparam = qede_set_ringparam,
-- 
1.9.3
