From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 05/26] tg3: remove redundant NULL test before release_firmware()
 call
Date: Mon, 9 Apr 2012 22:50:15 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204092209360.13925@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to test for a NULL pointer before calling
release_firmware - the function does that on its own.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/ethernet/broadcom/tg3.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 062ac33..9fbf73e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -15842,8 +15842,7 @@ static void __devexit tg3_remove_one(struct pci_dev *pdev)
 	if (dev) {
 		struct tg3 *tp = netdev_priv(dev);
 
-		if (tp->fw)
-			release_firmware(tp->fw);
+		release_firmware(tp->fw);
 
 		tg3_reset_task_cancel(tp);
 
-- 
1.7.10


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
