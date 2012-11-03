From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 10/16] drivers/net/ethernet/ibm/emac/mal.c: use WARN
Date: Sat,  3 Nov 2012 11:58:31 +0100
Message-ID: <1351940317-14812-11-git-send-email-Julia.Lawall@lip6.fr>
References: <1351940317-14812-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1351940317-14812-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Use WARN rather than printk followed by WARN_ON(1), for conciseness.

A simplified version of the semantic patch that makes this transformation
is as follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression list es;
@@

-printk(
+WARN(1,
  es);
-WARN_ON(1);
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/ibm/emac/mal.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index 479e43e..84c6b6c 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -738,13 +738,11 @@ static int __devexit mal_remove(struct platform_device *ofdev)
 	/* Synchronize with scheduled polling */
 	napi_disable(&mal->napi);
 
-	if (!list_empty(&mal->list)) {
+	if (!list_empty(&mal->list))
 		/* This is *very* bad */
-		printk(KERN_EMERG
+		WARN(1, KERN_EMERG
 		       "mal%d: commac list is not empty on remove!\n",
 		       mal->index);
-		WARN_ON(1);
-	}
 
 	dev_set_drvdata(&ofdev->dev, NULL);
 
