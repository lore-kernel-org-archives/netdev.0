From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 01/15] be2net: While configuring QOS for VF, pass
 proper domain id
Date: Fri, 11 Feb 2011 17:32:32 -0600
Message-ID: <20110211233232.GA18275@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51104 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756887Ab1BKXci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:32:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While configuring QOS for VFs, the VF number should be translated
to domain number correctly.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 82b2df8..4c73dce 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -820,7 +820,7 @@ static int be_set_vf_tx_rate(struct net_device *netdev,
 		rate = 10000;
 
 	adapter->vf_cfg[vf].vf_tx_rate = rate;
-	status = be_cmd_set_qos(adapter, rate / 10, vf);
+	status = be_cmd_set_qos(adapter, rate / 10, vf + 1);
 
 	if (status)
 		dev_info(&adapter->pdev->dev,
-- 
1.7.1

