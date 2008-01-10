From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/4] ipg: fix Tx completion irq request
Date: Fri, 11 Jan 2008 00:38:31 +0100
Message-ID: <20080110233831.GE13315@electric-eye.fr.zoreil.com>
References: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux@horizon.com, jeff@garzik.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:42959 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754001AbYAJXxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 18:53:18 -0500
Content-Disposition: inline
In-Reply-To: <20080110233508.GA13315@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current logic will only request an ack for the first pending
packet. No irq is triggered as soon as the CPU submits a few
packets a bit quickly.  Let's request an irq for every packet
instead.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ipg.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index b234b29..50f0c17 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1934,10 +1934,7 @@ static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (sp->tenmbpsmode)
 		txfd->tfc |= cpu_to_le64(IPG_TFC_TXINDICATE);
-	else if (!((sp->tx_current - sp->tx_dirty + 1) >
-	    IPG_FRAMESBETWEENTXDMACOMPLETES)) {
-		txfd->tfc |= cpu_to_le64(IPG_TFC_TXDMAINDICATE);
-	}
+	txfd->tfc |= cpu_to_le64(IPG_TFC_TXDMAINDICATE);
 	/* Based on compilation option, determine if FCS is to be
 	 * appended to transmit frame by IPG.
 	 */
-- 
1.5.3.3

