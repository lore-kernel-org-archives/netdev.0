From: Zhao Qiang <qiang.zhao@nxp.com>
Subject: [PATCH] ucc/hdlc: fix two little issue
Date: Tue, 14 Mar 2017 09:38:33 +0800
Message-ID: <1489455513-19239-1-git-send-email-qiang.zhao@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xiaobo.xie@nxp.com>, <netdev@vger.kernel.org>,
        Zhao Qiang <qiang.zhao@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0089.outbound.protection.outlook.com ([104.47.36.89]:4881
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752689AbdCNBwo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 21:52:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. modify bd_status from u32 to u16 in function hdlc_rx_done,
because bd_status register is 16bits
2. write bd_length register before writing bd_status register

Signed-off-by: Zhao Qiang <qiang.zhao@nxp.com>
---
 drivers/net/wan/fsl_ucc_hdlc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index a5045b5..6742ae6 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -381,8 +381,8 @@ static netdev_tx_t ucc_hdlc_tx(struct sk_buff *skb, struct net_device *dev)
 	/* set bd status and length */
 	bd_status = (bd_status & T_W_S) | T_R_S | T_I_S | T_L_S | T_TC_S;
 
-	iowrite16be(bd_status, &bd->status);
 	iowrite16be(skb->len, &bd->length);
+	iowrite16be(bd_status, &bd->status);
 
 	/* Move to next BD in the ring */
 	if (!(bd_status & T_W_S))
@@ -457,7 +457,7 @@ static int hdlc_rx_done(struct ucc_hdlc_private *priv, int rx_work_limit)
 	struct sk_buff *skb;
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	struct qe_bd *bd;
-	u32 bd_status;
+	u16 bd_status;
 	u16 length, howmany = 0;
 	u8 *bdbuffer;
 	int i;
-- 
2.1.0.27.g96db324
