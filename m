From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 07/11] xscale/ixp2000/ixpdev: print MAC via printk format specifier
Date: Fri, 24 Feb 2012 14:45:58 +0100
Message-ID: <1330091162-8141-8-git-send-email-danny.kukawka@bisect.de>
References: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lennert Buytenhek <kernel@wantstofly.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330091162-8141-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Print MAC/dev_addr via printk extended format specifier %pM
instead of custom code.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/xscale/ixp2000/ixpdev.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/xscale/ixp2000/ixpdev.c b/drivers/net/ethernet/xscale/ixp2000/ixpdev.c
index e122493..4500837 100644
--- a/drivers/net/ethernet/xscale/ixp2000/ixpdev.c
+++ b/drivers/net/ethernet/xscale/ixp2000/ixpdev.c
@@ -398,11 +398,8 @@ int ixpdev_init(int __nds_count, struct net_device **__nds,
 	}
 
 	for (i = 0; i < nds_count; i++) {
-		printk(KERN_INFO "%s: IXP2000 MSF ethernet (port %d), "
-			"%.2x:%.2x:%.2x:%.2x:%.2x:%.2x.\n", nds[i]->name, i,
-			nds[i]->dev_addr[0], nds[i]->dev_addr[1],
-			nds[i]->dev_addr[2], nds[i]->dev_addr[3],
-			nds[i]->dev_addr[4], nds[i]->dev_addr[5]);
+		printk(KERN_INFO "%s: IXP2000 MSF ethernet (port %d), %pM.\n",
+				 nds[i]->name, i, nds[i]->dev_addr);
 	}
 
 	return 0;
-- 
1.7.8.3
