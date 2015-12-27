From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] sh_eth: remove EDMAC_BIG_ENDIAN
Date: Mon, 28 Dec 2015 02:07:08 +0300
Message-ID: <1789816.9Rg3E9smcf@wasted.cogentembedded.com>
References: <27915743.MLN0FvErP3@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <27915743.MLN0FvErP3@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit  71557a37adb5 ("[netdrvr] sh_eth: Add SH7619 support") added support
for the big-endian EDMAC descriptors. However, it was never used and never
worked right until the recent driver  fixes. I think we now  can just remove
this support,  it was only burdening the driver from the start. It should be
easy to do without disturbing the SH platform code, at least for now...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   18 ++----------------
 drivers/net/ethernet/renesas/sh_eth.h |    1 -
 include/linux/sh_eth.h                |    2 +-
 3 files changed, 3 insertions(+), 18 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -971,24 +971,12 @@ static void sh_eth_set_receive_align(str
 /* CPU <-> EDMAC endian convert */
 static inline __u32 cpu_to_edmac(struct sh_eth_private *mdp, u32 x)
 {
-	switch (mdp->edmac_endian) {
-	case EDMAC_LITTLE_ENDIAN:
-		return cpu_to_le32(x);
-	case EDMAC_BIG_ENDIAN:
-		return cpu_to_be32(x);
-	}
-	return x;
+	return cpu_to_le32(x);
 }
 
 static inline __u32 edmac_to_cpu(struct sh_eth_private *mdp, u32 x)
 {
-	switch (mdp->edmac_endian) {
-	case EDMAC_LITTLE_ENDIAN:
-		return le32_to_cpu(x);
-	case EDMAC_BIG_ENDIAN:
-		return be32_to_cpu(x);
-	}
-	return x;
+	return le32_to_cpu(x);
 }
 
 /* Program the hardware MAC address from dev->dev_addr. */
@@ -3097,8 +3085,6 @@ static int sh_eth_drv_probe(struct platf
 	/* get PHY ID */
 	mdp->phy_id = pd->phy;
 	mdp->phy_interface = pd->phy_interface;
-	/* EDMAC endian */
-	mdp->edmac_endian = pd->edmac_endian;
 	mdp->no_ether_link = pd->no_ether_link;
 	mdp->ether_link_active_low = pd->ether_link_active_low;
 
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -513,7 +513,6 @@ struct sh_eth_private {
 	u32 cur_rx, dirty_rx;		/* Producer/consumer ring indices */
 	u32 cur_tx, dirty_tx;
 	u32 rx_buf_sz;			/* Based on MTU+slack. */
-	int edmac_endian;
 	struct napi_struct napi;
 	bool irq_enabled;
 	/* MII transceiver section. */
Index: net-next/include/linux/sh_eth.h
===================================================================
--- net-next.orig/include/linux/sh_eth.h
+++ net-next/include/linux/sh_eth.h
@@ -4,7 +4,7 @@
 #include <linux/phy.h>
 #include <linux/if_ether.h>
 
-enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
+enum {EDMAC_LITTLE_ENDIAN};
 
 struct sh_eth_plat_data {
 	int phy;

