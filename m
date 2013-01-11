From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] net: Export __netdev_pick_tx so that it can be used in
 modules
Date: Fri, 11 Jan 2013 10:38:42 -0800
Message-ID: <20130111183842.6152.34578.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27024 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755001Ab3AKSkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2013 13:40:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When testing with FCoE enabled we discovered that I had not exported
__netdev_pick_tx.  As a result ixgbe doesn't build with the RFC patches
applied because ixgbe_select_queue was calling the function.  This change
corrects that build issue by correctly exporting __netdev_pick_tx so it
can be used by modules.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/dev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 95de4c0..d1e8116 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2746,6 +2746,7 @@ u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
 
 	return queue_index;
 }
+EXPORT_SYMBOL(__netdev_pick_tx);
 
 struct netdev_queue *netdev_pick_tx(struct net_device *dev,
 				    struct sk_buff *skb)
