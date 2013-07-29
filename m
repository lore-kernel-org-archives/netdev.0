From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH 2/3] include: Convert ethernet mac address declarations to use ETH_ALEN
Date: Mon, 29 Jul 2013 13:59:24 +0200
Message-ID: <2929374.frUlkyTFNL@vostro.rjw.lan>
References: <cover.1375075325.git.joe@perches.com> <a769aba61c43967257854413f16d2b935cc54972.1375075325.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, Len Brown <lenb@kernel.org>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Mauro Carvalho Chehab <m.chehab@samsung.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org,
	linux-media@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <a769aba61c43967257854413f16d2b935cc54972.1375075325.git.joe@perches.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday, July 28, 2013 10:29:04 PM Joe Perches wrote:
> It's convenient to have ethernet mac addresses use
> ETH_ALEN to be able to grep for them a bit easier and
> also to ensure that the addresses are __aligned(2).
> 
> Add #include <linux/if_ether.h> as necessary.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  include/acpi/actbl2.h           |  4 ++-
>  include/linux/dm9000.h          |  4 ++-
>  include/linux/fs_enet_pd.h      |  3 ++-
>  include/linux/ieee80211.h       | 59 +++++++++++++++++++++--------------------
>  include/linux/mlx4/device.h     | 11 ++++----
>  include/linux/mlx4/qp.h         |  5 ++--
>  include/linux/mv643xx_eth.h     |  3 ++-
>  include/linux/sh_eth.h          |  3 ++-
>  include/linux/smsc911x.h        |  3 ++-
>  include/linux/uwb/spec.h        |  5 ++--
>  include/media/tveeprom.h        |  4 ++-
>  include/net/irda/irlan_common.h |  3 ++-
>  12 files changed, 61 insertions(+), 46 deletions(-)
> 
> diff --git a/include/acpi/actbl2.h b/include/acpi/actbl2.h
> index ffaac0e..3f0f11c 100644
> --- a/include/acpi/actbl2.h
> +++ b/include/acpi/actbl2.h
> @@ -44,6 +44,8 @@
>  #ifndef __ACTBL2_H__
>  #define __ACTBL2_H__
>  
> +#include <linux/if_ether.h>
> +
>  /*******************************************************************************
>   *
>   * Additional ACPI Tables (2)
> @@ -605,7 +607,7 @@ struct acpi_ibft_nic {
>  	u8 secondary_dns[16];
>  	u8 dhcp[16];
>  	u16 vlan;
> -	u8 mac_address[6];
> +	u8 mac_address[ETH_ALEN];
>  	u16 pci_address;
>  	u16 name_length;
>  	u16 name_offset;

Please don't touch this file.

It comes from a code base outside of the kernel and should be kept in sync with
the upstream.

Thanks,
Rafael


> diff --git a/include/linux/dm9000.h b/include/linux/dm9000.h
> index 96e8769..841925f 100644
> --- a/include/linux/dm9000.h
> +++ b/include/linux/dm9000.h
> @@ -14,6 +14,8 @@
>  #ifndef __DM9000_PLATFORM_DATA
>  #define __DM9000_PLATFORM_DATA __FILE__
>  
> +#include <linux/if_ether.h>
> +
>  /* IO control flags */
>  
>  #define DM9000_PLATF_8BITONLY	(0x0001)
> @@ -27,7 +29,7 @@
>  
>  struct dm9000_plat_data {
>  	unsigned int	flags;
> -	unsigned char	dev_addr[6];
> +	unsigned char	dev_addr[ETH_ALEN];
>  
>  	/* allow replacement IO routines */
>  
> diff --git a/include/linux/fs_enet_pd.h b/include/linux/fs_enet_pd.h
> index 51b7934..343d82a 100644
> --- a/include/linux/fs_enet_pd.h
> +++ b/include/linux/fs_enet_pd.h
> @@ -18,6 +18,7 @@
>  
>  #include <linux/string.h>
>  #include <linux/of_mdio.h>
> +#include <linux/if_ether.h>
>  #include <asm/types.h>
>  
>  #define FS_ENET_NAME	"fs_enet"
> @@ -135,7 +136,7 @@ struct fs_platform_info {
>  	const struct fs_mii_bus_info *bus_info;
>  
>  	int rx_ring, tx_ring;	/* number of buffers on rx     */
> -	__u8 macaddr[6];	/* mac address                 */
> +	__u8 macaddr[ETH_ALEN];	/* mac address                 */
>  	int rx_copybreak;	/* limit we copy small frames  */
>  	int use_napi;		/* use NAPI                    */
>  	int napi_weight;	/* NAPI weight                 */
> diff --git a/include/linux/ieee80211.h b/include/linux/ieee80211.h
> index b0dc87a..4e101af 100644
> --- a/include/linux/ieee80211.h
> +++ b/include/linux/ieee80211.h
> @@ -16,6 +16,7 @@
>  #define LINUX_IEEE80211_H
>  
>  #include <linux/types.h>
> +#include <linux/if_ether.h>
>  #include <asm/byteorder.h>
>  
>  /*
> @@ -209,28 +210,28 @@ static inline u16 ieee80211_sn_sub(u16 sn1, u16 sn2)
>  struct ieee80211_hdr {
>  	__le16 frame_control;
>  	__le16 duration_id;
> -	u8 addr1[6];
> -	u8 addr2[6];
> -	u8 addr3[6];
> +	u8 addr1[ETH_ALEN];
> +	u8 addr2[ETH_ALEN];
> +	u8 addr3[ETH_ALEN];
>  	__le16 seq_ctrl;
> -	u8 addr4[6];
> +	u8 addr4[ETH_ALEN];
>  } __packed __aligned(2);
>  
>  struct ieee80211_hdr_3addr {
>  	__le16 frame_control;
>  	__le16 duration_id;
> -	u8 addr1[6];
> -	u8 addr2[6];
> -	u8 addr3[6];
> +	u8 addr1[ETH_ALEN];
> +	u8 addr2[ETH_ALEN];
> +	u8 addr3[ETH_ALEN];
>  	__le16 seq_ctrl;
>  } __packed __aligned(2);
>  
>  struct ieee80211_qos_hdr {
>  	__le16 frame_control;
>  	__le16 duration_id;
> -	u8 addr1[6];
> -	u8 addr2[6];
> -	u8 addr3[6];
> +	u8 addr1[ETH_ALEN];
> +	u8 addr2[ETH_ALEN];
> +	u8 addr3[ETH_ALEN];
>  	__le16 seq_ctrl;
>  	__le16 qos_ctrl;
>  } __packed __aligned(2);
> @@ -608,8 +609,8 @@ struct ieee80211s_hdr {
>  	u8 flags;
>  	u8 ttl;
>  	__le32 seqnum;
> -	u8 eaddr1[6];
> -	u8 eaddr2[6];
> +	u8 eaddr1[ETH_ALEN];
> +	u8 eaddr2[ETH_ALEN];
>  } __packed __aligned(2);
>  
>  /* Mesh flags */
> @@ -758,7 +759,7 @@ struct ieee80211_rann_ie {
>  	u8 rann_flags;
>  	u8 rann_hopcount;
>  	u8 rann_ttl;
> -	u8 rann_addr[6];
> +	u8 rann_addr[ETH_ALEN];
>  	__le32 rann_seq;
>  	__le32 rann_interval;
>  	__le32 rann_metric;
> @@ -802,9 +803,9 @@ enum ieee80211_vht_opmode_bits {
>  struct ieee80211_mgmt {
>  	__le16 frame_control;
>  	__le16 duration;
> -	u8 da[6];
> -	u8 sa[6];
> -	u8 bssid[6];
> +	u8 da[ETH_ALEN];
> +	u8 sa[ETH_ALEN];
> +	u8 bssid[ETH_ALEN];
>  	__le16 seq_ctrl;
>  	union {
>  		struct {
> @@ -833,7 +834,7 @@ struct ieee80211_mgmt {
>  		struct {
>  			__le16 capab_info;
>  			__le16 listen_interval;
> -			u8 current_ap[6];
> +			u8 current_ap[ETH_ALEN];
>  			/* followed by SSID and Supported rates */
>  			u8 variable[0];
>  		} __packed reassoc_req;
> @@ -966,21 +967,21 @@ struct ieee80211_vendor_ie {
>  struct ieee80211_rts {
>  	__le16 frame_control;
>  	__le16 duration;
> -	u8 ra[6];
> -	u8 ta[6];
> +	u8 ra[ETH_ALEN];
> +	u8 ta[ETH_ALEN];
>  } __packed __aligned(2);
>  
>  struct ieee80211_cts {
>  	__le16 frame_control;
>  	__le16 duration;
> -	u8 ra[6];
> +	u8 ra[ETH_ALEN];
>  } __packed __aligned(2);
>  
>  struct ieee80211_pspoll {
>  	__le16 frame_control;
>  	__le16 aid;
> -	u8 bssid[6];
> -	u8 ta[6];
> +	u8 bssid[ETH_ALEN];
> +	u8 ta[ETH_ALEN];
>  } __packed __aligned(2);
>  
>  /* TDLS */
> @@ -989,14 +990,14 @@ struct ieee80211_pspoll {
>  struct ieee80211_tdls_lnkie {
>  	u8 ie_type; /* Link Identifier IE */
>  	u8 ie_len;
> -	u8 bssid[6];
> -	u8 init_sta[6];
> -	u8 resp_sta[6];
> +	u8 bssid[ETH_ALEN];
> +	u8 init_sta[ETH_ALEN];
> +	u8 resp_sta[ETH_ALEN];
>  } __packed;
>  
>  struct ieee80211_tdls_data {
> -	u8 da[6];
> -	u8 sa[6];
> +	u8 da[ETH_ALEN];
> +	u8 sa[ETH_ALEN];
>  	__be16 ether_type;
>  	u8 payload_type;
>  	u8 category;
> @@ -1090,8 +1091,8 @@ struct ieee80211_p2p_noa_attr {
>  struct ieee80211_bar {
>  	__le16 frame_control;
>  	__le16 duration;
> -	__u8 ra[6];
> -	__u8 ta[6];
> +	__u8 ra[ETH_ALEN];
> +	__u8 ta[ETH_ALEN];
>  	__le16 control;
>  	__le16 start_seq_num;
>  } __packed;
> diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
> index 52c23a8..e37ac2b 100644
> --- a/include/linux/mlx4/device.h
> +++ b/include/linux/mlx4/device.h
> @@ -33,6 +33,7 @@
>  #ifndef MLX4_DEVICE_H
>  #define MLX4_DEVICE_H
>  
> +#include <linux/if_ether.h>
>  #include <linux/pci.h>
>  #include <linux/completion.h>
>  #include <linux/radix-tree.h>
> @@ -619,7 +620,7 @@ struct mlx4_eth_av {
>  	u8		dgid[16];
>  	u32		reserved4[2];
>  	__be16		vlan;
> -	u8		mac[6];
> +	u8		mac[ETH_ALEN];
>  };
>  
>  union mlx4_ext_av {
> @@ -913,10 +914,10 @@ enum mlx4_net_trans_promisc_mode {
>  };
>  
>  struct mlx4_spec_eth {
> -	u8	dst_mac[6];
> -	u8	dst_mac_msk[6];
> -	u8	src_mac[6];
> -	u8	src_mac_msk[6];
> +	u8	dst_mac[ETH_ALEN];
> +	u8	dst_mac_msk[ETH_ALEN];
> +	u8	src_mac[ETH_ALEN];
> +	u8	src_mac_msk[ETH_ALEN];
>  	u8	ether_type_enable;
>  	__be16	ether_type;
>  	__be16	vlan_id_msk;
> diff --git a/include/linux/mlx4/qp.h b/include/linux/mlx4/qp.h
> index 262deac..6d35147 100644
> --- a/include/linux/mlx4/qp.h
> +++ b/include/linux/mlx4/qp.h
> @@ -34,6 +34,7 @@
>  #define MLX4_QP_H
>  
>  #include <linux/types.h>
> +#include <linux/if_ether.h>
>  
>  #include <linux/mlx4/device.h>
>  
> @@ -143,7 +144,7 @@ struct mlx4_qp_path {
>  	u8			feup;
>  	u8			fvl_rx;
>  	u8			reserved4[2];
> -	u8			dmac[6];
> +	u8			dmac[ETH_ALEN];
>  };
>  
>  enum { /* fl */
> @@ -318,7 +319,7 @@ struct mlx4_wqe_datagram_seg {
>  	__be32			dqpn;
>  	__be32			qkey;
>  	__be16			vlan;
> -	u8			mac[6];
> +	u8			mac[ETH_ALEN];
>  };
>  
>  struct mlx4_wqe_lso_seg {
> diff --git a/include/linux/mv643xx_eth.h b/include/linux/mv643xx_eth.h
> index 6e8215b..61a0da3 100644
> --- a/include/linux/mv643xx_eth.h
> +++ b/include/linux/mv643xx_eth.h
> @@ -6,6 +6,7 @@
>  #define __LINUX_MV643XX_ETH_H
>  
>  #include <linux/mbus.h>
> +#include <linux/if_ether.h>
>  
>  #define MV643XX_ETH_SHARED_NAME		"mv643xx_eth"
>  #define MV643XX_ETH_NAME		"mv643xx_eth_port"
> @@ -48,7 +49,7 @@ struct mv643xx_eth_platform_data {
>  	 * Use this MAC address if it is valid, overriding the
>  	 * address that is already in the hardware.
>  	 */
> -	u8			mac_addr[6];
> +	u8			mac_addr[ETH_ALEN];
>  
>  	/*
>  	 * If speed is 0, autonegotiation is enabled.
> diff --git a/include/linux/sh_eth.h b/include/linux/sh_eth.h
> index fc30571..6205eeb 100644
> --- a/include/linux/sh_eth.h
> +++ b/include/linux/sh_eth.h
> @@ -2,6 +2,7 @@
>  #define __ASM_SH_ETH_H__
>  
>  #include <linux/phy.h>
> +#include <linux/if_ether.h>
>  
>  enum {EDMAC_LITTLE_ENDIAN, EDMAC_BIG_ENDIAN};
>  enum {
> @@ -18,7 +19,7 @@ struct sh_eth_plat_data {
>  	phy_interface_t phy_interface;
>  	void (*set_mdio_gate)(void *addr);
>  
> -	unsigned char mac_addr[6];
> +	unsigned char mac_addr[ETH_ALEN];
>  	unsigned no_ether_link:1;
>  	unsigned ether_link_active_low:1;
>  	unsigned needs_init:1;
> diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
> index 4dde70e..eec3efd 100644
> --- a/include/linux/smsc911x.h
> +++ b/include/linux/smsc911x.h
> @@ -22,6 +22,7 @@
>  #define __LINUX_SMSC911X_H__
>  
>  #include <linux/phy.h>
> +#include <linux/if_ether.h>
>  
>  /* platform_device configuration data, should be assigned to
>   * the platform_device's dev.platform_data */
> @@ -31,7 +32,7 @@ struct smsc911x_platform_config {
>  	unsigned int flags;
>  	unsigned int shift;
>  	phy_interface_t phy_interface;
> -	unsigned char mac[6];
> +	unsigned char mac[ETH_ALEN];
>  };
>  
>  /* Constants for platform_device irq polarity configuration */
> diff --git a/include/linux/uwb/spec.h b/include/linux/uwb/spec.h
> index b52e44f..0df24bf 100644
> --- a/include/linux/uwb/spec.h
> +++ b/include/linux/uwb/spec.h
> @@ -32,6 +32,7 @@
>  
>  #include <linux/types.h>
>  #include <linux/bitmap.h>
> +#include <linux/if_ether.h>
>  
>  #define i1480_FW 0x00000303
>  /* #define i1480_FW 0x00000302 */
> @@ -130,7 +131,7 @@ enum { UWB_DRP_BACKOFF_WIN_MAX = 16 };
>   * it is also used to define headers sent down and up the wire/radio).
>   */
>  struct uwb_mac_addr {
> -	u8 data[6];
> +	u8 data[ETH_ALEN];
>  } __attribute__((packed));
>  
>  
> @@ -568,7 +569,7 @@ struct uwb_rc_evt_confirm {
>  /* Device Address Management event. [WHCI] section 3.1.3.2. */
>  struct uwb_rc_evt_dev_addr_mgmt {
>  	struct uwb_rceb rceb;
> -	u8 baAddr[6];
> +	u8 baAddr[ETH_ALEN];
>  	u8 bResultCode;
>  } __attribute__((packed));
>  
> diff --git a/include/media/tveeprom.h b/include/media/tveeprom.h
> index 4a1191a..f7119ee 100644
> --- a/include/media/tveeprom.h
> +++ b/include/media/tveeprom.h
> @@ -12,6 +12,8 @@ enum tveeprom_audio_processor {
>  	TVEEPROM_AUDPROC_OTHER,
>  };
>  
> +#include <linux/if_ether.h>
> +
>  struct tveeprom {
>  	u32 has_radio;
>  	/* If has_ir == 0, then it is unknown what the IR capabilities are,
> @@ -40,7 +42,7 @@ struct tveeprom {
>  	u32 revision;
>  	u32 serial_number;
>  	char rev_str[5];
> -	u8 MAC_address[6];
> +	u8 MAC_address[ETH_ALEN];
>  };
>  
>  void tveeprom_hauppauge_analog(struct i2c_client *c, struct tveeprom *tvee,
> diff --git a/include/net/irda/irlan_common.h b/include/net/irda/irlan_common.h
> index 0af8b8d..550c2d6 100644
> --- a/include/net/irda/irlan_common.h
> +++ b/include/net/irda/irlan_common.h
> @@ -32,6 +32,7 @@
>  #include <linux/types.h>
>  #include <linux/skbuff.h>
>  #include <linux/netdevice.h>
> +#include <linux/if_ether.h>
>  
>  #include <net/irda/irttp.h>
>  
> @@ -161,7 +162,7 @@ struct irlan_provider_cb {
>  	int access_type;     /* Access type */
>  	__u16 send_arb_val;
>  
> -	__u8 mac_address[6]; /* Generated MAC address for peer device */
> +	__u8 mac_address[ETH_ALEN]; /* Generated MAC address for peer device */
>  };
>  
>  /*
> 
-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
