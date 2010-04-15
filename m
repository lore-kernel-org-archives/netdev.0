From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH 1/2 resend] igb: dobule increment nr_frags
Date: Thu, 15 Apr 2010 18:06:13 +0900
Message-ID: <4BC6D705.80601@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:59753 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159Ab0DOJGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 05:06:33 -0400
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3F96W84008075
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Thu, 15 Apr 2010 18:06:32 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D487C45DE50
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 18:06:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B3D8745DE4E
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 18:06:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9765BE08004
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 18:06:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CB64E08002
	for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 18:06:31 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previous patch has some mail format problem.
Maybe I've fixed and re-sent.

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

