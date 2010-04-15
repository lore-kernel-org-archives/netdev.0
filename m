From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH 2/2] igbvf: dobule increment nr_frags
Date: Thu, 15 Apr 2010 16:23:40 +0900
Message-ID: <4BC6BEFC.3010309@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:54510 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500Ab0DOHXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 03:23:43 -0400
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F7NfgN022764
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Thu, 15 Apr 2010 16:23:41 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BEFA45DE6E
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:23:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 48D8045DE4D
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:23:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 322E01DB803E
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:23:41 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E231F1DB8037
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:23:40 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to increment nr_frags becasue skb_fill_page_desc increments
it.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 drivers/net/igbvf/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index ea8abf5..97cfc60 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -288,7 +288,7 @@ static bool igbvf_clean_rx_irq(struct igbvf_adapter *adapter,
 			               PCI_DMA_FROMDEVICE);
 			buffer_info->page_dma = 0;
 
-			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags++,
+			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
 			                   buffer_info->page,
 			                   buffer_info->page_offset,
 			                   length);

