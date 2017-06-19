From: Bo Yu <tsu.yubo@gmail.com>
Subject: Re: [PATCH V3 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Mon, 19 Jun 2017 08:40:02 +0800
Message-ID: <20170619004001.7akkdon47o3mspa4@debian>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-3-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32779 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750942AbdFRQkK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Jun 2017 12:40:10 -0400
Content-Disposition: inline
In-Reply-To: <20170617172431.177044-3-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
On Sat, Jun 17, 2017 at 06:24:25PM +0100, Salil Mehta wrote:
>+ *   Unregister client from ae_dev
>+ * start()
>+ *   Enable the hardware
>+ * stop()
>+ *   Disable the hardware
>+ * get_status()
>+ *   Get the carrier state of the back channel of the handle, 1 for ok, 0 for
>+ *   non-ok
>+ * get_ksettings_an_result()
>+ *   Get negotiation status,speed and duplex
>+ * update_speed_duplex_h()
>+ *   Update hardware speed and duplex
>+ * get_media_type()
>+ *   Get media type of MAC
>+ * adjust_link()
>+ *   Adjust link status
>+ * set_loopback()
>+ *   Set loopback
>+ * set_promisc_mode
>+ *   Set promisc mode
>+ * set_mtu()
>+ *   set mtu
>+ * get_pauseparam()
>+ *   get tx and rx of pause frame use
>+ * set_pauseparam()
>+ *   set tx and rx of pause frame use
>+ * set_autoneg()
>+ *   set auto autonegotiation of pause frame use
>+ * get_autoneg()
>+ *   get auto autonegotiation of pause frame use
>+ * get_coalesce_usecs()
>+ *   get usecs to delay a TX interrupt after a packet is sent
>+ * get_rx_max_coalesced_frames()
>+ *   get Maximum number of packets to be sent before a TX interrupt.
>+ * set_coalesce_usecs()
>+ *   set usecs to delay a TX interrupt after a packet is sent
>+ * set_coalesce_frames()
>+ *   set Maximum number of packets to be sent before a TX interrupt.
>+ * get_mac_addr()
>+ *   get mac address
>+ * set_mac_addr()
>+ *   set mac address
>+ * add_uc_addr
>+ *   Add unicast addr to mac table
>+ * rm_uc_addr
>+ *   Remove unicast addr from mac table
>+ * set_mc_addr()
>+ *   Set multicast address
>+ * add_mc_addr
>+ *   Add multicast address to mac table
>+ * rm_mc_addr
>+ *   Remove multicast address from mac table
>+ * update_stats()
>+ *   Update Old network device statistics
>+ * get_ethtool_stats()
>+ *   Get ethtool network device statistics
>+ * get_strings()
>+ *   Get a set of strings that describe the requested objects
>+ * get_sset_count()
>+ *   Get number of strings that @get_strings will write
>+ * update_led_status()
>+ *   Update the led status
>+ * set_led_id()
>+ *   Set led id
>+ * get_regs()
>+ *   Get regs dump
>+ * get_regs_len()
>+ *   Get the len of the regs dump
>+ * get_rss_key_size()
>+ *   Get rss key size
>+ * get_rss_indir_size()
>+ *   Get rss indirection table size
>+ * get_rss()
>+ *   Get rss table
>+ * set_rss()
>+ *   Set rss table
>+ * get_tc_size()
>+ *   Get tc size of handle
>+ * get_vector()
>+ *   Get vector number and vector infomation

Just another spealling : information

Checkpatch will report it also.

>+ * map_ring_to_vector()
>+ *   Map rings to vector
>+ * unmap_ring_from_vector()
>+ *   Unmap rings from vector
>+ * add_tunnel_udp()
>+ *   Add tunnel information to hardware
>+ * del_tunnel_udp()
>+ *   Delete tunnel information from hardware
>+ * reset_queue()
>+ *   Reset queue
>+ * get_fw_version()
>+ *   Get firmware version
>+ * get_mdix_mode()
>+ *   Get media typr of phy
>+ * set_vlan_filter()
>+ *   Set vlan filter config of Ports
>+ * set_vf_vlan_filter()
>+ *   Set vlan filter config of vf
>+ */
>+struct hnae3_ae_ops {
>+	int (*init_ae_dev)(struct hnae3_ae_dev *ae_dev);
>+	void (*uninit_ae_dev)(struct hnae3_ae_dev *ae_dev);
>+
>+	int (*register_client)(struct hnae3_client *client,
>+			       struct hnae3_ae_dev *ae_dev);
>+	void (*unregister_client)(struct hnae3_client *client,
>+				  struct hnae3_ae_dev *ae_dev);
>+	int (*start)(struct hnae3_handle *handle);
>+	void (*stop)(struct hnae3_handle *handle);
>+	int (*get_status)(struct hnae3_handle *handle);
>+	void (*get_ksettings_an_result)(struct hnae3_handle *handle,
>+					u8 *auto_neg, u32 *speed, u8 *duplex);
>+
>+	int (*update_speed_duplex_h)(struct hnae3_handle *handle);
>+	int (*cfg_mac_speed_dup_h)(struct hnae3_handle *handle, int speed,
>+				   u8 duplex);
>+
>+	void (*get_media_type)(struct hnae3_handle *handle, u8 *media_type);
>+	void (*adjust_link)(struct hnae3_handle *handle, int speed, int duplex);
>+	int (*set_loopback)(struct hnae3_handle *handle,
>+			    enum hnae3_loop loop_mode, bool en);
>+
>+	void (*set_promisc_mode)(struct hnae3_handle *handle, u32 en);
>+	int (*set_mtu)(struct hnae3_handle *handle, int new_mtu);
>+
>+	void (*get_pauseparam)(struct hnae3_handle *handle,
>+			       u32 *auto_neg, u32 *rx_en, u32 *tx_en);
>+	int (*set_pauseparam)(struct hnae3_handle *handle,
>+			      u32 auto_neg, u32 rx_en, u32 tx_en);
>+
>+	int (*set_autoneg)(struct hnae3_handle *handle, bool enable);
>+	int (*get_autoneg)(struct hnae3_handle *handle);
>+
>+	void (*get_coalesce_usecs)(struct hnae3_handle *handle,
>+				   u32 *tx_usecs, u32 *rx_usecs);
>+	void (*get_rx_max_coalesced_frames)(struct hnae3_handle *handle,
>+					    u32 *tx_frames, u32 *rx_frames);
>+	int (*set_coalesce_usecs)(struct hnae3_handle *handle, u32 timeout);
>+	int (*set_coalesce_frames)(struct hnae3_handle *handle,
>+				   u32 coalesce_frames);
>+	void (*get_coalesce_range)(struct hnae3_handle *handle,
>+				   u32 *tx_frames_low, u32 *rx_frames_low,
>+				   u32 *tx_frames_high, u32 *rx_frames_high,
>+				   u32 *tx_usecs_low, u32 *rx_usecs_low,
>+				   u32 *tx_usecs_high, u32 *rx_usecs_high);
>+
>+	void (*get_mac_addr)(struct hnae3_handle *handle, u8 *p);
>+	int (*set_mac_addr)(struct hnae3_handle *handle, void *p);
>+	int (*add_uc_addr)(struct hnae3_handle *handle,
>+			   const unsigned char *addr);
>+	int (*rm_uc_addr)(struct hnae3_handle *handle,
>+			  const unsigned char *addr);
>+	int (*set_mc_addr)(struct hnae3_handle *handle, void *addr);
>+	int (*add_mc_addr)(struct hnae3_handle *handle,
>+			   const unsigned char *addr);
>+	int (*rm_mc_addr)(struct hnae3_handle *handle,
>+			  const unsigned char *addr);
>+
>+	void (*set_tso_stats)(struct hnae3_handle *handle, int enable);
>+	void (*update_stats)(struct hnae3_handle *handle,
>+			     struct net_device_stats *net_stats);
>+	void (*get_stats)(struct hnae3_handle *handle, u64 *data);
>+
>+	void (*get_strings)(struct hnae3_handle *handle,
>+			    u32 stringset, u8 *data);
>+	int (*get_sset_count)(struct hnae3_handle *handle, int stringset);
>+
>+	void (*get_regs)(struct hnae3_handle *handle, void *data);
>+	int (*get_regs_len)(struct hnae3_handle *handle);
>+
>+	u32 (*get_rss_key_size)(struct hnae3_handle *handle);
>+	u32 (*get_rss_indir_size)(struct hnae3_handle *handle);
>+	int (*get_rss)(struct hnae3_handle *handle, u32 *indir, u8 *key,
>+		       u8 *hfunc);
>+	int (*set_rss)(struct hnae3_handle *handle, const u32 *indir,
>+		       const u8 *key, const u8 hfunc);
>+
>+	int (*get_tc_size)(struct hnae3_handle *handle);
>+
>+	int (*get_vector)(struct hnae3_handle *handle, u16 vector_num,
>+			  struct hnae3_vector_info *vector_info);
>+	int (*map_ring_to_vector)(struct hnae3_handle *handle,
>+				  int vector_num,
>+				  struct hnae3_ring_chain_node *vr_chain);
>+	int (*unmap_ring_from_vector)(struct hnae3_handle *handle,
>+				      int vector_num,
>+				      struct hnae3_ring_chain_node *vr_chain);
>+
>+	int (*add_tunnel_udp)(struct hnae3_handle *handle, u16 port_num);
>+	int (*del_tunnel_udp)(struct hnae3_handle *handle, u16 port_num);
>+
>+	void (*reset_queue)(struct hnae3_handle *handle, u16 queue_id);
>+	u32 (*get_fw_version)(struct hnae3_handle *handle);
>+	void (*get_mdix_mode)(struct hnae3_handle *handle,
>+			      u8 *tp_mdix_ctrl, u8 *tp_mdix);
>+
>+	int (*set_vlan_filter)(struct hnae3_handle *handle, __be16 proto,
>+			       u16 vlan_id, bool is_kill);
>+	int (*set_vf_vlan_filter)(struct hnae3_handle *handle, int vfid,
>+				  u16 vlan, u8 qos, __be16 proto);
>+};
>+
>+struct hnae3_ae_algo {
>+	struct hnae3_ae_ops *ops;
>+	struct list_head node;
>+	char name[HNAE3_CLASS_NAME_SIZE];
>+	const struct pci_device_id *pdev_id_table;
>+};
>+
>+#define HNAE3_INT_NAME_LEN        (IFNAMSIZ + 16)
>+#define HNAE3_ITR_COUNTDOWN_START 100
>+
>+struct hnae3_tc_info {
>+	u16	tqp_offset;	/* TQP offset from base TQP */
>+	u16	tqp_count;	/* Total TQPs */
>+	u8	up;		/* user priority */
>+	u8	tc;		/* TC index */
>+	bool	enable;		/* If this TC is enable or not */
>+};
>+
>+#define HNAE3_MAX_TC		8
>+struct hnae3_knic_private_info {
>+	struct net_device *netdev; /* Set by KNIC client when init instance */
>+	u16 rss_size;		   /* Allocated RSS queues */
>+	u16 rx_buf_len;
>+	u16 num_desc;
>+
>+	u8 num_tc;		   /* Total number of enabled TCs */
>+	struct hnae3_tc_info tc_info[HNAE3_MAX_TC]; /* Idx of array is HW TC */
>+
>+	u16 num_tqps;		  /* total number of TQPs in this handle */
>+	struct hnae3_queue **tqp;  /* array base of all TQPs in this instance */
>+};
>+
>+struct hnae3_roce_private_info {
>+	void __iomem *roce_io_base;
>+	struct net_device *netdev;
>+	int base_vector;
>+	int num_vectors;
>+};
>+
>+struct hnae3_unic_private_info {
>+	u16 rx_buf_len;
>+	u16 num_desc;
>+	u16 num_tqps;	/* total number of tqps in this handle */
>+	struct hnae3_queue **tqp;  /* array base of all TQPs of this instance */
>+};
>+
>+#define HNAE3_SUPPORT_MAC_LOOPBACK    1
>+#define HNAE3_SUPPORT_PHY_LOOPBACK    2
>+#define HNAE3_SUPPORT_SERDES_LOOPBACK 4
>+
>+struct hnae3_handle {
>+	struct hnae3_client *client;
>+	struct pci_dev *pdev;
>+	void *priv;
>+	struct hnae3_ae_algo *ae_algo;  /* the class who provides this handle */
>+	u64 flags; /* Indicate the capabilities for this handle*/
>+
>+	union {
>+		struct hnae3_knic_private_info kinfo;
>+		struct hnae3_unic_private_info uinfo;
>+		struct hnae3_roce_private_info rinfo;
>+	};
>+
>+	u32 numa_node_mask;	/* for multi-chip support */
>+};
>+
>+#define hnae_set_field(origin, mask, shift, val) \
>+	do { \
>+		(origin) &= (~(mask)); \
>+		(origin) |= ((val) << (shift)) & (mask); \
>+	} while (0)
>+#define hnae_get_field(origin, mask, shift) (((origin) & (mask)) >> (shift))
>+
>+#define hnae_set_bit(origin, shift, val) \
>+	hnae_set_field((origin), (0x1 << (shift)), (shift), (val))
>+#define hnae_get_bit(origin, shift) \
>+	hnae_get_field((origin), (0x1 << (shift)), (shift))
>+
>+int hnae3_register_ae_dev(struct hnae3_ae_dev *ae_dev);
>+void hnae3_unregister_ae_dev(struct hnae3_ae_dev *ae_dev);
>+
>+void hnae3_unregister_ae_algo(struct hnae3_ae_algo *ae_algo);
>+int hnae3_register_ae_algo(struct hnae3_ae_algo *ae_algo);
>+
>+void hnae3_unregister_client(struct hnae3_client *client);
>+int hnae3_register_client(struct hnae3_client *client);
>+#endif
>--
>2.7.4
>
>
