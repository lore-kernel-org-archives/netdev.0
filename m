From: Matthew Wilcox <willy@debian.org>
Subject: netdev_ops retraction
Date: Wed, 30 Jul 2003 19:44:16 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730184416.GI22222@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


So I've prototyped netdev_ops over a few drivers, and I don't like it.
Here's why I don't like it:

+struct netdev_ops {
+       struct net_device_stats * (*get_stats)(struct net_device *dev);
+       void    (*uninit)(struct net_device *dev);
+       void    (*destructor)(struct net_device *dev);
+       int     (*open)(struct net_device *dev);
+       int     (*stop)(struct net_device *dev);
+       int     (*hard_start_xmit)(struct sk_buff *skb, struct net_device *dev);
+       int     (*poll)(struct net_device *dev, int *quota);
+       int     (*hard_header)(struct sk_buff *skb, struct net_device *dev,
+                               unsigned short type, void *daddr,
+                               void *saddr, unsigned len);
+       int     (*rebuild_header)(struct sk_buff *skb);
+       void    (*set_multicast_list)(struct net_device *dev);
+       int     (*set_mac_address)(struct net_device *dev, void *addr);
+       int     (*do_ioctl)(struct net_device *dev, struct ifreq *ifr, int cmd);
+       int     (*set_config)(struct net_device *dev, struct ifmap *map);
+       int     (*hard_header_cache)(struct neighbour *neigh, struct hh_cache *hh);
+       void    (*header_cache_update)(struct hh_cache *hh,
+                       struct net_device *dev, unsigned char * haddr);
+       int     (*change_mtu)(struct net_device *dev, int new_mtu);
+       void    (*tx_timeout)(struct net_device *dev);
+       void    (*vlan_rx_register)(struct net_device *dev, struct vlan_group *grp);
+       void    (*vlan_rx_add_vid)(struct net_device *dev, unsigned short vid);
+       void    (*vlan_rx_kill_vid)(struct net_device *dev, unsigned short vid);
+       int     (*hard_header_parse)(struct sk_buff *skb, unsigned char *haddr);
+       int     (*neigh_setup)(struct net_device *dev, struct neigh_parms *);
+       int     (*accept_fastpath)(struct net_device *, struct dst_entry*);
+
+       int     (*get_settings)(struct net_device *, struct ethtool_cmd *);
+       int     (*set_settings)(struct net_device *, struct ethtool_cmd *);
+       void    (*get_drvinfo)(struct net_device *, struct ethtool_drvinfo *);
+       int     (*get_regs_len)(struct net_device *);
+       void    (*get_regs)(struct net_device *, struct ethtool_regs *, void *);
+       void    (*get_wol)(struct net_device *, struct ethtool_wolinfo *);
+       int     (*set_wol)(struct net_device *, struct ethtool_wolinfo *);
+       u32     (*get_msglevel)(struct net_device *);
+       void    (*set_msglevel)(struct net_device *, u32);
+       int     (*nway_reset)(struct net_device *);
+       u32     (*get_link)(struct net_device *);
+       int     (*get_eeprom)(struct net_device *, u32 offset, u32 len, u8 *, u32 magic);
+       int     (*set_eeprom)(struct net_device *, u32 offset, u32 len, u8 *, u32 magic);
+       int     (*get_coalesce)(struct net_device *, struct ethtool_coalesce *);
+       int     (*set_coalesce)(struct net_device *, struct ethtool_coalesce *);
+       void    (*get_ringparam)(struct net_device *, struct ethtool_ringparam *);
+       int     (*set_ringparam)(struct net_device *, struct ethtool_ringparam *);
+       void    (*get_pauseparam)(struct net_device *, struct ethtool_pauseparam *);
+       int     (*set_pauseparam)(struct net_device *, struct ethtool_pauseparam *);
+       u32     (*get_rx_csum)(struct net_device *);
+       int     (*set_rx_csum)(struct net_device *, u32);
+       u32     (*get_tx_csum)(struct net_device *);
+       int     (*set_tx_csum)(struct net_device *, u32);
+       u32     (*get_sg)(struct net_device *);
+       int     (*set_sg)(struct net_device *, u32);
+       int     (*self_test_count)(struct net_device *);
+       void    (*self_test)(struct net_device *, struct ethtool_test *, u64 *);
+       void    (*get_strings)(struct net_device *, u32 stringset, u8 *);
+       int     (*phys_id)(struct net_device *, u32);
+       int     (*get_stats_count)(struct net_device *);
+       void    (*get_ethtool_stats)(struct net_device *, struct ethtool_stats *, u64 *);
+};

Never mind the additional pointer dereference in the code, this is just
a horribly large data structure.  Unless someone convinces me otherwise,
I'm going to drop this idea and revert to doing ethtool_ops as a separate
data structure.  I think there's still scope for a netdev_ops patch,
but it's of dubious value and more of a 2.7 project.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
