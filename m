From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 15/20] drivers/net: Use kcalloc or kzalloc
Date: Thu, 13 May 2010 22:06:01 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005132205420.6282@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Use kcalloc or kzalloc rather than the combination of kmalloc and memset.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression x,y,flags;
statement S;
type T;
@@

x = 
-   kmalloc
+   kcalloc
           (
-           y * sizeof(T),
+           y, sizeof(T),
                flags);
 if (x == NULL) S
-memset(x, 0, y * sizeof(T));

@@
expression x,size,flags;
statement S;
@@

-x = kmalloc(size,flags);
+x = kzalloc(size,flags);
 if (x == NULL) S
-memset(x, 0, size);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/ibmveth.c |    3 +--
 drivers/net/ksz884x.c |    3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff -u -p a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -199,7 +199,7 @@ static int ibmveth_alloc_buffer_pool(str
 		return -1;
 	}
 
-	pool->skbuff = kmalloc(sizeof(void*) * pool->size, GFP_KERNEL);
+	pool->skbuff = kcalloc(pool->size, sizeof(void *), GFP_KERNEL);
 
 	if(!pool->skbuff) {
 		kfree(pool->dma_addr);
@@ -210,7 +210,6 @@ static int ibmveth_alloc_buffer_pool(str
 		return -1;
 	}
 
-	memset(pool->skbuff, 0, sizeof(void*) * pool->size);
 	memset(pool->dma_addr, 0, sizeof(dma_addr_t) * pool->size);
 
 	for(i = 0; i < pool->size; ++i) {
diff -u -p a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -7049,10 +7049,9 @@ static int __init pcidev_init(struct pci
 			mib_port_count = SWITCH_PORT_NUM;
 		}
 		hw->mib_port_cnt = TOTAL_PORT_NUM;
-		hw->ksz_switch = kmalloc(sizeof(struct ksz_switch), GFP_KERNEL);
+		hw->ksz_switch = kzalloc(sizeof(struct ksz_switch), GFP_KERNEL);
 		if (!hw->ksz_switch)
 			goto pcidev_init_alloc_err;
-		memset(hw->ksz_switch, 0, sizeof(struct ksz_switch));
 
 		sw = hw->ksz_switch;
 	}
