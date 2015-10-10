From: Tillmann Heidsieck <theidsieck@leenox.de>
Subject: [PATCH 2/2] atm: iphase: fix misleading indention
Date: Sat, 10 Oct 2015 21:47:19 +0200
Message-ID: <1444506439-10414-3-git-send-email-theidsieck@leenox.de>
References: <1444506439-10414-1-git-send-email-theidsieck@leenox.de>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tillmann Heidsieck <theidsieck@leenox.de>
To: Chas Williams <3chas3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444506439-10414-1-git-send-email-theidsieck@leenox.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a smatch warning:
drivers/atm/iphase.c:1178 rx_pkt() warn: curly braces intended?

The code is correct, the indention is misleading. In case the allocation
of skb fails, we want to skip to the end.

Signed-off-by: Tillmann Heidsieck <theidsieck@leenox.de>
---
 drivers/atm/iphase.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index d5010d7a99c3..7d00f2994738 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -1176,7 +1176,7 @@ static int rx_pkt(struct atm_dev *dev)
         if (!(skb = atm_alloc_charge(vcc, len, GFP_ATOMIC))) {
            if (vcc->vci < 32)
               printk("Drop control packets\n");
-	      goto out_free_desc;
+	   goto out_free_desc;
         }
 	skb_put(skb,len);  
         // pwang_test
-- 
2.6.1
