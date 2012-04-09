From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 14/26] wireless, mwifiex: drop redundant NULL test before
 call to release_firmware()
Date: Mon, 9 Apr 2012 22:51:12 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204092224080.13925@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Bing Zhao <bzhao@marvell.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since release_firmware() does its own test for NULL it is redundant to
do so before calling it.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/mwifiex/main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwifiex/main.c
index 9d1b3ca..2ee6162 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -342,8 +342,7 @@ static int mwifiex_init_hw_fw(struct mwifiex_adapter *adapter)
 	ret = 0;
 
 done:
-	if (adapter->firmware)
-		release_firmware(adapter->firmware);
+	release_firmware(adapter->firmware);
 	if (ret)
 		ret = -1;
 	return ret;
-- 
1.7.10


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
