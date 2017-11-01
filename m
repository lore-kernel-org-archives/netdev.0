From: Colin King <colin.king@canonical.com>
Subject: [PATCH] wan: wanxl: remove redundant assignment to stat
Date: Wed,  1 Nov 2017 08:49:45 +0000
Message-ID: <20171101084945.14653-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:34233 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751306AbdKAItr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 04:49:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

stat set to zero and the value is never read, instead stat is
set again in the do-loop. Hence the setting to zero is redundant
and can be removed. Cleans up clang warning:

drivers/net/wan/wanxl.c:737:2: warning: Value stored to 'stat'
is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wan/wanxl.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 0c7317520ed3..d573a57bc301 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -734,7 +734,6 @@ static int wanxl_pci_init_one(struct pci_dev *pdev,
 		return -ENODEV;
 	}
 
-	stat = 0;
 	timeout = jiffies + 5 * HZ;
 	do {
 		if ((stat = readl(card->plx + PLX_MAILBOX_5)) != 0)
-- 
2.14.1
