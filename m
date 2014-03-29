From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 17/17] wimax/i2400m: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:30 +0100
Message-ID: <3e64f1d5361be172537b011dba68898e61f3280c.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60881 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbaC2L0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 07:26:53 -0400
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
---
 drivers/net/wimax/i2400m/netdev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 4889613..a9970f1 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -374,8 +374,7 @@ netdev_tx_t i2400m_hard_start_xmit(struct sk_buff *skb,
 
 	d_fnstart(3, dev, "(skb %p net_dev %p)\n", skb, net_dev);
 
-	if (skb_header_cloned(skb) && 
-	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+	if (skb_cow_head(skb, 0))
 		goto drop;
 
 	if (i2400m->state == I2400M_SS_IDLE)
-- 
1.9.0
