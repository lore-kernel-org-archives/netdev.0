From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 4/4] sis190: scheduling while atomic error
Date: Mon, 10 Dec 2007 23:31:59 +0100
Message-ID: <20071210223159.GE8675@electric-eye.fr.zoreil.com>
References: <20071210222732.GA8675@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"K.M. Liu" <kmliu@sis.com.tw>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50918 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751818AbXLJWi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 17:38:26 -0500
Content-Disposition: inline
In-Reply-To: <20071210222732.GA8675@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sis190_tx_timeout
-> sis190_hw_start
   -> sis190_soft_reset
      -> msleep *splat*

PCI transactions are correctly flushed here.
The msleep() is probably useless.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: K.M. Liu <kmliu@sis.com.tw>
---
 drivers/net/sis190.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 973b369..c0db182 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -847,10 +847,8 @@ static void sis190_soft_reset(void __iomem *ioaddr)
 {
 	SIS_W32(IntrControl, 0x8000);
 	SIS_PCI_COMMIT();
-	msleep(1);
 	SIS_W32(IntrControl, 0x0);
 	sis190_asic_down(ioaddr);
-	msleep(1);
 }
 
 static void sis190_hw_start(struct net_device *dev)
-- 
1.5.3.3

