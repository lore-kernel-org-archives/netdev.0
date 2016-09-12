From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 09/15] net: mvneta: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:40 -0400
Message-ID: <1473689026-6983-10-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        netdev@vger.kernel.org, Marcin Wojtas <mw@semihalf.com>,
        "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/marvell/mvneta_bm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta_bm.h b/drivers/net/ethernet/marvell/mvneta_bm.h
index e74fd44a92f7..a32de432800c 100644
--- a/drivers/net/ethernet/marvell/mvneta_bm.h
+++ b/drivers/net/ethernet/marvell/mvneta_bm.h
@@ -133,7 +133,7 @@ struct mvneta_bm_pool {
 void *mvneta_frag_alloc(unsigned int frag_size);
 void mvneta_frag_free(unsigned int frag_size, void *data);
 
-#if defined(CONFIG_MVNETA_BM) || defined(CONFIG_MVNETA_BM_MODULE)
+#if IS_ENABLED(CONFIG_MVNETA_BM)
 void mvneta_bm_pool_destroy(struct mvneta_bm *priv,
 			    struct mvneta_bm_pool *bm_pool, u8 port_map);
 void mvneta_bm_bufs_free(struct mvneta_bm *priv, struct mvneta_bm_pool *bm_pool,
-- 
2.7.4
