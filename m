From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 01/13] bna: Add software PTP support
Date: Wed, 20 Nov 2013 21:54:05 -0800
Message-ID: <1385013257-32745-2-git-send-email-rmody@brocade.com>
References: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:6272 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750782Ab3KUGZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:25:48 -0500
In-Reply-To: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 - Invoke skb_tx_timestamp() API just before invoking txq_doorbell()
 - Add ethtool (-T) support

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c         | 2 ++
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index f276433..9b1c550 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2911,6 +2911,8 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	if (unlikely(!test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags)))
 		return NETDEV_TX_OK;
 
+	skb_tx_timestamp(skb);
+
 	bna_txq_prod_indx_doorbell(tcb);
 	smp_mb();
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 455b5a2..f9e1508 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -1131,6 +1131,7 @@ static const struct ethtool_ops bnad_ethtool_ops = {
 	.get_eeprom = bnad_get_eeprom,
 	.set_eeprom = bnad_set_eeprom,
 	.flash_device = bnad_flash_device,
+	.get_ts_info = ethtool_op_get_ts_info,
 };
 
 void
-- 
1.8.2.3
