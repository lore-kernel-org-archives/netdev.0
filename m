From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v3 net-next 2/2] rocker: mark parameters and local variables as const
Date: Mon, 25 May 2015 14:28:36 +0900
Message-ID: <1432531716-9189-3-git-send-email-simon.horman@netronome.com>
References: <1432531716-9189-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35657 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbbEYF3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 01:29:00 -0400
Received: by pacwv17 with SMTP id wv17so63681189pac.2
        for <netdev@vger.kernel.org>; Sun, 24 May 2015 22:28:59 -0700 (PDT)
In-Reply-To: <1432531716-9189-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark parameters and local variables as const where possible.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Acked-by: Scott Feldman <sfeldma@gmail.com>

---
v3
* Rebased and updated to cover new parameters and local variables
  that may be const
* Added Scott Feldman's Ack

v2
* Make more parameters and variables const.
  It seems that I missed quite a few the first time around.

  The more I look over this the more I feel others are lurking.
---
 drivers/net/ethernet/rocker/rocker.c | 415 ++++++++++++++++++-----------------
 1 file changed, 215 insertions(+), 200 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 4818f2be036f..36f7edfc3c7a 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -295,7 +295,7 @@ static bool rocker_vlan_id_is_internal(__be16 vlan_id)
 	return (_vlan_id >= start && _vlan_id <= end);
 }
 
