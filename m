From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH 1/8] 3c507: Remove unnecessary memset of netdev private data
Date: Thu,  6 May 2010 17:39:11 +0200
Message-ID: <1273160351-12710-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org,
	Tobias Klauser <tklauser@distanz.ch>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:46707 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755564Ab0EFPjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 11:39:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for the private data is allocated using kzalloc in
alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
set it to 0 again.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/3c507.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index b32b7a1..9e95afa 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -449,7 +449,6 @@ static int __init el16_probe1(struct net_device *dev, int ioaddr)
 		pr_debug("%s", version);
 
 	lp = netdev_priv(dev);
- 	memset(lp, 0, sizeof(*lp));
 	spin_lock_init(&lp->lock);
 	lp->base = ioremap(dev->mem_start, RX_BUF_END);
 	if (!lp->base) {
-- 
1.6.3.3

