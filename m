From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/5] dmfe: kill DEVICE define
Date: Tue,  3 May 2016 16:30:58 +0200
Message-ID: <1462285862-30946-2-git-send-email-fw@strlen.de>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
Cc: linux-kernel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	linux-parisc@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462285862-30946-1-git-send-email-fw@strlen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use net_device directly. Compile tested, objdiff shows no changes.

Cc: linux-parisc@vger.kernel.org
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/ethernet/dec/tulip/dmfe.c | 39 ++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index afd8e78..dd1c815 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -192,9 +192,6 @@
 	(__CHK_IO_SIZE(((pci_dev)->device << 16) | (pci_dev)->vendor, \
 	(pci_dev)->revision))
 
-/* Sten Check */
-#define DEVICE net_device
-
 /* Structure/enum declaration ------------------------------- */
 struct tx_desc {
         __le32 tdes0, tdes1, tdes2, tdes3; /* Data for the card */
@@ -313,10 +310,10 @@ static u8 SF_mode;		/* Special Function: 1:VLAN, 2:RX Flow Control
 
 
 /* function declaration ------------------------------------- */
-static int dmfe_open(struct DEVICE *);
-static netdev_tx_t dmfe_start_xmit(struct sk_buff *, struct DEVICE *);
-static int dmfe_stop(struct DEVICE *);
-static void dmfe_set_filter_mode(struct DEVICE *);
+static int dmfe_open(struct net_device *);
+static netdev_tx_t dmfe_start_xmit(struct sk_buff *, struct net_device *);
+static int dmfe_stop(struct net_device *);
+static void dmfe_set_filter_mode(struct net_device *);
 static const struct ethtool_ops netdev_ethtool_ops;
 static u16 read_srom_word(void __iomem *, int);
 static irqreturn_t dmfe_interrupt(int , void *);
@@ -326,8 +323,8 @@ static void poll_dmfe (struct net_device *dev);
 static void dmfe_descriptor_init(struct net_device *);
 static void allocate_rx_buffer(struct net_device *);
 static void update_cr6(u32, void __iomem *);
-static void send_filter_frame(struct DEVICE *);
-static void dm9132_id_table(struct DEVICE *);
+static void send_filter_frame(struct net_device *);
+static void dm9132_id_table(struct net_device *);
 static u16 dmfe_phy_read(void __iomem *, u8, u8, u32);
 static void dmfe_phy_write(void __iomem *, u8, u8, u16, u32);
 static void dmfe_phy_write_1bit(void __iomem *, u32);
@@ -336,12 +333,12 @@ static u8 dmfe_sense_speed(struct dmfe_board_info *);
 static void dmfe_process_mode(struct dmfe_board_info *);
 static void dmfe_timer(unsigned long);
 static inline u32 cal_CRC(unsigned char *, unsigned int, u8);
-static void dmfe_rx_packet(struct DEVICE *, struct dmfe_board_info *);
-static void dmfe_free_tx_pkt(struct DEVICE *, struct dmfe_board_info *);
+static void dmfe_rx_packet(struct net_device *, struct dmfe_board_info *);
+static void dmfe_free_tx_pkt(struct net_device *, struct dmfe_board_info *);
 static void dmfe_reuse_skb(struct dmfe_board_info *, struct sk_buff *);
-static void dmfe_dynamic_reset(struct DEVICE *);
+static void dmfe_dynamic_reset(struct net_device *);
 static void dmfe_free_rxbuffer(struct dmfe_board_info *);
-static void dmfe_init_dm910x(struct DEVICE *);
+static void dmfe_init_dm910x(struct net_device *);
 static void dmfe_parse_srom(struct dmfe_board_info *);
 static void dmfe_program_DM9801(struct dmfe_board_info *, int);
 static void dmfe_program_DM9802(struct dmfe_board_info *);
@@ -558,7 +555,7 @@ static void dmfe_remove_one(struct pci_dev *pdev)
  *	The interface is opened whenever "ifconfig" actives it.
  */
 
-static int dmfe_open(struct DEVICE *dev)
+static int dmfe_open(struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	const int irq = db->pdev->irq;
@@ -617,7 +614,7 @@ static int dmfe_open(struct DEVICE *dev)
  *	Enable Tx/Rx machine
  */
 
-static void dmfe_init_dm910x(struct DEVICE *dev)
+static void dmfe_init_dm910x(struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	void __iomem *ioaddr = db->ioaddr;
@@ -684,7 +681,7 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
  */
 
 static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
-					 struct DEVICE *dev)
+					 struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	void __iomem *ioaddr = db->ioaddr;
@@ -754,7 +751,7 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *skb,
  *	The interface is stopped when it is brought.
  */
 
-static int dmfe_stop(struct DEVICE *dev)
+static int dmfe_stop(struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	void __iomem *ioaddr = db->ioaddr;
@@ -798,7 +795,7 @@ static int dmfe_stop(struct DEVICE *dev)
 
 static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 {
-	struct DEVICE *dev = dev_id;
+	struct net_device *dev = dev_id;
 	struct dmfe_board_info *db = netdev_priv(dev);
 	void __iomem *ioaddr = db->ioaddr;
 	unsigned long flags;
@@ -879,7 +876,7 @@ static void poll_dmfe (struct net_device *dev)
  *	Free TX resource after TX complete
  */
 
-static void dmfe_free_tx_pkt(struct DEVICE *dev, struct dmfe_board_info * db)
+static void dmfe_free_tx_pkt(struct net_device *dev, struct dmfe_board_info *db)
 {
 	struct tx_desc *txptr;
 	void __iomem *ioaddr = db->ioaddr;
@@ -961,7 +958,7 @@ static inline u32 cal_CRC(unsigned char * Data, unsigned int Len, u8 flag)
  *	Receive the come packet and pass to upper layer
  */
 
-static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
+static void dmfe_rx_packet(struct net_device *dev, struct dmfe_board_info *db)
 {
 	struct rx_desc *rxptr;
 	struct sk_buff *skb, *newskb;
@@ -1052,7 +1049,7 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
  * Set DM910X multicast address
  */
 
-static void dmfe_set_filter_mode(struct DEVICE * dev)
+static void dmfe_set_filter_mode(struct net_device *dev)
 {
 	struct dmfe_board_info *db = netdev_priv(dev);
 	unsigned long flags;
-- 
2.7.3
