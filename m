From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/7] e1000e: Use skb_copy_to_linear_data_offset introduced in
	2.6.22
Date: Fri, 08 Aug 2008 18:35:56 -0700
Message-ID: <20080809013556.23913.27881.stgit@localhost.localdomain>
References: <20080809013544.23913.47157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:16589 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbYHIBf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 21:35:57 -0400
In-Reply-To: <20080809013544.23913.47157.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The e1000e driver was based on a version of e1000 prior to acme's
introduction of skb_copy_to_linear_data_offset, and was submitted
after acme went through and coverted all the drivers to use it.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 05b0b2f..efa9445 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -510,9 +510,12 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
 				skb_reserve(new_skb, NET_IP_ALIGN);
-				memcpy(new_skb->data - NET_IP_ALIGN,
-				       skb->data - NET_IP_ALIGN,
-				       length + NET_IP_ALIGN);
+				skb_copy_to_linear_data_offset(new_skb,
+							       -NET_IP_ALIGN,
+							       (skb->data -
+								NET_IP_ALIGN),
+							       (length +
+								NET_IP_ALIGN));
 				/* save the skb in buffer_info as good */
 				buffer_info->skb = skb;
 				skb = new_skb;

