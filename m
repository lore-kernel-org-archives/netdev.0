From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/2] igbvf: double increment nr_frags
Date: Tue, 27 Apr 2010 04:01:39 -0700
Message-ID: <20100427110137.23872.8779.stgit@localhost.localdomain>
References: <20100427110107.23872.86247.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:33379 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751815Ab0D0LB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 07:01:56 -0400
In-Reply-To: <20100427110107.23872.86247.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>

There is no need to increment nr_frags because skb_fill_page_desc increments
it.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igbvf/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index cc23090..9ac3f94 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -289,7 +289,7 @@ static bool igbvf_clean_rx_irq(struct igbvf_adapter *adapter,
 			               PCI_DMA_FROMDEVICE);
 			buffer_info->page_dma = 0;
 
-			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags++,
+			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
 			                   buffer_info->page,
 			                   buffer_info->page_offset,
 			                   length);

