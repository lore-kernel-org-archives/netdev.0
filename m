From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] sundance: correct printk of dma_addr_t
Date: Tue, 3 Feb 2004 15:36:54 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040203153654.7bc74d19.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


description:	fix dma_addr_t type error with CONFIG_HIGHMEM64G=y;
product_versions: linux-262-rc3

diffstat:=
 drivers/net/sundance.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff -Naurp ./drivers/net/sundance.c~sundan_dma ./drivers/net/sundance.c
--- ./drivers/net/sundance.c~sundan_dma	2004-02-03 14:53:24.000000000 -0800
+++ ./drivers/net/sundance.c	2004-02-03 14:54:28.000000000 -0800
@@ -986,8 +986,8 @@ static void tx_timeout(struct net_device
 	{
 		int i;
 		for (i=0; i<TX_RING_SIZE; i++) {
-			printk(KERN_DEBUG "%02x %08Zx %08x %08x(%02x) %08x %08x\n", i,
-				np->tx_ring_dma + i*sizeof(*np->tx_ring),
+			printk(KERN_DEBUG "%02x %08llx %08x %08x(%02x) %08x %08x\n", i,
+				(unsigned long long)np->tx_ring_dma + i*sizeof(*np->tx_ring),
 				le32_to_cpu(np->tx_ring[i].next_desc),
 				le32_to_cpu(np->tx_ring[i].status),
 				(le32_to_cpu(np->tx_ring[i].status) >> 2) & 0xff,
@@ -1672,8 +1672,8 @@ static int netdev_ioctl(struct net_devic
 	switch (cmd) {
 		case SIOCDEVPRIVATE:
 		for (i=0; i<TX_RING_SIZE; i++) {
-			printk(KERN_DEBUG "%02x %08Zx %08x %08x(%02x) %08x %08x\n", i,
-				np->tx_ring_dma + i*sizeof(*np->tx_ring),	
+			printk(KERN_DEBUG "%02x %08llx %08x %08x(%02x) %08x %08x\n", i,
+				(unsigned long long)np->tx_ring_dma + i*sizeof(*np->tx_ring),	
 				le32_to_cpu(np->tx_ring[i].next_desc),
 				le32_to_cpu(np->tx_ring[i].status),
 				(le32_to_cpu(np->tx_ring[i].status) >> 2) 


--
~Randy
