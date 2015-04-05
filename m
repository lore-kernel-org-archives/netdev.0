From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: move inline functions to the header file
Date: Mon, 06 Apr 2015 00:13:46 +0300
Message-ID: <4254119.qJUdUQCUqs@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The explicitly inline functions belong to the header files, so move
cpu_to_edmac() and edmac_to_cpu() into the driver header.

While at it, make these functions return 'u32' instead of '__u32'.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against the David Miller's 'net-next.git' repo.
I was going to let gcc figure out whether inlining was needed but it turned
out that with *inline* keywords removed gcc generated even more code...

 drivers/net/ethernet/renesas/sh_eth.c |   24 ------------------------
 drivers/net/ethernet/renesas/sh_eth.h |   23 +++++++++++++++++++++++
 2 files changed, 23 insertions(+), 24 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -941,30 +941,6 @@ static void sh_eth_set_receive_align(str
 		skb_reserve(skb, SH_ETH_RX_ALIGN - reserve);
 }
 
-
-/* CPU <-> EDMAC endian convert */
-static inline __u32 cpu_to_edmac(struct sh_eth_private *mdp, u32 x)
-{
-	switch (mdp->edmac_endian) {
-	case EDMAC_LITTLE_ENDIAN:
-		return cpu_to_le32(x);
-	case EDMAC_BIG_ENDIAN:
-		return cpu_to_be32(x);
-	}
-	return x;
-}
-
-static inline __u32 edmac_to_cpu(struct sh_eth_private *mdp, u32 x)
-{
-	switch (mdp->edmac_endian) {
-	case EDMAC_LITTLE_ENDIAN:
-		return le32_to_cpu(x);
-	case EDMAC_BIG_ENDIAN:
-		return be32_to_cpu(x);
-	}
-	return x;
-}
-
 /* Program the hardware MAC address from dev->dev_addr. */
 static void update_mac_address(struct net_device *ndev)
 {
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -546,6 +546,29 @@ static inline void sh_eth_soft_swap(char
 #endif
 }
 
+/* CPU <-> EDMAC endian convert */
+static inline u32 cpu_to_edmac(struct sh_eth_private *mdp, u32 x)
+{
+	switch (mdp->edmac_endian) {
+	case EDMAC_LITTLE_ENDIAN:
+		return cpu_to_le32(x);
+	case EDMAC_BIG_ENDIAN:
+		return cpu_to_be32(x);
+	}
+	return x;
+}
+
+static inline u32 edmac_to_cpu(struct sh_eth_private *mdp, u32 x)
+{
+	switch (mdp->edmac_endian) {
+	case EDMAC_LITTLE_ENDIAN:
+		return le32_to_cpu(x);
+	case EDMAC_BIG_ENDIAN:
+		return be32_to_cpu(x);
+	}
+	return x;
+}
+
 #define SH_ETH_OFFSET_INVALID	((u16) ~0)
 
 static inline void sh_eth_write(struct net_device *ndev, u32 data,

