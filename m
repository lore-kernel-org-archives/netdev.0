From: Pan Bian <bianpan201603@163.com>
Subject: [PATCH 1/1] atm: fix improper return value
Date: Sun,  4 Dec 2016 13:45:15 +0800
Message-ID: <1480830315-4924-1-git-send-email-bianpan201603@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Chas Williams <3chas3@gmail.com>,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-135.163.com ([123.125.50.135]:48119 "EHLO m50-135.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750778AbcLDFpa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Dec 2016 00:45:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan2016@163.com>

It returns variable "error" when ioremap_nocache() returns a NULL
pointer. The value of "error" is 0 then, which will mislead the callers
to believe that there is no error. This patch fixes the bug, returning
"-ENOMEM".

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=189021

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/atm/eni.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index f2aaf9e..40c2d56 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1727,7 +1727,7 @@ static int eni_do_init(struct atm_dev *dev)
 		printk("\n");
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't set up page "
 		    "mapping\n",dev->number);
-		return error;
+		return -ENOMEM;
 	}
 	eni_dev->ioaddr = base;
 	eni_dev->base_diff = real_base - (unsigned long) base;
-- 
1.9.1
