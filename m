From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 06/11] sun/sunqe: print MAC via printk format specifier
Date: Fri, 24 Feb 2012 14:45:57 +0100
Message-ID: <1330091162-8141-7-git-send-email-danny.kukawka@bisect.de>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Tobias Klauser <tklauser@distanz.ch>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Print MAC/dev_addr via printk extended format specifier %pM
instead of custom code.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/sun/sunqe.c |   10 ++--------
 1 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index b42d1c5..139d6b4 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -907,14 +907,8 @@ static int __devinit qec_ether_init(struct platform_device *op)
 
 	dev_set_drvdata(&op->dev, qe);
 
-	printk(KERN_INFO "%s: qe channel[%d] ", dev->name, qe->channel);
-	for (i = 0; i < 6; i++)
-		printk ("%2.2x%c",
-			dev->dev_addr[i],
-			i == 5 ? ' ': ':');
-	printk("\n");
-
-
+	printk(KERN_INFO "%s: qe channel[%d] %pM\n", dev->name, qe->channel,
+	       dev->dev_addr);
 	return 0;
 
 fail:
-- 
1.7.8.3
