From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 1/2] qede: Don't override priv_flags
Date: Mon, 31 Oct 2016 22:26:53 +0200
Message-ID: <1477945614-29133-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1477945614-29133-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:57063 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S946177AbcJaU1E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:27:04 -0400
In-Reply-To: <1477945614-29133-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver is now setting the ndev's priv_flags instead of adding to it,
causing pktgen failure to utilize various features due to the loss
of the IFF_TX_SKB_SHARING indication.

Fixes: 7b7e70f979e3 ("qed*: Allow unicast filtering")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 873f2eb..df02c45 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2366,7 +2366,7 @@ static void qede_init_ndev(struct qede_dev *edev)
 
 	qede_set_ethtool_ops(ndev);
 
-	ndev->priv_flags = IFF_UNICAST_FLT;
+	ndev->priv_flags |= IFF_UNICAST_FLT;
 
 	/* user-changeble features */
 	hw_features = NETIF_F_GRO | NETIF_F_SG |
-- 
1.9.3
