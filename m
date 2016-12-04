From: Pan Bian <bianpan201603@163.com>
Subject: [PATCH 1/1] isdn: hisax: set error code on failure
Date: Sun,  4 Dec 2016 18:33:23 +0800
Message-ID: <1480847603-15520-1-git-send-email-bianpan201603@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Bian <bianpan2016@163.com>

In function hfc4s8s_probe(), the value of return variable err should be
negative on failures. However, when the call to request_region() returns
NULL, the value of err is 0. This patch fixes the bug, assiging
"-EBUSY" to err on the path that request_region() fails.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188931

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/isdn/hisax/hfc4s8s_l1.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index 9600cd7..3172cee 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -1499,6 +1499,7 @@ struct hfc4s8s_l1 {
 		printk(KERN_INFO
 		       "HFC-4S/8S: failed to request address space at 0x%04x\n",
 		       hw->iobase);
+		err = -EBUSY;
 		goto out;
 	}
 
-- 
1.9.1
