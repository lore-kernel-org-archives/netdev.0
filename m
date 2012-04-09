From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 15/26] wireless, orinoco: release_firmware() tests for NULL,
 remove explicit tests before calls
Date: Mon, 9 Apr 2012 22:51:19 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204092225140.13925@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, Pavel Roskin <proski@gnu.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is redundant to test for NULL pointers before calling
release_firmware() since the function does its own NULL test.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/orinoco/fw.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/orinoco/fw.c b/drivers/net/wireless/orinoco/fw.c
index 4df8cf6..400a352 100644
--- a/drivers/net/wireless/orinoco/fw.c
+++ b/drivers/net/wireless/orinoco/fw.c
@@ -379,11 +379,8 @@ void orinoco_cache_fw(struct orinoco_private *priv, int ap)
 
 void orinoco_uncache_fw(struct orinoco_private *priv)
 {
-	if (priv->cached_pri_fw)
-		release_firmware(priv->cached_pri_fw);
-	if (priv->cached_fw)
-		release_firmware(priv->cached_fw);
-
+	release_firmware(priv->cached_pri_fw);
+	release_firmware(priv->cached_fw);
 	priv->cached_pri_fw = NULL;
 	priv->cached_fw = NULL;
 }
-- 
1.7.10


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
