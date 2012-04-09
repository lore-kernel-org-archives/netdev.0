From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 04/26] typhoon: get rid of redundant conditional before all
 to release_firmware()
Date: Mon, 9 Apr 2012 22:50:10 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204092208140.13925@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	David Dillow <dave@thedillows.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no need to test for a NULL pointer before calling
release_firmware() since the function does that check itself, so
remove the redundant test.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/ethernet/3com/typhoon.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 1234a14..b153666 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2549,8 +2549,7 @@ typhoon_init(void)
 static void __exit
 typhoon_cleanup(void)
 {
-	if (typhoon_fw)
-		release_firmware(typhoon_fw);
+	release_firmware(typhoon_fw);
 	pci_unregister_driver(&typhoon_driver);
 }
 
-- 
1.7.10


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
