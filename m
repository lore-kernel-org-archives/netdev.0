From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH] atm: idt77252: fix dev refcnt leak
Date: Tue, 19 Nov 2013 18:09:27 +0800
Message-ID: <1384855767-21446-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-atm-general@lists.sourceforge.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<ying.xue@windriver.com>
To: <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

init_card() calls dev_get_by_name() to get a network deceive. But it
doesn't decrease network device reference count after the device is
used.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 drivers/atm/idt77252.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 272f009..1bdf104 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -3511,7 +3511,7 @@ static int init_card(struct atm_dev *dev)
 	tmp = dev_get_by_name(&init_net, tname);	/* jhs: was "tmp = dev_get(tname);" */
 	if (tmp) {
 		memcpy(card->atmdev->esi, tmp->dev_addr, 6);
-
+		dev_put(tmp);
 		printk("%s: ESI %pM\n", card->name, card->atmdev->esi);
 	}
 	/*
-- 
1.7.9.5
