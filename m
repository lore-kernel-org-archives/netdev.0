From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/4] cw1200: hwio: Remove an unnecessary goto
Date: Tue,  4 Jun 2013 07:44:50 -0700
Message-ID: <fd299c9ef87fe50c12af871d6bfcc92d7f6ef3dc.1370356776.git.joe@perches.com>
References: <60123fd3175b7cceadf6c335b12e58b797e18f65.1370356776.git.joe@perches.com>
Cc: Solomon Peachy <pizza@shaftnet.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <60123fd3175b7cceadf6c335b12e58b797e18f65.1370356776.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

goto after return is wrong.

The other code in this block needs to set an
error value then goto an error release block.

This one doesn't need to release anything and
was likely a copy/paste remainder.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/cw1200/hwio.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/cw1200/hwio.c b/drivers/net/wireless/cw1200/hwio.c
index 142f45ef..dad3fb3 100644
--- a/drivers/net/wireless/cw1200/hwio.c
+++ b/drivers/net/wireless/cw1200/hwio.c
@@ -178,7 +178,6 @@ int cw1200_indirect_read(struct cw1200_common *priv, u32 addr, void *buf,
 	if ((buf_len / 2) >= 0x1000) {
 		pr_err("Can't read more than 0xfff words.\n");
 		return -EINVAL;
-		goto out;
 	}
 
 	priv->hwbus_ops->lock(priv->hwbus_priv);
-- 
1.8.1.2.459.gbcd45b4.dirty
