From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 1/4] network dev read_mostly
Date: Mon, 12 Mar 2007 14:08:18 -0700
Message-ID: <20070312210907.509184287@linux-foundation.org>
References: <20070312210817.485320783@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42387 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752940AbXCLVJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 17:09:33 -0400
Content-Disposition: inline; filename=dev-read-mostly.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For Eric, mark packet type and network device watermarks
as read mostly.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/core/dev.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3f0c468..c82a56b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -146,8 +146,8 @@ #include <linux/ctype.h>
  */
 
 static DEFINE_SPINLOCK(ptype_lock);
-static struct list_head ptype_base[16];	/* 16 way hashed list */
-static struct list_head ptype_all;		/* Taps */
+static struct list_head ptype_base[16] __read_mostly;	/* 16 way hashed list */
+static struct list_head ptype_all __read_mostly;	/* Taps */
 
 #ifdef CONFIG_NET_DMA
 static struct dma_client *net_dma_client;
@@ -1535,9 +1535,9 @@ out:
 			Receiver routines
   =======================================================================*/
 
-int netdev_max_backlog = 1000;
-int netdev_budget = 300;
-int weight_p = 64;            /* old backlog weight */
+int netdev_max_backlog __read_mostly = 1000;
+int netdev_budget __read_mostly = 300;
+int weight_p __read_mostly = 64;            /* old backlog weight */
 
 DEFINE_PER_CPU(struct netif_rx_stats, netdev_rx_stat) = { 0, };
 
-- 
1.4.1

--
Stephen Hemminger <shemminger@linux-foundation.org>

