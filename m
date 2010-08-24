From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 3/4] cxgb4: fix setting of the function number in transmit descriptors
Date: Mon, 23 Aug 2010 20:21:00 -0700
Message-ID: <1282620061-32608-4-git-send-email-dm@chelsio.com>
References: <1282620061-32608-1-git-send-email-dm@chelsio.com>
 <1282620061-32608-2-git-send-email-dm@chelsio.com>
 <1282620061-32608-3-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8714 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895Ab0HXD2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:28:21 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o7O3SLMA022367
	for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 20:28:21 -0700
In-Reply-To: <1282620061-32608-3-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/sge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 44c2e6c..6ddb3bb 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -975,7 +975,7 @@ out_free:	dev_kfree_skb(skb);
 	}
 
 	cpl->ctrl0 = htonl(TXPKT_OPCODE(CPL_TX_PKT_XT) |
-			   TXPKT_INTF(pi->tx_chan) | TXPKT_PF(0));
+			   TXPKT_INTF(pi->tx_chan) | TXPKT_PF(adap->fn));
 	cpl->pack = htons(0);
 	cpl->len = htons(skb->len);
 	cpl->ctrl1 = cpu_to_be64(cntrl);
-- 
1.5.4

