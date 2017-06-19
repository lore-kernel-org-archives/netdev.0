From: Bo Yu <tsu.yubo@gmail.com>
Subject: Re: [PATCH V3 net-next 1/8] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Mon, 19 Jun 2017 08:57:22 +0800
Message-ID: <20170619005721.4x66u5mm35huqa4g@debian>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-2-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36128 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751980AbdFRQ5a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 12:57:30 -0400
Content-Disposition: inline
In-Reply-To: <20170617172431.177044-2-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
On Sat, Jun 17, 2017 at 06:24:24PM +0100, Salil Mehta wrote:
>+	struct notifier_block notifier_block;
>+	/* Vxlan/Geneve information */
>+	struct hns3_udp_tunnel udp_tnl[HNS3_UDP_TNL_MAX];
>+};
>+
>+/* the distance between [begin, end) in a ring buffer
>+ * note: there is a unuse slot between the begin and the end
>+ */
>+static inline int ring_dist(struct hns3_enet_ring *ring, int begin, int end)
>+{
>+	return (end - begin + ring->desc_num) % ring->desc_num;
>+}
>+
>+static inline int ring_space(struct hns3_enet_ring *ring)
>+{
>+	return ring->desc_num -
>+		ring_dist(ring, ring->next_to_clean, ring->next_to_use) - 1;
>+}
>+
>+static inline int is_ring_empty(struct hns3_enet_ring *ring)
>+{
>+	return ring->next_to_use == ring->next_to_clean;
>+}
>+
>+static inline void hns3_write_reg(void __iomem *base, u32 reg, u32 value)
>+{
>+	u8 __iomem *reg_addr = READ_ONCE(base);
>+
>+	writel(value, reg_addr + reg);
>+}
>+
>+#define hns3_write_dev(a, reg, value) \
>+	hns3_write_reg((a)->io_base, (reg), (value))
>+
>+#define hnae_queue_xmit(tqp, buf_num) writel_relaxed(buf_num, \
>+		(tqp)->io_base + HNS3_RING_TX_RING_TAIL_REG)
>+
>+#define ring_to_dev(ring) (&(ring)->tqp->handle->pdev->dev)
>+
>+#define ring_to_dma_dir(ring) (HNAE3_IS_TX_RING(ring) ? \
>+	DMA_TO_DEVICE : DMA_FROM_DEVICE)
>+
>+#define tx_ring_data(priv, idx) ((priv)->ring_data[idx])
>+
>+#define hnae_buf_size(_ring) ((_ring)->buf_size)
>+#define hnae_page_order(_ring) (get_order(hnae_buf_size(_ring)))
>+#define hnae_page_size(_ring) (PAGE_SIZE << hnae_page_order(_ring))
>+
>+/* iterator for handling rings in ring group */
>+#define hns3_for_each_ring(pos, head) \
>+	for (pos = (head).ring; pos != NULL; pos = pos->next)

Only a pos? Comparsion to NULL could be written "pos" noticed by
checkpatch.


>+
>+void hns3_ethtool_set_ops(struct net_device *ndev);
>+
>+int hns3_nic_net_xmit_hw(
>+				struct net_device *ndev,
>+				struct sk_buff *skb,
>+				struct hns3_nic_ring_data *ring_data);
>+int hns3_clean_tx_ring(struct hns3_enet_ring *ring, int budget);
>+int hns3_clean_rx_ring_ex(
>+				struct hns3_enet_ring *ring,
>+				struct sk_buff **skb_ex,
>+				int budget);
>+#endif
>--
>2.7.4
>
>
