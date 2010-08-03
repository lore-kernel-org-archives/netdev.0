From: Stefan Weil <weil@mail.berlios.de>
Subject: [PATCH] davinci_emac: Fix use after free in davinci_emac_remove
Date: Tue,  3 Aug 2010 20:53:45 +0200
Message-ID: <1280861625-4804-1-git-send-email-weil@mail.berlios.de>
Cc: Stefan Weil <weil@mail.berlios.de>,
	"David S. Miller" <davem@davemloft.net>,
	Chaithrika U S <chaithrika@ti.com>,
	Sriramakrishnan <srk@ti.com>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

free_netdev finally calls kfree which makes the contents
of ndev and priv (private data contained in ndev) invalid.

So iounmap should be called before free_netdev.

Cc: David S. Miller <davem@davemloft.net>
Cc: Chaithrika U S <chaithrika@ti.com>
Cc: Sriramakrishnan <srk@ti.com>
Cc: Kevin Hilman <khilman@deeprootsystems.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Stefan Weil <weil@mail.berlios.de>
---
 drivers/net/davinci_emac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 8cc8a43..866e6b8 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2818,8 +2818,8 @@ static int __devexit davinci_emac_remove(struct platform_device *pdev)
 	release_mem_region(res->start, res->end - res->start + 1);
 
 	unregister_netdev(ndev);
-	free_netdev(ndev);
 	iounmap(priv->remap_addr);
+	free_netdev(ndev);
 
 	clk_disable(emac_clk);
 	clk_put(emac_clk);
-- 
1.5.6.5
