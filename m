From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/11] drivers/net/tg3.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:10 -0800
Message-ID: <24eddd5027b6ac3b66224dcf50a4ba4eed5aba60.1197671367.git.joe__21931.5430651934$1197671943$gmane$org@perches.com>
References: <1197671652-32492-1-git-send-email-joe@perches.com>
 <1197671652-32492-2-git-send-email-joe@perches.com>
 <1197671652-32492-3-git-send-email-joe@perches.com>
 <1197671652-32492-4-git-send-email-joe@perches.com>
 <1197671652-32492-5-git-send-email-joe@perches.com>
 <1197671652-32492-6-git-send-email-joe@perches.com>
 <1197671652-32492-7-git-send-email-joe@perches.com>
 <1197671652-32492-8-git-send-email-joe@perches.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Michael Chan <mchan@broadcom.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934661AbXLNWiO@vger.kernel.org>
In-Reply-To: <1197671652-32492-8-git-send-email-joe@perches.com>
Message-Id: <24eddd5027b6ac3b66224dcf50a4ba4eed5aba60.1197671367.git.joe@perches.com>
In-Reply-To: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
References: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tg3.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4942f7d..eea7da9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12351,9 +12351,10 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	unsigned long tg3reg_base, tg3reg_len;
 	struct net_device *dev;
 	struct tg3 *tp;
-	int i, err, pm_cap;
+	int err, pm_cap;
 	char str[40];
 	u64 dma_mask, persist_dma_mask;
+	DECLARE_MAC_BUF(mac);
 
 	if (tg3_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -12632,7 +12633,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_apeunmap;
 	}
 
-	printk(KERN_INFO "%s: Tigon3 [partno(%s) rev %04x PHY(%s)] (%s) %s Ethernet ",
+	printk(KERN_INFO "%s: Tigon3 [partno(%s) rev %04x PHY(%s)] "
+	       "(%s) %s Ethernet %s\n",
 	       dev->name,
 	       tp->board_part_number,
 	       tp->pci_chip_rev_id,
@@ -12640,11 +12642,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	       tg3_bus_string(tp, str),
 	       ((tp->tg3_flags & TG3_FLAG_10_100_ONLY) ? "10/100Base-TX" :
 		((tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) ? "1000Base-SX" :
-		 "10/100/1000Base-T")));
