From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 12/26] ipw2200: remove a redundant NULL check before calling
 release_firmware()
Date: Mon, 9 Apr 2012 22:51:01 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204092220360.13925@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The release_firmware() function does its own NULL test, so testing
before calling it is rather redundant.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/ipw2x00/ipw2200.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 2b02257..77c5d2f 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -3657,8 +3657,7 @@ static int ipw_load(struct ipw_priv *priv)
 		priv->rxq = NULL;
 	}
 	ipw_tx_queue_free(priv);
-	if (raw)
-		release_firmware(raw);
+	release_firmware(raw);
 #ifdef CONFIG_PM
 	fw_loaded = 0;
 	raw = NULL;
-- 
1.7.10


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
