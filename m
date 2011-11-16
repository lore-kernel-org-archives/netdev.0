From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 4/5] amd8111e:  Convert ETH_ADDR_LEN uses to ETH_ALEN
Date: Wed, 16 Nov 2011 11:38:05 -0800
Message-ID: <5a78f1a0df7c4e742f72cafce8b495b3e7f1ad57.1321472143.git.joe@perches.com>
References: <cover.1321472142.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1321472142.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reduce the number of #defines, use the normal #define from if_ether.h

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/amd/amd8111e.c |    6 +++---
 drivers/net/ethernet/amd/amd8111e.h |    1 -
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index a388118..33e0a8c 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -499,7 +499,7 @@ static int amd8111e_restart(struct net_device *dev)
 	writel( VAL0 | APAD_XMT | REX_RTRY, mmio + CMD2 );
 
 	/* Setting the MAC address to the device */
-	for(i = 0; i < ETH_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		writeb( dev->dev_addr[i], mmio + PADR + i );
 
 	/* Enable interrupt coalesce */
@@ -1550,7 +1550,7 @@ static int amd8111e_set_mac_address(struct net_device *dev, void *p)
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	spin_lock_irq(&lp->lock);
 	/* Setting the MAC address to the device */
-	for(i = 0; i < ETH_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		writeb( dev->dev_addr[i], lp->mmio + PADR + i );
 
 	spin_unlock_irq(&lp->lock);
@@ -1886,7 +1886,7 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 	}
 
 	/* Initializing MAC address */
-	for(i = 0; i < ETH_ADDR_LEN; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		dev->dev_addr[i] = readb(lp->mmio + PADR + i);
 
 	/* Setting user defined parametrs */
diff --git a/drivers/net/ethernet/amd/amd8111e.h b/drivers/net/ethernet/amd/amd8111e.h
index 2ff2e7a..5bbb53a 100644
--- a/drivers/net/ethernet/amd/amd8111e.h
+++ b/drivers/net/ethernet/amd/amd8111e.h
@@ -586,7 +586,6 @@ typedef enum {
 
 #define PKT_BUFF_SZ			1536
 #define MIN_PKT_LEN			60
-#define ETH_ADDR_LEN			6
 
 #define  AMD8111E_TX_TIMEOUT		(3 * HZ)/* 3 sec */
 #define SOFT_TIMER_FREQ 		0xBEBC  /* 0.5 sec */
-- 
1.7.6.405.gc1be0
