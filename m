From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] igb: double increment nr_frags
Date: Tue, 27 Apr 2010 04:01:19 -0700
Message-ID: <20100427110107.23872.86247.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:39904 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751228Ab0D0LBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 07:01:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>

There is no need to increment nr_frags because skb_fill_page_desc increments
it.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index c19b1e0..a14303a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5248,7 +5248,7 @@ static bool igb_clean_rx_irq_adv(struct igb_q_vector *q_vector,
 				       PAGE_SIZE / 2, PCI_DMA_FROMDEVICE);
 			buffer_info->page_dma = 0;
 
-			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags++,
+			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
 						buffer_info->page,
 						buffer_info->page_offset,
 						length);