-static __be16 rocker_port_vid_to_vlan(struct rocker_port *rocker_port,
+static __be16 rocker_port_vid_to_vlan(const struct rocker_port *rocker_port,
 				      u16 vid, bool *pop_vlan)
 {
 	__be16 vlan_id;
@@ -312,7 +312,7 @@ static __be16 rocker_port_vid_to_vlan(struct rocker_port *rocker_port,
 	return vlan_id;
 }
 
-static u16 rocker_port_vlan_to_vid(struct rocker_port *rocker_port,
+static u16 rocker_port_vlan_to_vid(const struct rocker_port *rocker_port,
 				   __be16 vlan_id)
 {
 	if (rocker_vlan_id_is_internal(vlan_id))
@@ -321,7 +321,7 @@ static u16 rocker_port_vlan_to_vid(struct rocker_port *rocker_port,
 	return ntohs(vlan_id);
 }
 
-static bool rocker_port_is_bridged(struct rocker_port *rocker_port)
+static bool rocker_port_is_bridged(const struct rocker_port *rocker_port)
 {
 	return !!rocker_port->bridge_dev;
 }
@@ -443,18 +443,18 @@ static void rocker_wait_wake_up(struct rocker_wait *wait)
 	wake_up(&wait->wait);
 }
 
-static u32 rocker_msix_vector(struct rocker *rocker, unsigned int vector)
+static u32 rocker_msix_vector(const struct rocker *rocker, unsigned int vector)
 {
 	return rocker->msix_entries[vector].vector;
 }
 
-static u32 rocker_msix_tx_vector(struct rocker_port *rocker_port)
+static u32 rocker_msix_tx_vector(const struct rocker_port *rocker_port)
 {
 	return rocker_msix_vector(rocker_port->rocker,
 				  ROCKER_MSIX_VEC_TX(rocker_port->port_number));
 }
 
-static u32 rocker_msix_rx_vector(struct rocker_port *rocker_port)
+static u32 rocker_msix_rx_vector(const struct rocker_port *rocker_port)
 {
 	return rocker_msix_vector(rocker_port->rocker,
 				  ROCKER_MSIX_VEC_RX(rocker_port->port_number));
@@ -473,9 +473,9 @@ static u32 rocker_msix_rx_vector(struct rocker_port *rocker_port)
  * HW basic testing functions
  *****************************/
 
-static int rocker_reg_test(struct rocker *rocker)
+static int rocker_reg_test(const struct rocker *rocker)
 {
-	struct pci_dev *pdev = rocker->pdev;
+	const struct pci_dev *pdev = rocker->pdev;
 	u64 test_reg;
 	u64 rnd;
 
@@ -503,12 +503,12 @@ static int rocker_reg_test(struct rocker *rocker)
 	return 0;
 }
 
-static int rocker_dma_test_one(struct rocker *rocker, struct rocker_wait *wait,
-			       u32 test_type, dma_addr_t dma_handle,
-			       unsigned char *buf, unsigned char *expect,
-			       size_t size)
+static int rocker_dma_test_one(const struct rocker *rocker,
+			       struct rocker_wait *wait, u32 test_type,
+			       dma_addr_t dma_handle, const unsigned char *buf,
+			       const unsigned char *expect, size_t size)
 {
-	struct pci_dev *pdev = rocker->pdev;
+	const struct pci_dev *pdev = rocker->pdev;
 	int i;
 
 	rocker_wait_reset(wait);
@@ -532,7 +532,7 @@ static int rocker_dma_test_one(struct rocker *rocker, struct rocker_wait *wait,
 #define ROCKER_TEST_DMA_BUF_SIZE (PAGE_SIZE * 4)
 #define ROCKER_TEST_DMA_FILL_PATTERN 0x96
 
-static int rocker_dma_test_offset(struct rocker *rocker,
+static int rocker_dma_test_offset(const struct rocker *rocker,
 				  struct rocker_wait *wait, int offset)
 {
 	struct pci_dev *pdev = rocker->pdev;
@@ -592,7 +592,8 @@ free_alloc:
 	return err;
 }
 
-static int rocker_dma_test(struct rocker *rocker, struct rocker_wait *wait)
+static int rocker_dma_test(const struct rocker *rocker,
+			   struct rocker_wait *wait)
 {
 	int i;
 	int err;
@@ -614,9 +615,9 @@ static irqreturn_t rocker_test_irq_handler(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static int rocker_basic_hw_test(struct rocker *rocker)
+static int rocker_basic_hw_test(const struct rocker *rocker)
 {
-	struct pci_dev *pdev = rocker->pdev;
+	const struct pci_dev *pdev = rocker->pdev;
 	struct rocker_wait wait;
 	int err;
 
@@ -749,7 +750,7 @@ static u64 rocker_tlv_get_u64(const struct rocker_tlv *tlv)
 	return *(u64 *) rocker_tlv_data(tlv);
 }
 
-static void rocker_tlv_parse(struct rocker_tlv **tb, int maxtype,
+static void rocker_tlv_parse(const struct rocker_tlv **tb, int maxtype,
 			     const char *buf, int buf_len)
 {
 	const struct rocker_tlv *tlv;
@@ -762,19 +763,19 @@ static void rocker_tlv_parse(struct rocker_tlv **tb, int maxtype,
 		u32 type = rocker_tlv_type(tlv);
 
 		if (type > 0 && type <= maxtype)
-			tb[type] = (struct rocker_tlv *) tlv;
+			tb[type] = tlv;
 	}
 }
 
-static void rocker_tlv_parse_nested(struct rocker_tlv **tb, int maxtype,
+static void rocker_tlv_parse_nested(const struct rocker_tlv **tb, int maxtype,
 				    const struct rocker_tlv *tlv)
 {
 	rocker_tlv_parse(tb, maxtype, rocker_tlv_data(tlv),
 			 rocker_tlv_len(tlv));
 }
 
-static void rocker_tlv_parse_desc(struct rocker_tlv **tb, int maxtype,
-				  struct rocker_desc_info *desc_info)
+static void rocker_tlv_parse_desc(const struct rocker_tlv **tb, int maxtype,
+				  const struct rocker_desc_info *desc_info)
 {
 	rocker_tlv_parse(tb, maxtype, desc_info->data,
 			 desc_info->desc->tlv_size);
@@ -859,9 +860,9 @@ static void rocker_tlv_nest_end(struct rocker_desc_info *desc_info,
 }
 
 static void rocker_tlv_nest_cancel(struct rocker_desc_info *desc_info,
-				   struct rocker_tlv *start)
+				   const struct rocker_tlv *start)
 {
-	desc_info->tlv_size = (char *) start - desc_info->data;
+	desc_info->tlv_size = (const char *) start - desc_info->data;
 }
 
 /******************************************
@@ -873,7 +874,7 @@ static u32 __pos_inc(u32 pos, size_t limit)
 	return ++pos == limit ? 0 : pos;
 }
 
-static int rocker_desc_err(struct rocker_desc_info *desc_info)
+static int rocker_desc_err(const struct rocker_desc_info *desc_info)
 {
 	int err = desc_info->desc->comp_err & ~ROCKER_DMA_DESC_COMP_ERR_GEN;
 
@@ -901,31 +902,31 @@ static int rocker_desc_err(struct rocker_desc_info *desc_info)
 	return -EINVAL;
 }
 
-static void rocker_desc_gen_clear(struct rocker_desc_info *desc_info)
+static void rocker_desc_gen_clear(const struct rocker_desc_info *desc_info)
 {
 	desc_info->desc->comp_err &= ~ROCKER_DMA_DESC_COMP_ERR_GEN;
 }
 
-static bool rocker_desc_gen(struct rocker_desc_info *desc_info)
+static bool rocker_desc_gen(const struct rocker_desc_info *desc_info)
 {
 	u32 comp_err = desc_info->desc->comp_err;
 
 	return comp_err & ROCKER_DMA_DESC_COMP_ERR_GEN ? true : false;
 }
 
-static void *rocker_desc_cookie_ptr_get(struct rocker_desc_info *desc_info)
+static void *rocker_desc_cookie_ptr_get(const struct rocker_desc_info *desc_info)
 {
 	return (void *)(uintptr_t)desc_info->desc->cookie;
 }
 
-static void rocker_desc_cookie_ptr_set(struct rocker_desc_info *desc_info,
+static void rocker_desc_cookie_ptr_set(const struct rocker_desc_info *desc_info,
 				       void *ptr)
 {
 	desc_info->desc->cookie = (uintptr_t) ptr;
 }
 
 static struct rocker_desc_info *
-rocker_desc_head_get(struct rocker_dma_ring_info *info)
+rocker_desc_head_get(const struct rocker_dma_ring_info *info)
 {
 	static struct rocker_desc_info *desc_info;
 	u32 head = __pos_inc(info->head, info->size);
@@ -937,15 +938,15 @@ rocker_desc_head_get(struct rocker_dma_ring_info *info)
 	return desc_info;
 }
 
-static void rocker_desc_commit(struct rocker_desc_info *desc_info)
+static void rocker_desc_commit(const struct rocker_desc_info *desc_info)
 {
 	desc_info->desc->buf_size = desc_info->data_size;
 	desc_info->desc->tlv_size = desc_info->tlv_size;
 }
 
-static void rocker_desc_head_set(struct rocker *rocker,
+static void rocker_desc_head_set(const struct rocker *rocker,
 				 struct rocker_dma_ring_info *info,
-				 struct rocker_desc_info *desc_info)
+				 const struct rocker_desc_info *desc_info)
 {
 	u32 head = __pos_inc(info->head, info->size);
 
@@ -970,8 +971,8 @@ rocker_desc_tail_get(struct rocker_dma_ring_info *info)
 	return desc_info;
 }
 
-static void rocker_dma_ring_credits_set(struct rocker *rocker,
-					struct rocker_dma_ring_info *info,
+static void rocker_dma_ring_credits_set(const struct rocker *rocker,
+					const struct rocker_dma_ring_info *info,
 					u32 credits)
 {
 	if (credits)
@@ -984,7 +985,7 @@ static unsigned long rocker_dma_ring_size_fix(size_t size)
 		   min(roundup_pow_of_two(size), ROCKER_DMA_SIZE_MAX));
 }
 
-static int rocker_dma_ring_create(struct rocker *rocker,
+static int rocker_dma_ring_create(const struct rocker *rocker,
 				  unsigned int type,
 				  size_t size,
 				  struct rocker_dma_ring_info *info)
@@ -1020,8 +1021,8 @@ static int rocker_dma_ring_create(struct rocker *rocker,
 	return 0;
 }
 
-static void rocker_dma_ring_destroy(struct rocker *rocker,
-				    struct rocker_dma_ring_info *info)
+static void rocker_dma_ring_destroy(const struct rocker *rocker,
+				    const struct rocker_dma_ring_info *info)
 {
 	rocker_write64(rocker, DMA_DESC_ADDR(info->type), 0);
 
@@ -1031,7 +1032,7 @@ static void rocker_dma_ring_destroy(struct rocker *rocker,
 	kfree(info->desc_info);
 }
 
-static void rocker_dma_ring_pass_to_producer(struct rocker *rocker,
+static void rocker_dma_ring_pass_to_producer(const struct rocker *rocker,
 					     struct rocker_dma_ring_info *info)
 {
 	int i;
@@ -1046,8 +1047,8 @@ static void rocker_dma_ring_pass_to_producer(struct rocker *rocker,
 	rocker_desc_commit(&info->desc_info[i]);
 }
 
-static int rocker_dma_ring_bufs_alloc(struct rocker *rocker,
-				      struct rocker_dma_ring_info *info,
+static int rocker_dma_ring_bufs_alloc(const struct rocker *rocker,
+				      const struct rocker_dma_ring_info *info,
 				      int direction, size_t buf_size)
 {
 	struct pci_dev *pdev = rocker->pdev;
@@ -1084,7 +1085,7 @@ static int rocker_dma_ring_bufs_alloc(struct rocker *rocker,
 
 rollback:
 	for (i--; i >= 0; i--) {
-		struct rocker_desc_info *desc_info = &info->desc_info[i];
+		const struct rocker_desc_info *desc_info = &info->desc_info[i];
 
 		pci_unmap_single(pdev, dma_unmap_addr(desc_info, mapaddr),
 				 desc_info->data_size, direction);
@@ -1093,15 +1094,15 @@ rollback:
 	return err;
 }
 
-static void rocker_dma_ring_bufs_free(struct rocker *rocker,
-				      struct rocker_dma_ring_info *info,
+static void rocker_dma_ring_bufs_free(const struct rocker *rocker,
+				      const struct rocker_dma_ring_info *info,
 				      int direction)
 {
 	struct pci_dev *pdev = rocker->pdev;
 	int i;
 
 	for (i = 0; i < info->size; i++) {
-		struct rocker_desc_info *desc_info = &info->desc_info[i];
+		const struct rocker_desc_info *desc_info = &info->desc_info[i];
 		struct rocker_desc *desc = &info->desc[i];
 
 		desc->buf_addr = 0;
@@ -1114,7 +1115,7 @@ static void rocker_dma_ring_bufs_free(struct rocker *rocker,
 
 static int rocker_dma_rings_init(struct rocker *rocker)
 {
-	struct pci_dev *pdev = rocker->pdev;
+	const struct pci_dev *pdev = rocker->pdev;
 	int err;
 
 	err = rocker_dma_ring_create(rocker, ROCKER_DMA_CMD,
@@ -1171,8 +1172,8 @@ static void rocker_dma_rings_fini(struct rocker *rocker)
 	rocker_dma_ring_destroy(rocker, &rocker->cmd_ring);
 }
 
-static int rocker_dma_rx_ring_skb_map(struct rocker *rocker,
-				      struct rocker_port *rocker_port,
+static int rocker_dma_rx_ring_skb_map(const struct rocker *rocker,
+				      const struct rocker_port *rocker_port,
 				      struct rocker_desc_info *desc_info,
 				      struct sk_buff *skb, size_t buf_len)
 {
@@ -1195,13 +1196,13 @@ tlv_put_failure:
 	return -EMSGSIZE;
 }
 
-static size_t rocker_port_rx_buf_len(struct rocker_port *rocker_port)
+static size_t rocker_port_rx_buf_len(const struct rocker_port *rocker_port)
 {
 	return rocker_port->dev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 }
 
-static int rocker_dma_rx_ring_skb_alloc(struct rocker *rocker,
-					struct rocker_port *rocker_port,
+static int rocker_dma_rx_ring_skb_alloc(const struct rocker *rocker,
+					const struct rocker_port *rocker_port,
 					struct rocker_desc_info *desc_info)
 {
 	struct net_device *dev = rocker_port->dev;
@@ -1228,8 +1229,8 @@ static int rocker_dma_rx_ring_skb_alloc(struct rocker *rocker,
 	return 0;
 }
 
-static void rocker_dma_rx_ring_skb_unmap(struct rocker *rocker,
-					 struct rocker_tlv **attrs)
+static void rocker_dma_rx_ring_skb_unmap(const struct rocker *rocker,
+					 const struct rocker_tlv **attrs)
 {
 	struct pci_dev *pdev = rocker->pdev;
 	dma_addr_t dma_handle;
@@ -1243,10 +1244,10 @@ static void rocker_dma_rx_ring_skb_unmap(struct rocker *rocker,
 	pci_unmap_single(pdev, dma_handle, len, PCI_DMA_FROMDEVICE);
 }
 
-static void rocker_dma_rx_ring_skb_free(struct rocker *rocker,
-					struct rocker_desc_info *desc_info)
+static void rocker_dma_rx_ring_skb_free(const struct rocker *rocker,
+					const struct rocker_desc_info *desc_info)
 {
-	struct rocker_tlv *attrs[ROCKER_TLV_RX_MAX + 1];
+	const struct rocker_tlv *attrs[ROCKER_TLV_RX_MAX + 1];
 	struct sk_buff *skb = rocker_desc_cookie_ptr_get(desc_info);
 
 	if (!skb)
@@ -1256,10 +1257,10 @@ static void rocker_dma_rx_ring_skb_free(struct rocker *rocker,
 	dev_kfree_skb_any(skb);
 }
 
-static int rocker_dma_rx_ring_skbs_alloc(struct rocker *rocker,
-					 struct rocker_port *rocker_port)
+static int rocker_dma_rx_ring_skbs_alloc(const struct rocker *rocker,
+					 const struct rocker_port *rocker_port)
 {
-	struct rocker_dma_ring_info *rx_ring = &rocker_port->rx_ring;
+	const struct rocker_dma_ring_info *rx_ring = &rocker_port->rx_ring;
 	int i;
 	int err;
 
@@ -1277,10 +1278,10 @@ rollback:
 	return err;
 }
 
-static void rocker_dma_rx_ring_skbs_free(struct rocker *rocker,
-					 struct rocker_port *rocker_port)
+static void rocker_dma_rx_ring_skbs_free(const struct rocker *rocker,
+					 const struct rocker_port *rocker_port)
 {
-	struct rocker_dma_ring_info *rx_ring = &rocker_port->rx_ring;
+	const struct rocker_dma_ring_info *rx_ring = &rocker_port->rx_ring;
 	int i;
 
 	for (i = 0; i < rx_ring->size; i++)
@@ -1361,7 +1362,8 @@ static void rocker_port_dma_rings_fini(struct rocker_port *rocker_port)
 	rocker_dma_ring_destroy(rocker, &rocker_port->tx_ring);
 }
 
-static void rocker_port_set_enable(struct rocker_port *rocker_port, bool enable)
+static void rocker_port_set_enable(const struct rocker_port *rocker_port,
+				   bool enable)
 {
 	u64 val = rocker_read64(rocker_port->rocker, PORT_PHYS_ENABLE);
 
@@ -1379,7 +1381,7 @@ static void rocker_port_set_enable(struct rocker_port *rocker_port, bool enable)
 static irqreturn_t rocker_cmd_irq_handler(int irq, void *dev_id)
 {
 	struct rocker *rocker = dev_id;
-	struct rocker_desc_info *desc_info;
+	const struct rocker_desc_info *desc_info;
 	struct rocker_wait *wait;
 	u32 credits = 0;
 
@@ -1395,22 +1397,22 @@ static irqreturn_t rocker_cmd_irq_handler(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-static void rocker_port_link_up(struct rocker_port *rocker_port)
+static void rocker_port_link_up(const struct rocker_port *rocker_port)
 {
 	netif_carrier_on(rocker_port->dev);
 	netdev_info(rocker_port->dev, "Link is up\n");
 }
 
-static void rocker_port_link_down(struct rocker_port *rocker_port)
+static void rocker_port_link_down(const struct rocker_port *rocker_port)
 {
 	netif_carrier_off(rocker_port->dev);
 	netdev_info(rocker_port->dev, "Link is down\n");
 }
 
-static int rocker_event_link_change(struct rocker *rocker,
+static int rocker_event_link_change(const struct rocker *rocker,
 				    const struct rocker_tlv *info)
 {
-	struct rocker_tlv *attrs[ROCKER_TLV_EVENT_LINK_CHANGED_MAX + 1];
+	const struct rocker_tlv *attrs[ROCKER_TLV_EVENT_LINK_CHANGED_MAX + 1];
 	unsigned int port_number;
 	bool link_up;
 	struct rocker_port *rocker_port;
@@ -1456,7 +1458,7 @@ struct rocker_mac_vlan_seen_work {
 
 static void rocker_event_mac_vlan_seen_work(struct work_struct *work)
 {
-	struct rocker_mac_vlan_seen_work *sw =
+	const struct rocker_mac_vlan_seen_work *sw =
 		container_of(work, struct rocker_mac_vlan_seen_work, work);
 
 	rtnl_lock();
@@ -1467,14 +1469,14 @@ static void rocker_event_mac_vlan_seen_work(struct work_struct *work)
 	kfree(work);
 }
 
-static int rocker_event_mac_vlan_seen(struct rocker *rocker,
+static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 				      const struct rocker_tlv *info)
 {
 	struct rocker_mac_vlan_seen_work *sw;
-	struct rocker_tlv *attrs[ROCKER_TLV_EVENT_MAC_VLAN_MAX + 1];
+	const struct rocker_tlv *attrs[ROCKER_TLV_EVENT_MAC_VLAN_MAX + 1];
 	unsigned int port_number;
 	struct rocker_port *rocker_port;
-	unsigned char *addr;
+	const unsigned char *addr;
 	int flags = ROCKER_OP_FLAG_LEARNED;
 	__be16 vlan_id;
 
@@ -1513,11 +1515,11 @@ static int rocker_event_mac_vlan_seen(struct rocker *rocker,
 	return 0;
 }
 
-static int rocker_event_process(struct rocker *rocker,
-				struct rocker_desc_info *desc_info)
+static int rocker_event_process(const struct rocker *rocker,
+				const struct rocker_desc_info *desc_info)
 {
-	struct rocker_tlv *attrs[ROCKER_TLV_EVENT_MAX + 1];
-	struct rocker_tlv *info;
+	const struct rocker_tlv *attrs[ROCKER_TLV_EVENT_MAX + 1];
+	const struct rocker_tlv *info;
 	u16 type;
 
 	rocker_tlv_parse_desc(attrs, ROCKER_TLV_EVENT_MAX, desc_info);
@@ -1541,8 +1543,8 @@ static int rocker_event_process(struct rocker *rocker,
 static irqreturn_t rocker_event_irq_handler(int irq, void *dev_id)
 {
 	struct rocker *rocker = dev_id;
-	struct pci_dev *pdev = rocker->pdev;
-	struct rocker_desc_info *desc_info;
+	const struct pci_dev *pdev = rocker->pdev;
+	const struct rocker_desc_info *desc_info;
 	u32 credits = 0;
 	int err;
 
@@ -1586,16 +1588,21 @@ static irqreturn_t rocker_rx_irq_handler(int irq, void *dev_id)
  * Command interface
  ********************/
 
-typedef int (*rocker_cmd_cb_t)(struct rocker *rocker,
-			       struct rocker_port *rocker_port,
-			       struct rocker_desc_info *desc_info,
-			       void *priv);
+typedef int (*rocker_cmd_prep_cb_t)(const struct rocker *rocker,
+				    const struct rocker_port *rocker_port,
+				    struct rocker_desc_info *desc_info,
+				    void *priv);
+
+typedef int (*rocker_cmd_proc_cb_t)(const struct rocker *rocker,
+				    const struct rocker_port *rocker_port,
+				    const struct rocker_desc_info *desc_info,
+				    void *priv);
 
 static int rocker_cmd_exec(struct rocker *rocker,
 			   struct rocker_port *rocker_port,
 			   enum switchdev_trans trans,
-			   rocker_cmd_cb_t prepare, void *prepare_priv,
-			   rocker_cmd_cb_t process, void *process_priv)
+			   rocker_cmd_prep_cb_t prepare, void *prepare_priv,
+			   rocker_cmd_proc_cb_t process, void *process_priv)
 {
 	struct rocker_desc_info *desc_info;
 	struct rocker_wait *wait;
@@ -1646,8 +1653,8 @@ out:
 }
 
 static int
-rocker_cmd_get_port_settings_prep(struct rocker *rocker,
-				  struct rocker_port *rocker_port,
+rocker_cmd_get_port_settings_prep(const struct rocker *rocker,
+				  const struct rocker_port *rocker_port,
 				  struct rocker_desc_info *desc_info,
 				  void *priv)
 {
@@ -1667,14 +1674,14 @@ rocker_cmd_get_port_settings_prep(struct rocker *rocker,
 }
 
 static int
-rocker_cmd_get_port_settings_ethtool_proc(struct rocker *rocker,
-					  struct rocker_port *rocker_port,
-					  struct rocker_desc_info *desc_info,
+rocker_cmd_get_port_settings_ethtool_proc(const struct rocker *rocker,
+					  const struct rocker_port *rocker_port,
+					  const struct rocker_desc_info *desc_info,
 					  void *priv)
 {
 	struct ethtool_cmd *ecmd = priv;
-	struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
-	struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
+	const struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
+	const struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
 	u32 speed;
 	u8 duplex;
 	u8 autoneg;
@@ -1706,15 +1713,15 @@ rocker_cmd_get_port_settings_ethtool_proc(struct rocker *rocker,
 }
 
 static int
-rocker_cmd_get_port_settings_macaddr_proc(struct rocker *rocker,
-					  struct rocker_port *rocker_port,
-					  struct rocker_desc_info *desc_info,
+rocker_cmd_get_port_settings_macaddr_proc(const struct rocker *rocker,
+					  const struct rocker_port *rocker_port,
+					  const struct rocker_desc_info *desc_info,
 					  void *priv)
 {
 	unsigned char *macaddr = priv;
-	struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
-	struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
-	struct rocker_tlv *attr;
+	const struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
+	const struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
+	const struct rocker_tlv *attr;
 
 	rocker_tlv_parse_desc(attrs, ROCKER_TLV_CMD_MAX, desc_info);
 	if (!attrs[ROCKER_TLV_CMD_INFO])
@@ -1739,17 +1746,17 @@ struct port_name {
 };
 
 static int
-rocker_cmd_get_port_settings_phys_name_proc(struct rocker *rocker,
-					    struct rocker_port *rocker_port,
-					    struct rocker_desc_info *desc_info,
+rocker_cmd_get_port_settings_phys_name_proc(const struct rocker *rocker,
+					    const struct rocker_port *rocker_port,
+					    const struct rocker_desc_info *desc_info,
 					    void *priv)
 {
-	struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
-	struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
+	const struct rocker_tlv *info_attrs[ROCKER_TLV_CMD_PORT_SETTINGS_MAX + 1];
+	const struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
 	struct port_name *name = priv;
-	struct rocker_tlv *attr;
+	const struct rocker_tlv *attr;
 	size_t i, j, len;
-	char *str;
+	const char *str;
 
 	rocker_tlv_parse_desc(attrs, ROCKER_TLV_CMD_MAX, desc_info);
 	if (!attrs[ROCKER_TLV_CMD_INFO])
@@ -1781,8 +1788,8 @@ rocker_cmd_get_port_settings_phys_name_proc(struct rocker *rocker,
 }
 
 static int
-rocker_cmd_set_port_settings_ethtool_prep(struct rocker *rocker,
-					  struct rocker_port *rocker_port,
+rocker_cmd_set_port_settings_ethtool_prep(const struct rocker *rocker,
+					  const struct rocker_port *rocker_port,
 					  struct rocker_desc_info *desc_info,
 					  void *priv)
 {
@@ -1812,12 +1819,12 @@ rocker_cmd_set_port_settings_ethtool_prep(struct rocker *rocker,
 }
 
 static int
-rocker_cmd_set_port_settings_macaddr_prep(struct rocker *rocker,
-					  struct rocker_port *rocker_port,
+rocker_cmd_set_port_settings_macaddr_prep(const struct rocker *rocker,
+					  const struct rocker_port *rocker_port,
 					  struct rocker_desc_info *desc_info,
 					  void *priv)
 {
-	unsigned char *macaddr = priv;
+	const unsigned char *macaddr = priv;
 	struct rocker_tlv *cmd_info;
 
 	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_CMD_TYPE,
@@ -1837,8 +1844,8 @@ rocker_cmd_set_port_settings_macaddr_prep(struct rocker *rocker,
 }
 
 static int
-rocker_cmd_set_port_learning_prep(struct rocker *rocker,
-				  struct rocker_port *rocker_port,
+rocker_cmd_set_port_learning_prep(const struct rocker *rocker,
+				  const struct rocker_port *rocker_port,
 				  struct rocker_desc_info *desc_info,
 				  void *priv)
 {
@@ -1906,8 +1913,9 @@ static int rocker_port_set_learning(struct rocker_port *rocker_port,
 			       NULL, NULL, NULL);
 }
 
-static int rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
-					   struct rocker_flow_tbl_entry *entry)
+static int
+rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
+				const struct rocker_flow_tbl_entry *entry)
 {
 	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
 			       entry->key.ig_port.in_pport))
@@ -1922,8 +1930,9 @@ static int rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
 	return 0;
 }
 
-static int rocker_cmd_flow_tbl_add_vlan(struct rocker_desc_info *desc_info,
-					struct rocker_flow_tbl_entry *entry)
+static int
+rocker_cmd_flow_tbl_add_vlan(struct rocker_desc_info *desc_info,
+			     const struct rocker_flow_tbl_entry *entry)
 {
 	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
 			       entry->key.vlan.in_pport))
@@ -1945,8 +1954,9 @@ static int rocker_cmd_flow_tbl_add_vlan(struct rocker_desc_info *desc_info,
 	return 0;
 }
 
-static int rocker_cmd_flow_tbl_add_term_mac(struct rocker_desc_info *desc_info,
-					    struct rocker_flow_tbl_entry *entry)
+static int
+rocker_cmd_flow_tbl_add_term_mac(struct rocker_desc_info *desc_info,
+				 const struct rocker_flow_tbl_entry *entry)
 {
 	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
 			       entry->key.term_mac.in_pport))
@@ -1982,7 +1992,7 @@ static int rocker_cmd_flow_tbl_add_term_mac(struct rocker_desc_info *desc_info,
 
 static int
 rocker_cmd_flow_tbl_add_ucast_routing(struct rocker_desc_info *desc_info,
-				      struct rocker_flow_tbl_entry *entry)
+				      const struct rocker_flow_tbl_entry *entry)
 {
 	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
 				entry->key.ucast_routing.eth_type))
@@ -2003,8 +2013,9 @@ rocker_cmd_flow_tbl_add_ucast_routing(struct rocker_desc_info *desc_info,
 	return 0;
 }
 
-static int rocker_cmd_flow_tbl_add_bridge(struct rocker_desc_info *desc_info,
-					  struct rocker_flow_tbl_entry *entry)
+static int
+rocker_cmd_flow_tbl_add_bridge(struct rocker_desc_info *desc_info,
+			       const struct rocker_flow_tbl_entry *entry)
 {
 	if (entry->key.bridge.has_eth_dst &&
 	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_DST_MAC,
@@ -2036,8 +2047,9 @@ static int rocker_cmd_flow_tbl_add_bridge(struct rocker_desc_info *desc_info,
 	return 0;
 }
 
-static int rocker_cmd_flow_tbl_add_acl(struct rocker_desc_info *desc_info,
-				       struct rocker_flow_tbl_entry *entry)
+static int
+rocker_cmd_flow_tbl_add_acl(struct rocker_desc_info *desc_info,
+			    const struct rocker_flow_tbl_entry *entry)
 {
 	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
 			       entry->key.acl.in_pport))
@@ -2102,12 +2114,12 @@ static int rocker_cmd_flow_tbl_add_acl(struct rocker_desc_info *desc_info,
 	return 0;
 }
 
-static int rocker_cmd_flow_tbl_add(struct rocker *rocker,
-				   struct rocker_port *rocker_port,
+static int rocker_cmd_flow_tbl_add(const struct rocker *rocker,
+				   const struct rocker_port *rocker_port,
 				   struct rocker_desc_info *desc_info,
 				   void *priv)
 {
-	struct rocker_flow_tbl_entry *entry = priv;
+	const struct rocker_flow_tbl_entry *entry = priv;
 	struct rocker_tlv *cmd_info;
 	int err = 0;
 
@@ -2160,8 +2172,8 @@ static int rocker_cmd_flow_tbl_add(struct rocker *rocker,
 	return 0;
 }
 
-static int rocker_cmd_flow_tbl_del(struct rocker *rocker,
-				   struct rocker_port *rocker_port,
+static int rocker_cmd_flow_tbl_del(const struct rocker *rocker,
+				   const struct rocker_port *rocker_port,
 				   struct rocker_desc_info *desc_info,
 				   void *priv)
 {
@@ -2197,7 +2209,7 @@ rocker_cmd_group_tbl_add_l2_interface(struct rocker_desc_info *desc_info,
 
 static int
 rocker_cmd_group_tbl_add_l2_rewrite(struct rocker_desc_info *desc_info,
-				    struct rocker_group_tbl_entry *entry)
+				    const struct rocker_group_tbl_entry *entry)
 {
 	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_GROUP_ID_LOWER,
 			       entry->l2_rewrite.group_id))
@@ -2220,7 +2232,7 @@ rocker_cmd_group_tbl_add_l2_rewrite(struct rocker_desc_info *desc_info,
 
 static int
 rocker_cmd_group_tbl_add_group_ids(struct rocker_desc_info *desc_info,
-				   struct rocker_group_tbl_entry *entry)
+				   const struct rocker_group_tbl_entry *entry)
 {
 	int i;
 	struct rocker_tlv *group_ids;
@@ -2246,7 +2258,7 @@ rocker_cmd_group_tbl_add_group_ids(struct rocker_desc_info *desc_info,
 
 static int
 rocker_cmd_group_tbl_add_l3_unicast(struct rocker_desc_info *desc_info,
-				    struct rocker_group_tbl_entry *entry)
+				    const struct rocker_group_tbl_entry *entry)
 {
 	if (!is_zero_ether_addr(entry->l3_unicast.eth_src) &&
 	    rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC,
@@ -2270,8 +2282,8 @@ rocker_cmd_group_tbl_add_l3_unicast(struct rocker_desc_info *desc_info,
 	return 0;
 }
 
-static int rocker_cmd_group_tbl_add(struct rocker *rocker,
-				    struct rocker_port *rocker_port,
+static int rocker_cmd_group_tbl_add(const struct rocker *rocker,
+				    const struct rocker_port *rocker_port,
 				    struct rocker_desc_info *desc_info,
 				    void *priv)
 {
@@ -2316,8 +2328,8 @@ static int rocker_cmd_group_tbl_add(struct rocker *rocker,
 	return 0;
 }
 
-static int rocker_cmd_group_tbl_del(struct rocker *rocker,
-				    struct rocker_port *rocker_port,
+static int rocker_cmd_group_tbl_del(const struct rocker *rocker,
+				    const struct rocker_port *rocker_port,
 				    struct rocker_desc_info *desc_info,
 				    void *priv)
 {
@@ -2400,7 +2412,8 @@ static void rocker_free_tbls(struct rocker *rocker)
 }
 
 static struct rocker_flow_tbl_entry *
-rocker_flow_tbl_find(struct rocker *rocker, struct rocker_flow_tbl_entry *match)
+rocker_flow_tbl_find(const struct rocker *rocker,
+		     const struct rocker_flow_tbl_entry *match)
 {
 	struct rocker_flow_tbl_entry *found;
 	size_t key_len = match->key_len ? match->key_len : sizeof(found->key);
@@ -2713,8 +2726,8 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 }
 
 static struct rocker_group_tbl_entry *
-rocker_group_tbl_find(struct rocker *rocker,
-		      struct rocker_group_tbl_entry *match)
+rocker_group_tbl_find(const struct rocker *rocker,
+		      const struct rocker_group_tbl_entry *match)
 {
 	struct rocker_group_tbl_entry *found;
 
@@ -2837,7 +2850,7 @@ static int rocker_group_l2_interface(struct rocker_port *rocker_port,
 static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
 				   enum switchdev_trans trans,
 				   int flags, u8 group_count,
-				   u32 *group_ids, u32 group_id)
+				   const u32 *group_ids, u32 group_id)
 {
 	struct rocker_group_tbl_entry *entry;
 
@@ -2862,7 +2875,7 @@ static int rocker_group_l2_fan_out(struct rocker_port *rocker_port,
 static int rocker_group_l2_flood(struct rocker_port *rocker_port,
 				 enum switchdev_trans trans, int flags,
 				 __be16 vlan_id, u8 group_count,
-				 u32 *group_ids, u32 group_id)
+				 const u32 *group_ids, u32 group_id)
 {
 	return rocker_group_l2_fan_out(rocker_port, trans, flags,
 				       group_count, group_ids,
@@ -2871,7 +2884,7 @@ static int rocker_group_l2_flood(struct rocker_port *rocker_port,
 
 static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
 				   enum switchdev_trans trans, int flags,
-				   u32 index, u8 *src_mac, u8 *dst_mac,
+				   u32 index, const u8 *src_mac, const u8 *dst_mac,
 				   __be16 vlan_id, bool ttl_check, u32 pport)
 {
 	struct rocker_group_tbl_entry *entry;
@@ -2893,7 +2906,7 @@ static int rocker_group_l3_unicast(struct rocker_port *rocker_port,
 }
 
 static struct rocker_neigh_tbl_entry *
-	rocker_neigh_tbl_find(struct rocker *rocker, __be32 ip_addr)
+rocker_neigh_tbl_find(const struct rocker *rocker, __be32 ip_addr)
 {
 	struct rocker_neigh_tbl_entry *found;
 
@@ -2931,7 +2944,7 @@ static void _rocker_neigh_del(enum switchdev_trans trans,
 
 static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
 				 enum switchdev_trans trans,
-				 u8 *eth_dst, bool ttl_check)
+				 const u8 *eth_dst, bool ttl_check)
 {
 	if (eth_dst) {
 		ether_addr_copy(entry->eth_dst, eth_dst);
@@ -2943,7 +2956,7 @@ static void _rocker_neigh_update(struct rocker_neigh_tbl_entry *entry,
 
 static int rocker_port_ipv4_neigh(struct rocker_port *rocker_port,
 				  enum switchdev_trans trans,
-				  int flags, __be32 ip_addr, u8 *eth_dst)
+				  int flags, __be32 ip_addr, const u8 *eth_dst)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_neigh_tbl_entry *entry;
@@ -3125,7 +3138,7 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 					int flags, __be16 vlan_id)
 {
 	struct rocker_port *p;
-	struct rocker *rocker = rocker_port->rocker;
+	const struct rocker *rocker = rocker_port->rocker;
 	u32 group_id = ROCKER_GROUP_L2_FLOOD(vlan_id, 0);
 	u32 *group_ids;
 	u8 group_count = 0;
@@ -3171,7 +3184,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 				      enum switchdev_trans trans, int flags,
 				      __be16 vlan_id, bool pop_vlan)
 {
-	struct rocker *rocker = rocker_port->rocker;
+	const struct rocker *rocker = rocker_port->rocker;
 	struct rocker_port *p;
 	bool adding = !(flags & ROCKER_OP_FLAG_REMOVE);
 	u32 out_pport;
@@ -3269,13 +3282,13 @@ static struct rocker_ctrl {
 
 static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 				     enum switchdev_trans trans, int flags,
-				     struct rocker_ctrl *ctrl, __be16 vlan_id)
+				     const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport = rocker_port->pport;
 	u32 in_pport_mask = 0xffffffff;
 	u32 out_pport = 0;
-	u8 *eth_src = NULL;
-	u8 *eth_src_mask = NULL;
+	const u8 *eth_src = NULL;
+	const u8 *eth_src_mask = NULL;
 	__be16 vlan_id_mask = htons(0xffff);
 	u8 ip_proto = 0;
 	u8 ip_proto_mask = 0;
@@ -3302,7 +3315,7 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 
 static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 					enum switchdev_trans trans, int flags,
-					struct rocker_ctrl *ctrl,
+					const struct rocker_ctrl *ctrl,
 					__be16 vlan_id)
 {
 	enum rocker_of_dpa_table_id goto_tbl =
@@ -3327,7 +3340,7 @@ static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 
 static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 				      enum switchdev_trans trans, int flags,
-				      struct rocker_ctrl *ctrl, __be16 vlan_id)
+				      const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	u32 in_pport_mask = 0xffffffff;
 	__be16 vlan_id_mask = htons(0xffff);
@@ -3351,7 +3364,7 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 
 static int rocker_port_ctrl_vlan(struct rocker_port *rocker_port,
 				 enum switchdev_trans trans, int flags,
-				 struct rocker_ctrl *ctrl, __be16 vlan_id)
+				 const struct rocker_ctrl *ctrl, __be16 vlan_id)
 {
 	if (ctrl->acl)
 		return rocker_port_ctrl_vlan_acl(rocker_port, trans, flags,
@@ -3388,7 +3401,7 @@ static int rocker_port_ctrl_vlan_add(struct rocker_port *rocker_port,
 
 static int rocker_port_ctrl(struct rocker_port *rocker_port,
 			    enum switchdev_trans trans, int flags,
-			    struct rocker_ctrl *ctrl)
+			    const struct rocker_ctrl *ctrl)
 {
 	u16 vid;
 	int err = 0;
@@ -3506,7 +3519,7 @@ struct rocker_fdb_learn_work {
 
 static void rocker_port_fdb_learn_work(struct work_struct *work)
 {
-	struct rocker_fdb_learn_work *lw =
+	const struct rocker_fdb_learn_work *lw =
 		container_of(work, struct rocker_fdb_learn_work, work);
 	bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
 	bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
@@ -3577,7 +3590,8 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 }
 
 static struct rocker_fdb_tbl_entry *
-rocker_fdb_tbl_find(struct rocker *rocker, struct rocker_fdb_tbl_entry *match)
+rocker_fdb_tbl_find(const struct rocker *rocker,
+		    const struct rocker_fdb_tbl_entry *match)
 {
 	struct rocker_fdb_tbl_entry *found;
 
@@ -3835,7 +3849,7 @@ static int rocker_port_fwd_disable(struct rocker_port *rocker_port,
 }
 
 static struct rocker_internal_vlan_tbl_entry *
-rocker_internal_vlan_tbl_find(struct rocker *rocker, int ifindex)
+rocker_internal_vlan_tbl_find(const struct rocker *rocker, int ifindex)
 {
 	struct rocker_internal_vlan_tbl_entry *found;
 
@@ -3890,8 +3904,9 @@ found:
 	return found->vlan_id;
 }
 
-static void rocker_port_internal_vlan_id_put(struct rocker_port *rocker_port,
-					     int ifindex)
+static void
+rocker_port_internal_vlan_id_put(const struct rocker_port *rocker_port,
+				 int ifindex)
 {
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_internal_vlan_tbl_entry *found;
@@ -3921,10 +3936,10 @@ not_found:
 
 static int rocker_port_fib_ipv4(struct rocker_port *rocker_port,
 				enum switchdev_trans trans, __be32 dst,
-				int dst_len, struct fib_info *fi, u32 tb_id,
-				int flags)
+				int dst_len, const struct fib_info *fi,
+				u32 tb_id, int flags)
 {
-	struct fib_nh *nh;
+	const struct fib_nh *nh;
 	__be16 eth_type = htons(ETH_P_IP);
 	__be32 dst_mask = inet_make_mask(dst_len);
 	__be16 internal_vlan_id = rocker_port->internal_vlan_id;
@@ -4029,12 +4044,12 @@ static int rocker_port_stop(struct net_device *dev)
 	return 0;
 }
 
-static void rocker_tx_desc_frags_unmap(struct rocker_port *rocker_port,
-				       struct rocker_desc_info *desc_info)
+static void rocker_tx_desc_frags_unmap(const struct rocker_port *rocker_port,
+				       const struct rocker_desc_info *desc_info)
 {
-	struct rocker *rocker = rocker_port->rocker;
+	const struct rocker *rocker = rocker_port->rocker;
 	struct pci_dev *pdev = rocker->pdev;
-	struct rocker_tlv *attrs[ROCKER_TLV_TX_MAX + 1];
+	const struct rocker_tlv *attrs[ROCKER_TLV_TX_MAX + 1];
 	struct rocker_tlv *attr;
 	int rem;
 
@@ -4042,7 +4057,7 @@ static void rocker_tx_desc_frags_unmap(struct rocker_port *rocker_port,
 	if (!attrs[ROCKER_TLV_TX_FRAGS])
 		return;
 	rocker_tlv_for_each_nested(attr, attrs[ROCKER_TLV_TX_FRAGS], rem) {
-		struct rocker_tlv *frag_attrs[ROCKER_TLV_TX_FRAG_ATTR_MAX + 1];
+		const struct rocker_tlv *frag_attrs[ROCKER_TLV_TX_FRAG_ATTR_MAX + 1];
 		dma_addr_t dma_handle;
 		size_t len;
 
@@ -4059,11 +4074,11 @@ static void rocker_tx_desc_frags_unmap(struct rocker_port *rocker_port,
 	}
 }
 
-static int rocker_tx_desc_frag_map_put(struct rocker_port *rocker_port,
+static int rocker_tx_desc_frag_map_put(const struct rocker_port *rocker_port,
 				       struct rocker_desc_info *desc_info,
 				       char *buf, size_t buf_len)
 {
-	struct rocker *rocker = rocker_port->rocker;
+	const struct rocker *rocker = rocker_port->rocker;
 	struct pci_dev *pdev = rocker->pdev;
 	dma_addr_t dma_handle;
 	struct rocker_tlv *frag;
@@ -4236,8 +4251,8 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 static int rocker_port_attr_get(struct net_device *dev,
 				struct switchdev_attr *attr)
 {
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	struct rocker *rocker = rocker_port->rocker;
+	const struct rocker_port *rocker_port = netdev_priv(dev);
+	const struct rocker *rocker = rocker_port->rocker;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_PARENT_ID:
@@ -4254,7 +4269,7 @@ static int rocker_port_attr_get(struct net_device *dev,
 	return 0;
 }
 
-static void rocker_port_trans_abort(struct rocker_port *rocker_port)
+static void rocker_port_trans_abort(const struct rocker_port *rocker_port)
 {
 	struct list_head *mem, *tmp;
 
@@ -4332,7 +4347,7 @@ static int rocker_port_vlan_add(struct rocker_port *rocker_port,
 
 static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 				 enum switchdev_trans trans,
-				 struct switchdev_obj_vlan *vlan)
+				 const struct switchdev_obj_vlan *vlan)
 {
 	u16 vid;
 	int err;
@@ -4349,7 +4364,7 @@ static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 
 static int rocker_port_fdb_add(struct rocker_port *rocker_port,
 			       enum switchdev_trans trans,
-			       struct switchdev_obj_fdb *fdb)
+			       const struct switchdev_obj_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
 	int flags = 0;
@@ -4364,7 +4379,7 @@ static int rocker_port_obj_add(struct net_device *dev,
 			       struct switchdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
-	struct switchdev_obj_ipv4_fib *fib4;
+	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	switch (obj->trans) {
@@ -4415,7 +4430,7 @@ static int rocker_port_vlan_del(struct rocker_port *rocker_port,
 }
 
 static int rocker_port_vlans_del(struct rocker_port *rocker_port,
-				 struct switchdev_obj_vlan *vlan)
+				 const struct switchdev_obj_vlan *vlan)
 {
 	u16 vid;
 	int err;
@@ -4431,7 +4446,7 @@ static int rocker_port_vlans_del(struct rocker_port *rocker_port,
 
 static int rocker_port_fdb_del(struct rocker_port *rocker_port,
 			       enum switchdev_trans trans,
-			       struct switchdev_obj_fdb *fdb)
+			       const struct switchdev_obj_fdb *fdb)
 {
 	__be16 vlan_id = rocker_port_vid_to_vlan(rocker_port, fdb->vid, NULL);
 	int flags = ROCKER_OP_FLAG_REMOVE;
@@ -4446,7 +4461,7 @@ static int rocker_port_obj_del(struct net_device *dev,
 			       struct switchdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
-	struct switchdev_obj_ipv4_fib *fib4;
+	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	switch (obj->id) {
@@ -4471,7 +4486,7 @@ static int rocker_port_obj_del(struct net_device *dev,
 	return err;
 }
 
-static int rocker_port_fdb_dump(struct rocker_port *rocker_port,
+static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 				struct switchdev_obj *obj)
 {
 	struct rocker *rocker = rocker_port->rocker;
@@ -4501,7 +4516,7 @@ static int rocker_port_fdb_dump(struct rocker_port *rocker_port,
 static int rocker_port_obj_dump(struct net_device *dev,
 				struct switchdev_obj *obj)
 {
-	struct rocker_port *rocker_port = netdev_priv(dev);
+	const struct rocker_port *rocker_port = netdev_priv(dev);
 	int err = 0;
 
 	switch (obj->id) {
@@ -4585,8 +4600,8 @@ static void rocker_port_get_strings(struct net_device *netdev, u32 stringset,
 }
 
 static int
-rocker_cmd_get_port_stats_prep(struct rocker *rocker,
-			       struct rocker_port *rocker_port,
+rocker_cmd_get_port_stats_prep(const struct rocker *rocker,
+			       const struct rocker_port *rocker_port,
 			       struct rocker_desc_info *desc_info,
 			       void *priv)
 {
@@ -4610,14 +4625,14 @@ rocker_cmd_get_port_stats_prep(struct rocker *rocker,
 }
 
 static int
-rocker_cmd_get_port_stats_ethtool_proc(struct rocker *rocker,
-				       struct rocker_port *rocker_port,
-				       struct rocker_desc_info *desc_info,
+rocker_cmd_get_port_stats_ethtool_proc(const struct rocker *rocker,
+				       const struct rocker_port *rocker_port,
+				       const struct rocker_desc_info *desc_info,
 				       void *priv)
 {
-	struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
-	struct rocker_tlv *stats_attrs[ROCKER_TLV_CMD_PORT_STATS_MAX + 1];
-	struct rocker_tlv *pattr;
+	const struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
+	const struct rocker_tlv *stats_attrs[ROCKER_TLV_CMD_PORT_STATS_MAX + 1];
+	const struct rocker_tlv *pattr;
 	u32 pport;
 	u64 *data = priv;
 	int i;
@@ -4703,8 +4718,8 @@ static struct rocker_port *rocker_port_napi_tx_get(struct napi_struct *napi)
 static int rocker_port_poll_tx(struct napi_struct *napi, int budget)
 {
 	struct rocker_port *rocker_port = rocker_port_napi_tx_get(napi);
-	struct rocker *rocker = rocker_port->rocker;
-	struct rocker_desc_info *desc_info;
+	const struct rocker *rocker = rocker_port->rocker;
+	const struct rocker_desc_info *desc_info;
 	u32 credits = 0;
 	int err;
 
@@ -4739,11 +4754,11 @@ static int rocker_port_poll_tx(struct napi_struct *napi, int budget)
 	return 0;
 }
 
-static int rocker_port_rx_proc(struct rocker *rocker,
-			       struct rocker_port *rocker_port,
+static int rocker_port_rx_proc(const struct rocker *rocker,
+			       const struct rocker_port *rocker_port,
 			       struct rocker_desc_info *desc_info)
 {
-	struct rocker_tlv *attrs[ROCKER_TLV_RX_MAX + 1];
+	const struct rocker_tlv *attrs[ROCKER_TLV_RX_MAX + 1];
 	struct sk_buff *skb = rocker_desc_cookie_ptr_get(desc_info);
 	size_t rx_len;
 
@@ -4776,7 +4791,7 @@ static struct rocker_port *rocker_port_napi_rx_get(struct napi_struct *napi)
 static int rocker_port_poll_rx(struct napi_struct *napi, int budget)
 {
 	struct rocker_port *rocker_port = rocker_port_napi_rx_get(napi);
-	struct rocker *rocker = rocker_port->rocker;
+	const struct rocker *rocker = rocker_port->rocker;
 	struct rocker_desc_info *desc_info;
 	u32 credits = 0;
 	int err;
@@ -4816,9 +4831,9 @@ static int rocker_port_poll_rx(struct napi_struct *napi, int budget)
  * PCI driver ops
  *****************/
 
-static void rocker_carrier_init(struct rocker_port *rocker_port)
+static void rocker_carrier_init(const struct rocker_port *rocker_port)
 {
-	struct rocker *rocker = rocker_port->rocker;
+	const struct rocker *rocker = rocker_port->rocker;
 	u64 link_status = rocker_read64(rocker, PORT_PHYS_LINK_STATUS);
 	bool link_up;
 
@@ -4829,7 +4844,7 @@ static void rocker_carrier_init(struct rocker_port *rocker_port)
 		netif_carrier_off(rocker_port->dev);
 }
 
-static void rocker_remove_ports(struct rocker *rocker)
+static void rocker_remove_ports(const struct rocker *rocker)
 {
 	struct rocker_port *rocker_port;
 	int i;
@@ -4843,10 +4858,10 @@ static void rocker_remove_ports(struct rocker *rocker)
 	kfree(rocker->ports);
 }
 
-static void rocker_port_dev_addr_init(struct rocker *rocker,
+static void rocker_port_dev_addr_init(const struct rocker *rocker,
 				      struct rocker_port *rocker_port)
 {
-	struct pci_dev *pdev = rocker->pdev;
+	const struct pci_dev *pdev = rocker->pdev;
 	int err;
 
 	err = rocker_cmd_get_port_settings_macaddr(rocker_port,
@@ -4859,7 +4874,7 @@ static void rocker_port_dev_addr_init(struct rocker *rocker,
 
 static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 {
-	struct pci_dev *pdev = rocker->pdev;
+	const struct pci_dev *pdev = rocker->pdev;
 	struct rocker_port *rocker_port;
 	struct net_device *dev;
 	int err;
@@ -4970,7 +4985,7 @@ err_enable_msix:
 	return err;
 }
 
-static void rocker_msix_fini(struct rocker *rocker)
+static void rocker_msix_fini(const struct rocker *rocker)
 {
 	pci_disable_msix(rocker->pdev);
 	kfree(rocker->msix_entries);
@@ -5136,7 +5151,7 @@ static struct pci_driver rocker_pci_driver = {
  * Net device notifier event handler
  ************************************/
 
-static bool rocker_port_dev_check(struct net_device *dev)
+static bool rocker_port_dev_check(const struct net_device *dev)
 {
 	return dev->netdev_ops == &rocker_port_netdev_ops;
 }
-- 
2.1.4
