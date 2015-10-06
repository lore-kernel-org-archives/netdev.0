From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH RFC v1 7/7] net/faraday: Enable offload checksum according to device-tree
Date: Tue,  6 Oct 2015 14:09:49 +1100
Message-ID: <1444100989-3437-8-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1444100989-3437-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, davem@davemloft.net,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp05.au.ibm.com ([202.81.31.147]:57834 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbbJFDuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 23:50:55 -0400
Received: from /spool/local
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Tue, 6 Oct 2015 13:50:53 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id B0D5E2CE8055
	for <netdev@vger.kernel.org>; Tue,  6 Oct 2015 14:50:51 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t963ohPT47186040
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 14:50:51 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t963oIaC008246
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 14:50:19 +1100
In-Reply-To: <1444100989-3437-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables IP/UDP/TCP offload checksum according to information
passed on from bootloader through device-tree. The offload doesn't
working properly when the interface works in NCSI mode.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 1b13fd4..8caed35 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1377,7 +1377,11 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	netdev->ethtool_ops = &ftgmac100_ethtool_ops;
 	netdev->netdev_ops = &ftgmac100_netdev_ops;
-	netdev->features = NETIF_F_IP_CSUM | NETIF_F_GRO;
+	if (pdev->dev.of_node &&
+	    of_get_property(pdev->dev.of_node, "no-hw-checksum", NULL))
+		netdev->features = NETIF_F_GRO;
+	else
+		netdev->features = NETIF_F_IP_CSUM | NETIF_F_GRO;
 
 	platform_set_drvdata(pdev, netdev);
 
-- 
2.1.0
