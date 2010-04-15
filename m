From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH 1/2] igb: double increment nr_frags
Date: Thu, 15 Apr 2010 16:20:28 +0900
Message-ID: <4BC6BE3C.6070204@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:54378 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114Ab0DOHUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 03:20:42 -0400
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F7KeEq021358
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Thu, 15 Apr 2010 16:20:40 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 651A245DE54
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:20:40 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F46945DE51
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:20:40 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 14A1C1DB8040
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:20:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B9D0C1DB805B
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:20:39 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to increment nr_frags becasue skb_fill_page_desc increments
it.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
  drivers/net/igb/igb_main.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 78cc742..8bde6c3 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5254,7 +5254,7 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
  				       PAGE_SIZE / 2, PCI_DMA_FROMDEVICE);
  			buffer_info->page_dma = 0;
  
-			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags++,
+			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
  						buffer_info->page,
  						buffer_info->page_offset,
  						length);

