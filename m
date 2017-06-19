From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH V3 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Mon, 19 Jun 2017 09:59:02 -0700
Message-ID: <20170619095902.5fadbe42@xeon-e3>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
        <20170617172431.177044-3-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
        <huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170617172431.177044-3-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 17 Jun 2017 18:24:25 +0100
Salil Mehta <salil.mehta@huawei.com> wrote:

> +
> +/* This struct defines the operation on the handle.
> + *
> + * init_ae_dev(): (mandatory)
> + *   Get PF configure from pci_dev and initialize PF hardware
> + * uninit_ae_dev()
> + *   Disable PF device and release PF resource
> + * register_client
> + *   Register client to ae_dev
> + * unregister_client()
> + *   Unregister client from ae_dev
> + * start()
> + *   Enable the hardware
> + * stop()
> + *   Disable the hardware
> + * get_status()
> + *   Get the carrier state of the back channel of the handle, 1 for ok, 0 for
> + *   non-ok
> + * get_ksettings_an_result()
> + *   Get negotiation status,speed and duplex
> + * update_speed_duplex_h()
> + *   Update hardware speed and duplex
> + * get_media_type()
> + *   Get media type of MAC
> + * adjust_link()
> + *   Adjust link status
> + * set_loopback()
> + *   Set loopback
> + * set_promisc_mode
> + *   Set promisc mode
> + * set_mtu()
> + *   set mtu
> + * get_pauseparam()
> + *   get tx and rx of pause frame use
> + * set_pauseparam()
> + *   set tx and rx of pause frame use
> + * set_autoneg()
> + *   set auto autonegotiation of pause frame use
> + * get_autoneg()
> + *   get auto autonegotiation of pause frame use
> + * get_coalesce_usecs()
> + *   get usecs to delay a TX interrupt after a packet is sent
> + * get_rx_max_coalesced_frames()
> + *   get Maximum number of packets to be sent before a TX interrupt.
> + * set_coalesce_usecs()
> + *   set usecs to delay a TX interrupt after a packet is sent
> + * set_coalesce_frames()
> + *   set Maximum number of packets to be sent before a TX interrupt.
> + * get_mac_addr()
> + *   get mac address
> + * set_mac_addr()
> + *   set mac address
> + * add_uc_addr
> + *   Add unicast addr to mac table
> + * rm_uc_addr
> + *   Remove unicast addr from mac table
> + * set_mc_addr()
> + *   Set multicast address
> + * add_mc_addr
> + *   Add multicast address to mac table
> + * rm_mc_addr
> + *   Remove multicast address from mac table
> + * update_stats()
> + *   Update Old network device statistics
> + * get_ethtool_stats()
> + *   Get ethtool network device statistics
> + * get_strings()
> + *   Get a set of strings that describe the requested objects
> + * get_sset_count()
> + *   Get number of strings that @get_strings will write
> + * update_led_status()
> + *   Update the led status
> + * set_led_id()
> + *   Set led id
> + * get_regs()
> + *   Get regs dump
> + * get_regs_len()
> + *   Get the len of the regs dump
> + * get_rss_key_size()
> + *   Get rss key size
> + * get_rss_indir_size()
> + *   Get rss indirection table size
> + * get_rss()
> + *   Get rss table
> + * set_rss()
> + *   Set rss table
> + * get_tc_size()
> + *   Get tc size of handle
> + * get_vector()
> + *   Get vector number and vector infomation
> + * map_ring_to_vector()
> + *   Map rings to vector
> + * unmap_ring_from_vector()
> + *   Unmap rings from vector
> + * add_tunnel_udp()
> + *   Add tunnel information to hardware
> + * del_tunnel_udp()
> + *   Delete tunnel information from hardware
> + * reset_queue()
> + *   Reset queue
> + * get_fw_version()
> + *   Get firmware version
> + * get_mdix_mode()
> + *   Get media typr of phy
> + * set_vlan_filter()
> + *   Set vlan filter config of Ports
> + * set_vf_vlan_filter()
> + *   Set vlan filter config of vf
> + */
> +struct hnae3_ae_ops {
> +	int (*init_ae_dev)(struct hnae3_ae_dev *ae_dev);
> +	void (*uninit_ae_dev)(struct hnae3_ae_dev *ae_dev);
> +
> +	int (*register_client)(struct hnae3_client *client,
> +			       struct hnae3_ae_dev *ae_dev);
> +	void (*unregister_client)(struct hnae3_client *client,
> +				  struct hnae3_ae_dev *ae_dev);
> +	int (*start)(struct hnae3_handle *handle);
> +	void (*stop)(struct hnae3_handle *handle);
> +	int (*get_status)(struct hnae3_handle *handle);
> +	void (*get_ksettings_an_result)(struct hnae3_handle *handle,
> +					u8 *auto_neg, u32 *speed, u8 *duplex);
> +
> +	int (*update_speed_duplex_h)(struct hnae3_handle *handle);
> +	int (*cfg_mac_speed_dup_h)(struct hnae3_handle *handle, int speed,
> +				   u8 duplex);
> +
> +	void (*get_media_type)(struct hnae3_handle *handle, u8 *media_type);
> +	void (*adjust_link)(struct hnae3_handle *handle, int speed, int duplex);
> +	int (*set_loopback)(struct hnae3_handle *handle,
> +			    enum hnae3_loop loop_mode, bool en);
> +
> +	void (*set_promisc_mode)(struct hnae3_handle *handle, u32 en);
> +	int (*set_mtu)(struct hnae3_handle *handle, int new_mtu);
> +
> +	void (*get_pauseparam)(struct hnae3_handle *handle,
> +			       u32 *auto_neg, u32 *rx_en, u32 *tx_en);
> +	int (*set_pauseparam)(struct hnae3_handle *handle,
> +			      u32 auto_neg, u32 rx_en, u32 tx_en);
> +
> +	int (*set_autoneg)(struct hnae3_handle *handle, bool enable);
> +	int (*get_autoneg)(struct hnae3_handle *handle);
> +
> +	void (*get_coalesce_usecs)(struct hnae3_handle *handle,
> +				   u32 *tx_usecs, u32 *rx_usecs);
> +	void (*get_rx_max_coalesced_frames)(struct hnae3_handle *handle,
> +					    u32 *tx_frames, u32 *rx_frames);
> +	int (*set_coalesce_usecs)(struct hnae3_handle *handle, u32 timeout);
> +	int (*set_coalesce_frames)(struct hnae3_handle *handle,
> +				   u32 coalesce_frames);
> +	void (*get_coalesce_range)(struct hnae3_handle *handle,
> +				   u32 *tx_frames_low, u32 *rx_frames_low,
> +				   u32 *tx_frames_high, u32 *rx_frames_high,
> +				   u32 *tx_usecs_low, u32 *rx_usecs_low,
> +				   u32 *tx_usecs_high, u32 *rx_usecs_high);
> +
> +	void (*get_mac_addr)(struct hnae3_handle *handle, u8 *p);
> +	int (*set_mac_addr)(struct hnae3_handle *handle, void *p);
> +	int (*add_uc_addr)(struct hnae3_handle *handle,
> +			   const unsigned char *addr);
> +	int (*rm_uc_addr)(struct hnae3_handle *handle,
> +			  const unsigned char *addr);
> +	int (*set_mc_addr)(struct hnae3_handle *handle, void *addr);
> +	int (*add_mc_addr)(struct hnae3_handle *handle,
> +			   const unsigned char *addr);
> +	int (*rm_mc_addr)(struct hnae3_handle *handle,
> +			  const unsigned char *addr);
> +
> +	void (*set_tso_stats)(struct hnae3_handle *handle, int enable);
> +	void (*update_stats)(struct hnae3_handle *handle,
> +			     struct net_device_stats *net_stats);
> +	void (*get_stats)(struct hnae3_handle *handle, u64 *data);
> +
> +	void (*get_strings)(struct hnae3_handle *handle,
> +			    u32 stringset, u8 *data);
> +	int (*get_sset_count)(struct hnae3_handle *handle, int stringset);
> +
> +	void (*get_regs)(struct hnae3_handle *handle, void *data);
> +	int (*get_regs_len)(struct hnae3_handle *handle);
> +
> +	u32 (*get_rss_key_size)(struct hnae3_handle *handle);
> +	u32 (*get_rss_indir_size)(struct hnae3_handle *handle);
> +	int (*get_rss)(struct hnae3_handle *handle, u32 *indir, u8 *key,
> +		       u8 *hfunc);
> +	int (*set_rss)(struct hnae3_handle *handle, const u32 *indir,
> +		       const u8 *key, const u8 hfunc);
> +
> +	int (*get_tc_size)(struct hnae3_handle *handle);
> +
> +	int (*get_vector)(struct hnae3_handle *handle, u16 vector_num,
> +			  struct hnae3_vector_info *vector_info);
> +	int (*map_ring_to_vector)(struct hnae3_handle *handle,
> +				  int vector_num,
> +				  struct hnae3_ring_chain_node *vr_chain);
> +	int (*unmap_ring_from_vector)(struct hnae3_handle *handle,
> +				      int vector_num,
> +				      struct hnae3_ring_chain_node *vr_chain);
> +
> +	int (*add_tunnel_udp)(struct hnae3_handle *handle, u16 port_num);
> +	int (*del_tunnel_udp)(struct hnae3_handle *handle, u16 port_num);
> +
> +	void (*reset_queue)(struct hnae3_handle *handle, u16 queue_id);
> +	u32 (*get_fw_version)(struct hnae3_handle *handle);
> +	void (*get_mdix_mode)(struct hnae3_handle *handle,
> +			      u8 *tp_mdix_ctrl, u8 *tp_mdix);
> +
> +	int (*set_vlan_filter)(struct hnae3_handle *handle, __be16 proto,
> +			       u16 vlan_id, bool is_kill);
> +	int (*set_vf_vlan_filter)(struct hnae3_handle *handle, int vfid,
> +				  u16 vlan, u8 qos, __be16 proto);
> +};
> +


Since ae_ops contains only function pointers. All definitions of it must be const
(and therefore pointers as well).
