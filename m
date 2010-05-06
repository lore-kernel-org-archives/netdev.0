From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH 2/8] 3c523: Remove unnecessary memset of netdev private data
Date: Thu,  6 May 2010 17:39:46 +0200
Message-ID: <1273160386-12845-1-git-send-email-tklauser@distanz.ch>
Cc: kernel-janitors@vger.kernel.org,
	Tobias Klauser <tklauser@distanz.ch>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:46741 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758835Ab0EFPjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 11:39:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The memory for the private data is allocated using kzalloc in
alloc_etherdev (or alloc_netdev_mq respectively) so there is no need to
set it to 0 again.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/3c523.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 8c70686..55d219e 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -503,7 +503,6 @@ static int __init do_elmc_probe(struct net_device *dev)
 		break;
 	}
 
-	memset(pr, 0, sizeof(struct priv));
 	pr->slot = slot;
 
 	pr_info("%s: 3Com 3c523 Rev 0x%x at %#lx\n", dev->name, (int) revision,
-- 
1.6.3.3

