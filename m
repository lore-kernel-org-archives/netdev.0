From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [RESEND PATCH 4/4] stmmac: convert unicast addr list to list_head
Date: Wed, 16 Dec 2009 08:26:45 +0100
Message-ID: <1260948405-28511-4-git-send-email-peppe.cavallaro@st.com>
References: <1260948405-28511-1-git-send-email-peppe.cavallaro@st.com>
 <1260948405-28511-2-git-send-email-peppe.cavallaro@st.com>
 <1260948405-28511-3-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:54246 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934635AbZLPH1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 02:27:20 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4BA4B76
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 07:27:17 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 1B82B731
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 07:27:17 +0000 (GMT)
In-Reply-To: <1260948405-28511-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts unicast address list to standard list_head using
previously introduced struct netdev_hw_addr.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/dwmac1000_core.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
index 3752e1e..e109bea 100644
--- a/drivers/net/stmmac/dwmac1000_core.c
+++ b/drivers/net/stmmac/dwmac1000_core.c
@@ -83,7 +83,7 @@ static void gmac_set_filter(struct net_device *dev)
 	unsigned int value = 0;
 
 	DBG(KERN_INFO "%s: # mcasts %d, # unicast %d\n",
-	    __func__, dev->mc_count, dev->uc_count);
+	    __func__, dev->mc_count, dev->uc.count);
 
 	if (dev->flags & IFF_PROMISC)
 		value = GMAC_FRAME_FILTER_PR;
@@ -117,17 +117,16 @@ static void gmac_set_filter(struct net_device *dev)
 	}
 
 	/* Handle multiple unicast addresses (perfect filtering)*/
-	if (dev->uc_count > GMAC_MAX_UNICAST_ADDRESSES)
+	if (dev->uc.count > GMAC_MAX_UNICAST_ADDRESSES)
 		/* Switch to promiscuous mode is more than 16 addrs
 		   are required */
 		value |= GMAC_FRAME_FILTER_PR;
 	else {
-		int i;
-		struct dev_addr_list *uc_ptr = dev->uc_list;
+		int i = 0;
+		struct netdev_hw_addr *ha;
 
-			for (i = 0; i < dev->uc_count; i++) {
-				gmac_set_umac_addr(ioaddr, uc_ptr->da_addr,
-						i + 1);
+			list_for_each_entry(ha, &dev->uc.list, list) {
+				gmac_set_umac_addr(ioaddr, ha->addr, i + 1);
 
 				DBG(KERN_INFO "\t%d "
 				"- Unicast addr %02x:%02x:%02x:%02x:%02x:"
@@ -135,7 +134,8 @@ static void gmac_set_filter(struct net_device *dev)
 				uc_ptr->da_addr[0], uc_ptr->da_addr[1],
 				uc_ptr->da_addr[2], uc_ptr->da_addr[3],
 				uc_ptr->da_addr[4], uc_ptr->da_addr[5]);
-				uc_ptr = uc_ptr->next;
+
+				i++;
 		}
 	}
 
-- 
1.6.0.4

