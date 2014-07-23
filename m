From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: [PATCH net] bnx2x: fix set_setting for some PHYs
Date: Wed, 23 Jul 2014 22:12:57 +0300
Message-ID: <1406142777-24267-1-git-send-email-dkravkov@lb-tlvb-dmitry.il.qlogic.com>
Cc: mschmidt@redhat.com, Yaniv Rosner <Yaniv.Rosner@qlogic.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:63673 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932514AbaGWTNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 15:13:10 -0400
Received: by mail-wi0-f182.google.com with SMTP id d1so2805663wiv.9
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 12:13:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <Yaniv.Rosner@qlogic.com>

Allow set_settings() to complete succesfully even if link is
not estabilished and port type isn't known yet.

Signed-off-by: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index bd0600c..25eddd9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -379,6 +379,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			break;
 		case PORT_FIBRE:
 		case PORT_DA:
+		case PORT_NONE:
 			if (!(bp->port.supported[0] & SUPPORTED_FIBRE ||
 			      bp->port.supported[1] & SUPPORTED_FIBRE)) {
 				DP(BNX2X_MSG_ETHTOOL,
-- 
1.9.3
