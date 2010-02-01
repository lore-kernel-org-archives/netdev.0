From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH] irda: remove BKL from irnet open function
Date: Mon,  1 Feb 2010 16:18:40 -0200
Message-ID: <1265048321-8097-1-git-send-email-cascardo@holoscopio.com>
Cc: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from liberdade.minaslivre.org ([72.232.254.139]:37183 "EHLO
	liberdade.minaslivre.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304Ab0BASXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 13:23:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit cddf63d99d0d145f18b293c3d0de4af7dab2a922 has push down the BKL
into irnet open function. However, there's nothing that needs locking in
there.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 net/irda/irnet/irnet_ppp.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/irda/irnet/irnet_ppp.c b/net/irda/irnet/irnet_ppp.c
index 156020d..d6b502c 100644
--- a/net/irda/irnet/irnet_ppp.c
+++ b/net/irda/irnet/irnet_ppp.c
@@ -479,7 +479,6 @@ dev_irnet_open(struct inode *	inode,
   ap = kzalloc(sizeof(*ap), GFP_KERNEL);
   DABORT(ap == NULL, -ENOMEM, FS_ERROR, "Can't allocate struct irnet...\n");
 
-  lock_kernel();
   /* initialize the irnet structure */
   ap->file = file;
 
@@ -501,7 +500,6 @@ dev_irnet_open(struct inode *	inode,
     {
       DERROR(FS_ERROR, "Can't setup IrDA link...\n");
       kfree(ap);
-      unlock_kernel();
       return err;
     }
 
@@ -512,7 +510,6 @@ dev_irnet_open(struct inode *	inode,
   file->private_data = ap;
 
   DEXIT(FS_TRACE, " - ap=0x%p\n", ap);
-  unlock_kernel();
   return 0;
 }
 
-- 
1.6.6.1

