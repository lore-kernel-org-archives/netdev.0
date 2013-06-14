From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: [PATCH net-next 5/5] staging/rtl8192u: convert skb->tail into skb_tail_pointer(skb)
Date: Fri, 14 Jun 2013 17:58:35 +0900
Message-ID: <4e2318187b15be4d81c3b03cd0337506c7008bb8.1371200138.git.yamahata@valinux.co.jp>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
Cc: yamahata@valinux.co.jp, Simon Horman <horms@verge.net.au>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devel@driverdev.osuosl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:39015 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512Ab3FNI6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 04:58:37 -0400
In-Reply-To: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
In-Reply-To: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change set of 7a884dc "[SK_BUFF]: Convert skb->tail to sk_buff_data_t"
converted skb->tail from pointer into sk_buff_data_t.
Thus skb->tail is not always pointer, the area pointed by skb->tail
should be accessed via skb_tail_pointer().

Found by inspection. Compile tested only.

Cc: Simon Horman <horms@verge.net.au>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 drivers/staging/rtl8192u/r8192U_core.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/rtl8192u/r8192U_core.c b/drivers/staging/rtl8192u/r8192U_core.c
index 71f5cde..a18430e 100644
--- a/drivers/staging/rtl8192u/r8192U_core.c
+++ b/drivers/staging/rtl8192u/r8192U_core.c
@@ -1271,8 +1271,8 @@ struct sk_buff *DrvAggr_Aggregation(struct net_device *dev, struct ieee80211_drv
 		/* Subframe drv Tx descriptor and firmware info setting */
 		skb = pSendList->tx_agg_frames[i];
 		tcb_desc = (cb_desc *)(skb->cb + MAX_DEV_ADDR_SIZE);
-		tx_agg_desc = (tx_desc_819x_usb_aggr_subframe *)agg_skb->tail;
-		tx_fwinfo = (tx_fwinfo_819x_usb *)(agg_skb->tail + sizeof(tx_desc_819x_usb_aggr_subframe));
+		tx_agg_desc = (tx_desc_819x_usb_aggr_subframe *)skb_tail_pointer(agg_skb);
+		tx_fwinfo = (tx_fwinfo_819x_usb *)(skb_tail_pointer(agg_skb) + sizeof(tx_desc_819x_usb_aggr_subframe));
 
 		memset(tx_fwinfo,0,sizeof(tx_fwinfo_819x_usb));
 		/* DWORD 0 */
-- 
1.7.10.4
