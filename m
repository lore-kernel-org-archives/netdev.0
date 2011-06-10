From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 10/10] smsc9420: enable transmit time stamping.
Date: Fri, 10 Jun 2011 17:07:08 +0200
Message-ID: <26bd81f0763a33d35d867d5eb36ac44dc2d88d3a.1307717675.git.richard.cochran@omicron.at>
References: <cover.1307717675.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57323 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757512Ab1FJPHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 11:07:51 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so2260711bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 08:07:50 -0700 (PDT)
In-Reply-To: <cover.1307717675.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1307717675.git.richard.cochran@omicron.at>
References: <cover.1307717675.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping
for the smsc9420. Compile tested only.

Cc: Steve Glendinning <steve.glendinning@smsc.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/smsc9420.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smsc9420.c b/drivers/net/smsc9420.c
index 4c92ad8..2d84f92 100644
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -1034,6 +1034,8 @@ static netdev_tx_t smsc9420_hard_start_xmit(struct sk_buff *skb,
 	smsc9420_reg_write(pd, TX_POLL_DEMAND, 1);
 	smsc9420_pci_flush_write(pd);
 
+	skb_tx_timestamp(skb);
+
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.0.4

