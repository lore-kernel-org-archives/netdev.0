From: Alban Bedel <albeu@free.fr>
Subject: [PATCH] 8139too: The maximum MTU should allow for VLAN headers
Date: Sun, 23 Nov 2014 13:07:54 +0100
Message-ID: <1416744476-7372-1-git-send-email-albeu@free.fr>
Cc: Ben Hutchings <ben@decadent.org.uk>, Alban Bedel <albeu@free.fr>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Benoit Taine <benoit.taine@lip6.fr>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As pointed out by Ben Hutchings drivers that allow using VLAN have to
provide enough headroom for the VLAN tags.

Signed-off-by: Alban Bedel <albeu@free.fr>
---
 drivers/net/ethernet/realtek/8139too.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index e157541..63dc0f9 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -112,6 +112,7 @@
 #include <linux/io.h>
 #include <linux/uaccess.h>
 #include <linux/gfp.h>
+#include <linux/if_vlan.h>
 #include <asm/irq.h>
 
 #define RTL8139_DRIVER_NAME   DRV_NAME " Fast Ethernet driver " DRV_VERSION
@@ -182,13 +183,13 @@ static int debug = -1;
 /* Number of Tx descriptor registers. */
 #define NUM_TX_DESC	4
 
-/* max supported ethernet frame size -- must be at least (dev->mtu+14+4).*/
+/* max supported ethernet frame size -- must be at least (dev->mtu+18+4).*/
 #define MAX_ETH_FRAME_SIZE	1792
 
 /* max supported payload size */
-#define MAX_ETH_DATA_SIZE	(MAX_ETH_FRAME_SIZE - ETH_HLEN - ETH_FCS_LEN)
+#define MAX_ETH_DATA_SIZE (MAX_ETH_FRAME_SIZE - VLAN_ETH_HLEN - ETH_FCS_LEN)
 
-/* Size of the Tx bounce buffers -- must be at least (dev->mtu+14+4). */
+/* Size of the Tx bounce buffers -- must be at least (dev->mtu+18+4). */
 #define TX_BUF_SIZE	MAX_ETH_FRAME_SIZE
 #define TX_BUF_TOT_LEN	(TX_BUF_SIZE * NUM_TX_DESC)
 
-- 
2.0.0
