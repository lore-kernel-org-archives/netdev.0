From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH RFC 6/6] net/faraday: Enable offload checksum according to device-tree
Date: Mon,  9 Nov 2015 11:10:06 +1100
Message-ID: <1447027806-4744-7-git-send-email-gwshan@linux.vnet.ibm.com>
References: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com,
	Gavin Shan <gwshan@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:45623 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbbKIALO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 19:11:14 -0500
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
	Mon, 9 Nov 2015 10:11:11 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 422673578056
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 11:11:09 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tA90AkDt33620128
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:10:54 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tA90AZXh027067
	for <netdev@vger.kernel.org>; Mon, 9 Nov 2015 11:10:36 +1100
In-Reply-To: <1447027806-4744-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables IP/UDP/TCP offload checksum according to information
passed on from bootloader through device-tree. The offload doesn't
working properly when the interface works in NCSI mode.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 1b13fd4..1e2f4d2 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1377,7 +1377,10 @@ static int ftgmac100_probe(struct platform_device *pdev)
 
 	netdev->ethtool_ops = &ftgmac100_ethtool_ops;
 	netdev->netdev_ops = &ftgmac100_netdev_ops;
-	netdev->features = NETIF_F_IP_CSUM | NETIF_F_GRO;
+	netdev->features = NETIF_F_GRO;
+	if (pdev->dev.of_node &&
+	    of_property_read_bool(pdev->dev.of_node, "no-hw-checksum"))
+		netdev->features |= NETIF_F_IP_CSUM;
 
 	platform_set_drvdata(pdev, netdev);
 
-- 
2.1.0
