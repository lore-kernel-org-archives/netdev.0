From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] net: hisilicon: constify hnae_buf_ops and hnae_ae_ops structures
Date: Sun,  6 Dec 2015 17:24:57 +0100
Message-ID: <1449419097-19032-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, davem@davemloft.net,
	huangdaode@hisilicon.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The hnae_buf_ops and hnae_ae_ops structures are never modified, so declare
them as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---

I have the impression that this driver is not recorded properly in the
MAINTAINERS file.

 drivers/net/ethernet/hisilicon/hns/hnae.c         |    4 ++--
 drivers/net/ethernet/hisilicon/hns/hnae.h         |   13 +++++++------
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |    2 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c     |    4 ++--
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  |   16 ++++++++--------
 5 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index b364529..8bf84ad 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -85,7 +85,7 @@ static void hnae_unmap_buffer(struct hnae_ring *ring, struct hnae_desc_cb *cb)
 			       ring_to_dma_dir(ring));
 }
 
-static struct hnae_buf_ops hnae_bops = {
+static const struct hnae_buf_ops hnae_bops = {
 	.alloc_buffer = hnae_alloc_buffer,
 	.free_buffer = hnae_free_buffer,
 	.map_buffer = hnae_map_buffer,
@@ -317,7 +317,7 @@ EXPORT_SYMBOL(hnae_reinit_handle);
  */
 struct hnae_handle *hnae_get_handle(struct device *owner_dev,
 				    const char *ae_id, u32 port_id,
-				    struct hnae_buf_ops *bops)
+				    const struct hnae_buf_ops *bops)
 {
 	struct hnae_ae_dev *dev;
 	struct hnae_handle *handle;
diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index cec95ac..95c4ee8 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -451,7 +451,7 @@ struct hnae_ae_ops {
 struct hnae_ae_dev {
 	struct device cls_dev; /* the class dev */
 	struct device *dev; /* the presented dev */
-	struct hnae_ae_ops *ops;
+	const struct hnae_ae_ops *ops;
 	struct list_head node;
 	struct module *owner; /* the module who provides this dev */
 	int id;
@@ -471,14 +471,15 @@ struct hnae_handle {
 	u32 eport_id;
 	enum hnae_port_type port_type;
 	struct list_head node;    /* list to hnae_ae_dev->handle_list */
-	struct hnae_buf_ops *bops; /* operation for the buffer */
+	const struct hnae_buf_ops *bops; /* operation for the buffer */
 	struct hnae_queue **qs;  /* array base of all queues */
 };
 
 #define ring_to_dev(ring) ((ring)->q->dev->dev)
 
 struct hnae_handle *hnae_get_handle(struct device *owner_dev, const char *ae_id,
-				    u32 port_id, struct hnae_buf_ops *bops);
+				    u32 port_id,
+				    const struct hnae_buf_ops *bops);
 void hnae_put_handle(struct hnae_handle *handle);
 int hnae_ae_register(struct hnae_ae_dev *dev, struct module *owner);
 void hnae_ae_unregister(struct hnae_ae_dev *dev);
@@ -497,7 +498,7 @@ int hnae_reinit_handle(struct hnae_handle *handle);
 static inline int hnae_reserve_buffer_map(struct hnae_ring *ring,
 					  struct hnae_desc_cb *cb)
 {
-	struct hnae_buf_ops *bops = ring->q->handle->bops;
+	const struct hnae_buf_ops *bops = ring->q->handle->bops;
 	int ret;
 
 	ret = bops->alloc_buffer(ring, cb);
@@ -536,7 +537,7 @@ static inline void hnae_buffer_detach(struct hnae_ring *ring, int i)
 
 static inline void hnae_free_buffer_detach(struct hnae_ring *ring, int i)
 {
-	struct hnae_buf_ops *bops = ring->q->handle->bops;
+	const struct hnae_buf_ops *bops = ring->q->handle->bops;
 	struct hnae_desc_cb *cb = &ring->desc_cb[i];
 
 	if (!ring->desc_cb[i].dma)
@@ -550,7 +551,7 @@ static inline void hnae_free_buffer_detach(struct hnae_ring *ring, int i)
 static inline void hnae_replace_buffer(struct hnae_ring *ring, int i,
 				       struct hnae_desc_cb *res_cb)
 {
-	struct hnae_buf_ops *bops = ring->q->handle->bops;
+	const struct hnae_buf_ops *bops = ring->q->handle->bops;
 	struct hnae_desc_cb tmp_cb = ring->desc_cb[i];
 
 	bops->unmap_buffer(ring, &ring->desc_cb[i]);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 1a16c03..06461d2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -730,7 +730,7 @@ int hns_ae_get_regs_len(struct hnae_handle *handle)
 	return total_num;
 }
 
-static struct hnae_ae_ops hns_dsaf_ops = {
+static const struct hnae_ae_ops hns_dsaf_ops = {
 	.get_handle = hns_ae_get_handle,
 	.put_handle = hns_ae_put_handle,
 	.init_queue = hns_ae_init_queue,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 08cef0d..8f5ad0d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -946,7 +946,7 @@ out_has_some_queues:
 static void hns_nic_net_down(struct net_device *ndev)
 {
 	int i;
-	struct hnae_ae_ops *ops;
+	const struct hnae_ae_ops *ops;
 	struct hns_nic_priv *priv = netdev_priv(ndev);
 
 	if (test_and_set_bit(NIC_STATE_DOWN, &priv->state))
@@ -1270,7 +1270,7 @@ static void hns_nic_update_link_status(struct net_device *netdev)
 static void hns_nic_dump(struct hns_nic_priv *priv)
 {
 	struct hnae_handle *h = priv->ae_handle;
-	struct hnae_ae_ops *ops = h->dev->ops;
+	const struct hnae_ae_ops *ops = h->dev->ops;
 	u32 *data, reg_num, i;
 
 	if (ops->get_regs_len && ops->get_regs) {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index a033212..7457b0b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -678,7 +678,7 @@ void hns_get_ringparam(struct net_device *net_dev,
 		       struct ethtool_ringparam *param)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
-	struct hnae_ae_ops *ops;
+	const struct hnae_ae_ops *ops;
 	struct hnae_queue *queue;
 	u32 uplimit = 0;
 
@@ -703,7 +703,7 @@ static void hns_get_pauseparam(struct net_device *net_dev,
 			       struct ethtool_pauseparam *param)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
-	struct hnae_ae_ops *ops;
+	const struct hnae_ae_ops *ops;
 
 	ops = priv->ae_handle->dev->ops;
 
@@ -724,7 +724,7 @@ static int hns_set_pauseparam(struct net_device *net_dev,
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 	struct hnae_handle *h;
-	struct hnae_ae_ops *ops;
+	const struct hnae_ae_ops *ops;
 
 	assert(priv || priv->ae_handle);
 
@@ -749,7 +749,7 @@ static int hns_get_coalesce(struct net_device *net_dev,
 			    struct ethtool_coalesce *ec)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
-	struct hnae_ae_ops *ops;
+	const struct hnae_ae_ops *ops;
 
 	ops = priv->ae_handle->dev->ops;
 
@@ -783,7 +783,7 @@ static int hns_set_coalesce(struct net_device *net_dev,
 			    struct ethtool_coalesce *ec)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
-	struct hnae_ae_ops *ops;
+	const struct hnae_ae_ops *ops;
 	int ret;
 
 	assert(priv || priv->ae_handle);
@@ -984,7 +984,7 @@ int hns_get_sset_count(struct net_device *netdev, int stringset)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_handle *h = priv->ae_handle;
-	struct hnae_ae_ops *ops = h->dev->ops;
+	const struct hnae_ae_ops *ops = h->dev->ops;
 
 	if (!ops->get_sset_count) {
 		netdev_err(netdev, "get_sset_count is null!\n");
@@ -1126,7 +1126,7 @@ void hns_get_regs(struct net_device *net_dev, struct ethtool_regs *cmd,
 		  void *data)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
-	struct hnae_ae_ops *ops;
+	const struct hnae_ae_ops *ops;
 
 	assert(priv || priv->ae_handle);
 
@@ -1150,7 +1150,7 @@ static int hns_get_regs_len(struct net_device *net_dev)
 {
 	u32 reg_num;
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
-	struct hnae_ae_ops *ops;
+	const struct hnae_ae_ops *ops;
 
 	assert(priv || priv->ae_handle);
 
