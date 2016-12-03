From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/1] atm: lanai: set error code when ioremap fails
Date: Sat,  3 Dec 2016 20:25:45 +0800
Message-ID: <1480767945-5676-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Chas Williams <3chas3@gmail.com>,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In function lanai_dev_open(), when the call to ioremap() fails, the
value of return variable result is 0. 0 means no error in this context.
This patch fixes the bug, assigning "-ENOMEM" to result when ioremap()
returns a NULL pointer.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188791

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 drivers/atm/lanai.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index ce43ae3..445505d 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -2143,6 +2143,7 @@ static int lanai_dev_open(struct atm_dev *atmdev)
 	lanai->base = (bus_addr_t) ioremap(raw_base, LANAI_MAPPING_SIZE);
 	if (lanai->base == NULL) {
 		printk(KERN_ERR DEV_LABEL ": couldn't remap I/O space\n");
+		result = -ENOMEM;
 		goto error_pci;
 	}
 	/* 3.3: Reset lanai and PHY */
-- 
1.9.1
