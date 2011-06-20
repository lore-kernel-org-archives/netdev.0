From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 11/11] ucc_geth: enable transmit time stamping.
Date: Mon, 20 Jun 2011 09:51:33 +0200
Message-ID: <847da92acf06bc8b4ab60b1704617bcc71e776c2.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Shlomi Gridish <gridish@freescale.com>,
	Li Yang <leoli@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40854 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216Ab1FTHwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 03:52:06 -0400
Received: by mail-fx0-f46.google.com with SMTP id 17so760782fxm.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 00:52:05 -0700 (PDT)
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1308556146.git.richard.cochran@omicron.at>
References: <cover.1308556146.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping.
Compile tested only.

Cc: Shlomi Gridish <gridish@freescale.com>
Cc: Li Yang <leoli@freescale.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/ucc_geth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index ef04105..3127700 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3165,6 +3165,8 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	ugeth->txBd[txQ] = bd;
 
+	skb_tx_timestamp(skb);
+
 	if (ugeth->p_scheduler) {
 		ugeth->cpucount[txQ]++;
 		/* Indicate to QE that there are more Tx bds ready for
-- 
1.7.0.4

