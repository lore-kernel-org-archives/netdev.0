From: Pan Bian <bianpan201602@163.com>
Subject: [PATCH 1/1] wan: pc300too: abort path on failure
Date: Sun, 23 Apr 2017 17:38:35 +0800
Message-ID: <1492940315-1462-1-git-send-email-bianpan201602@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pan Bian <bianpan2016@163.com>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-132.163.com ([123.125.50.132]:37409 "EHLO m50-132.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1044391AbdDWJjP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Apr 2017 05:39:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pan Bian <bianpan2016@163.com>

In function pc300_pci_init_one(), on the ioremap error path, function
pc300_pci_remove_one() is called to free the allocated memory. However,
the path is not terminated, and the freed memory will be used later,
resulting in use-after-free bugs. This path fixes the bug.

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/net/wan/pc300too.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index e1dd1ec..b9b934b 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -346,6 +346,7 @@ static int pc300_pci_init_one(struct pci_dev *pdev,
 	    card->rambase == NULL) {
 		pr_err("ioremap() failed\n");
 		pc300_pci_remove_one(pdev);
+		return -ENOMEM;
 	}
 
 	/* PLX PCI 9050 workaround for local configuration register read bug */
-- 
1.9.1
