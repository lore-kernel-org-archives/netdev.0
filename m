From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] usb: pegasus: fixed coding style issues
Date: Sun, 27 Jun 2010 05:47:21 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1006270545570.2377@gabi>
References: <20100626185854.4a3eff43@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Petko Manolov <petkan@users.sourceforge.net>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Nicolas Kaiser <nikai@nikai.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([78.83.248.164]:45886 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754092Ab0F0Cql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 22:46:41 -0400
In-Reply-To: <20100626185854.4a3eff43@absol.kitzblitz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think the old code is what "Lindent" script outputs.  To me it doesn't 
matter either way. :-)


 		Petko


On Sat, 26 Jun 2010, Nicolas Kaiser wrote:

> Fixed brace, static initialization, comment, whitespace and spacing
> coding style issues.
>
> Signed-off-by: Nicolas Kaiser <nikai@nikai.net>
> ---
> drivers/net/usb/pegasus.c |  125 +++++++++----------
> drivers/net/usb/pegasus.h |  296 ++++++++++++++++++++++----------------------
> 2 files changed, 209 insertions(+), 212 deletions(-)
>
> diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
> index 974d17f..6710f09 100644
> --- a/drivers/net/usb/pegasus.c
> +++ b/drivers/net/usb/pegasus.c
> @@ -21,11 +21,11 @@
>  *			behaves. Pegasus II support added since this version.
>  *			TODO: suppressing HCD warnings spewage on disconnect.
>  *		v0.4.13	Ethernet address is now set at probe(), not at open()
> - *			time as this seems to break dhcpd.
> + *			time as this seems to break dhcpd.
>  *		v0.5.0	branch to 2.5.x kernels
>  *		v0.5.1	ethtool support added
>  *		v0.5.5	rx socket buffers are in a pool and the their allocation
> - * 			is out of the interrupt routine.
> + *			is out of the interrupt routine.
>  */
>
> #include <linux/sched.h>
> @@ -55,9 +55,9 @@ static const char driver_name[] = "pegasus";
> #define	BMSR_MEDIA	(BMSR_10HALF | BMSR_10FULL | BMSR_100HALF | \
> 			BMSR_100FULL | BMSR_ANEGCAPABLE)
>
> -static int loopback = 0;
> -static int mii_mode = 0;
> -static char *devid=NULL;
> +static int loopback;
> +static int mii_mode;
> +static char *devid;
>
> static struct usb_eth_dev usb_dev_id[] = {
> #define	PEGASUS_DEV(pn, vid, pid, flags)	\
> @@ -102,8 +102,8 @@ MODULE_PARM_DESC(devid, "The format is: 'DEV_name:VendorID:DeviceID:Flags'");
>
> /* use ethtool to change the level for any given device */
> static int msg_level = -1;
> -module_param (msg_level, int, 0);
> -MODULE_PARM_DESC (msg_level, "Override default message level");
> +module_param(msg_level, int, 0);
> +MODULE_PARM_DESC(msg_level, "Override default message level");
>
> MODULE_DEVICE_TABLE(usb, pegasus_ids);
> static const struct net_device_ops pegasus_netdev_ops;
> @@ -141,7 +141,7 @@ static void ctrl_callback(struct urb *urb)
> 	wake_up(&pegasus->ctrl_wait);
> }
>
> -static int get_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
> +static int get_registers(pegasus_t *pegasus, __u16 indx, __u16 size,
> 			 void *data)
> {
> 	int ret;
> @@ -196,7 +196,7 @@ out:
> 	return ret;
> }
>
> -static int set_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
> +static int set_registers(pegasus_t *pegasus, __u16 indx, __u16 size,
> 			 void *data)
> {
> 	int ret;
> @@ -248,7 +248,7 @@ out:
> 	return ret;
> }
>
> -static int set_register(pegasus_t * pegasus, __u16 indx, __u8 data)
> +static int set_register(pegasus_t *pegasus, __u16 indx, __u8 data)
> {
> 	int ret;
> 	char *tmp;
> @@ -299,7 +299,7 @@ out:
> 	return ret;
> }
>
> -static int update_eth_regs_async(pegasus_t * pegasus)
> +static int update_eth_regs_async(pegasus_t *pegasus)
> {
> 	int ret;
>
> @@ -326,7 +326,7 @@ static int update_eth_regs_async(pegasus_t * pegasus)
> }
>
> /* Returns 0 on success, error on failure */
> -static int read_mii_word(pegasus_t * pegasus, __u8 phy, __u8 indx, __u16 * regd)
> +static int read_mii_word(pegasus_t *pegasus, __u8 phy, __u8 indx, __u16 *regd)
> {
> 	int i;
> 	__u8 data[4] = { phy, 0, 0, indx };
> @@ -334,7 +334,7 @@ static int read_mii_word(pegasus_t * pegasus, __u8 phy, __u8 indx, __u16 * regd)
> 	int ret;
>
> 	set_register(pegasus, PhyCtrl, 0);
> -	set_registers(pegasus, PhyAddr, sizeof (data), data);
> +	set_registers(pegasus, PhyAddr, sizeof(data), data);
> 	set_register(pegasus, PhyCtrl, (indx | PHY_READ));
> 	for (i = 0; i < REG_TIMEOUT; i++) {
> 		ret = get_registers(pegasus, PhyCtrl, 1, data);
> @@ -366,7 +366,7 @@ static int mdio_read(struct net_device *dev, int phy_id, int loc)
> 	return (int)res;
> }
>
> -static int write_mii_word(pegasus_t * pegasus, __u8 phy, __u8 indx, __u16 regd)
> +static int write_mii_word(pegasus_t *pegasus, __u8 phy, __u8 indx, __u16 regd)
> {
> 	int i;
> 	__u8 data[4] = { phy, 0, 0, indx };
> @@ -402,7 +402,7 @@ static void mdio_write(struct net_device *dev, int phy_id, int loc, int val)
> 	write_mii_word(pegasus, phy_id, loc, val);
> }
>
> -static int read_eprom_word(pegasus_t * pegasus, __u8 index, __u16 * retdata)
> +static int read_eprom_word(pegasus_t *pegasus, __u8 index, __u16 *retdata)
> {
> 	int i;
> 	__u8 tmp;
> @@ -433,7 +433,7 @@ fail:
> }
>
> #ifdef	PEGASUS_WRITE_EEPROM
> -static inline void enable_eprom_write(pegasus_t * pegasus)
> +static inline void enable_eprom_write(pegasus_t *pegasus)
> {
> 	__u8 tmp;
> 	int ret;
> @@ -442,7 +442,7 @@ static inline void enable_eprom_write(pegasus_t * pegasus)
> 	set_register(pegasus, EthCtrl2, tmp | EPROM_WR_ENABLE);
> }
>
> -static inline void disable_eprom_write(pegasus_t * pegasus)
> +static inline void disable_eprom_write(pegasus_t *pegasus)
> {
> 	__u8 tmp;
> 	int ret;
> @@ -452,7 +452,7 @@ static inline void disable_eprom_write(pegasus_t * pegasus)
> 	set_register(pegasus, EthCtrl2, tmp & ~EPROM_WR_ENABLE);
> }
>
> -static int write_eprom_word(pegasus_t * pegasus, __u8 index, __u16 data)
> +static int write_eprom_word(pegasus_t *pegasus, __u8 index, __u16 data)
> {
> 	int i;
> 	__u8 tmp, d[4] = { 0x3f, 0, 0, EPROM_WRITE };
> @@ -484,7 +484,7 @@ fail:
> }
> #endif				/* PEGASUS_WRITE_EEPROM */
>
> -static inline void get_node_id(pegasus_t * pegasus, __u8 * id)
> +static inline void get_node_id(pegasus_t *pegasus, __u8 *id)
> {
> 	int i;
> 	__u16 w16;
> @@ -495,7 +495,7 @@ static inline void get_node_id(pegasus_t * pegasus, __u8 * id)
> 	}
> }
>
> -static void set_ethernet_addr(pegasus_t * pegasus)
> +static void set_ethernet_addr(pegasus_t *pegasus)
> {
> 	__u8 node_id[6];
>
> @@ -503,12 +503,12 @@ static void set_ethernet_addr(pegasus_t * pegasus)
> 		get_registers(pegasus, 0x10, sizeof(node_id), node_id);
> 	} else {
> 		get_node_id(pegasus, node_id);
> -		set_registers(pegasus, EthID, sizeof (node_id), node_id);
> +		set_registers(pegasus, EthID, sizeof(node_id), node_id);
> 	}
> -	memcpy(pegasus->net->dev_addr, node_id, sizeof (node_id));
> +	memcpy(pegasus->net->dev_addr, node_id, sizeof(node_id));
> }
>
> -static inline int reset_mac(pegasus_t * pegasus)
> +static inline int reset_mac(pegasus_t *pegasus)
> {
> 	__u8 data = 0x8;
> 	int i;
> @@ -563,7 +563,7 @@ static int enable_net_traffic(struct net_device *dev, struct usb_device *usb)
> 		data[1] = 0;
> 	data[2] = (loopback & 1) ? 0x09 : 0x01;
>
> -	memcpy(pegasus->eth_regs, data, sizeof (data));
> +	memcpy(pegasus->eth_regs, data, sizeof(data));
> 	ret = set_registers(pegasus, EthCtrl0, 3, data);
>
> 	if (usb_dev_id[pegasus->dev_index].vendor == VENDOR_LINKSYS ||
> @@ -577,7 +577,7 @@ static int enable_net_traffic(struct net_device *dev, struct usb_device *usb)
> 	return ret;
> }
>
> -static void fill_skb_pool(pegasus_t * pegasus)
> +static void fill_skb_pool(pegasus_t *pegasus)
> {
> 	int i;
>
> @@ -595,7 +595,7 @@ static void fill_skb_pool(pegasus_t * pegasus)
> 	}
> }
>
> -static void free_skb_pool(pegasus_t * pegasus)
> +static void free_skb_pool(pegasus_t *pegasus)
> {
> 	int i;
>
> @@ -667,11 +667,11 @@ static void read_bulk_callback(struct urb *urb)
> 		netif_dbg(pegasus, rx_err, net,
> 			  "RX packet error %x\n", rx_status);
> 		pegasus->stats.rx_errors++;
> -		if (rx_status & 0x06)	// long or runt
> +		if (rx_status & 0x06)	/* long or runt	*/
> 			pegasus->stats.rx_length_errors++;
> 		if (rx_status & 0x08)
> 			pegasus->stats.rx_crc_errors++;
> -		if (rx_status & 0x10)	// extra bits
> +		if (rx_status & 0x10)	/* extra bits	*/
> 			pegasus->stats.rx_frame_errors++;
> 		goto goon;
> 	}
> @@ -748,9 +748,8 @@ static void rx_fixup(unsigned long data)
> 	if (pegasus->flags & PEGASUS_RX_URB_FAIL)
> 		if (pegasus->rx_skb)
> 			goto try_again;
> -	if (pegasus->rx_skb == NULL) {
> +	if (pegasus->rx_skb == NULL)
> 		pegasus->rx_skb = pull_skb(pegasus);
> -	}
> 	if (pegasus->rx_skb == NULL) {
> 		netif_warn(pegasus, rx_err, pegasus->net, "low on memory\n");
> 		tasklet_schedule(&pegasus->rx_tl);
> @@ -835,7 +834,7 @@ static void intr_callback(struct urb *urb)
> 	}
>
> 	if (urb->actual_length >= 6) {
> -		u8	* d = urb->transfer_buffer;
> +		u8 *d = urb->transfer_buffer;
>
> 		/* byte 0 == tx_status1, reg 2B */
> 		if (d[0] & (TX_UNDERRUN|EXCESSIVE_COL
> @@ -918,14 +917,14 @@ static struct net_device_stats *pegasus_netdev_stats(struct net_device *dev)
> 	return &((pegasus_t *) netdev_priv(dev))->stats;
> }
>
> -static inline void disable_net_traffic(pegasus_t * pegasus)
> +static inline void disable_net_traffic(pegasus_t *pegasus)
> {
> 	__le16 tmp = cpu_to_le16(0);
>
> 	set_registers(pegasus, EthCtrl0, sizeof(tmp), &tmp);
> }
>
> -static inline void get_interrupt_interval(pegasus_t * pegasus)
> +static inline void get_interrupt_interval(pegasus_t *pegasus)
> {
> 	u16 data;
> 	u8 interval;
> @@ -961,7 +960,7 @@ static void set_carrier(struct net_device *net)
> 		netif_carrier_off(net);
> }
>
> -static void free_all_urbs(pegasus_t * pegasus)
> +static void free_all_urbs(pegasus_t *pegasus)
> {
> 	usb_free_urb(pegasus->intr_urb);
> 	usb_free_urb(pegasus->tx_urb);
> @@ -969,7 +968,7 @@ static void free_all_urbs(pegasus_t * pegasus)
> 	usb_free_urb(pegasus->ctrl_urb);
> }
>
> -static void unlink_all_urbs(pegasus_t * pegasus)
> +static void unlink_all_urbs(pegasus_t *pegasus)
> {
> 	usb_kill_urb(pegasus->intr_urb);
> 	usb_kill_urb(pegasus->tx_urb);
> @@ -977,12 +976,11 @@ static void unlink_all_urbs(pegasus_t * pegasus)
> 	usb_kill_urb(pegasus->ctrl_urb);
> }
>
> -static int alloc_urbs(pegasus_t * pegasus)
> +static int alloc_urbs(pegasus_t *pegasus)
> {
> 	pegasus->ctrl_urb = usb_alloc_urb(0, GFP_KERNEL);
> -	if (!pegasus->ctrl_urb) {
> +	if (!pegasus->ctrl_urb)
> 		return 0;
> -	}
> 	pegasus->rx_urb = usb_alloc_urb(0, GFP_KERNEL);
> 	if (!pegasus->rx_urb) {
> 		usb_free_urb(pegasus->ctrl_urb);
> @@ -1019,7 +1017,7 @@ static int pegasus_open(struct net_device *net)
> 		return -ENOMEM;
>
> 	res = set_registers(pegasus, EthID, 6, net->dev_addr);
> -
> +
> 	usb_fill_bulk_urb(pegasus->rx_urb, pegasus->usb,
> 			  usb_rcvbulkpipe(pegasus->usb, 1),
> 			  pegasus->rx_skb->data, PEGASUS_MTU + 8,
> @@ -1033,7 +1031,7 @@ static int pegasus_open(struct net_device *net)
>
> 	usb_fill_int_urb(pegasus->intr_urb, pegasus->usb,
> 			 usb_rcvintpipe(pegasus->usb, 3),
> -			 pegasus->intr_buff, sizeof (pegasus->intr_buff),
> +			 pegasus->intr_buff, sizeof(pegasus->intr_buff),
> 			 intr_callback, pegasus, pegasus->intr_interval);
> 	if ((res = usb_submit_urb(pegasus->intr_urb, GFP_KERNEL))) {
> 		if (res == -ENODEV)
> @@ -1076,9 +1074,9 @@ static void pegasus_get_drvinfo(struct net_device *dev,
> 				struct ethtool_drvinfo *info)
> {
> 	pegasus_t *pegasus = netdev_priv(dev);
> -	strncpy(info->driver, driver_name, sizeof (info->driver) - 1);
> -	strncpy(info->version, DRIVER_VERSION, sizeof (info->version) - 1);
> -	usb_make_path(pegasus->usb, info->bus_info, sizeof (info->bus_info));
> +	strncpy(info->driver, driver_name, sizeof(info->driver) - 1);
> +	strncpy(info->version, DRIVER_VERSION, sizeof(info->version) - 1);
> +	usb_make_path(pegasus->usb, info->bus_info, sizeof(info->bus_info));
> }
>
> /* also handles three patterns of some kind in hardware */
> @@ -1098,7 +1096,7 @@ pegasus_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
> {
> 	pegasus_t	*pegasus = netdev_priv(dev);
> 	u8		reg78 = 0x04;
> -
> +
> 	if (wol->wolopts & ~WOL_SUPPORTED)
> 		return -EINVAL;
>
> @@ -1118,7 +1116,7 @@ pegasus_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
> static inline void pegasus_reset_wol(struct net_device *dev)
> {
> 	struct ethtool_wolinfo wol;
> -
> +
> 	memset(&wol, 0, sizeof wol);
> 	(void) pegasus_set_wol(dev, &wol);
> }
> @@ -1178,7 +1176,7 @@ static const struct ethtool_ops ops = {
>
> static int pegasus_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
> {
> -	__u16 *data = (__u16 *) & rq->ifr_ifru;
> +	__u16 *data = (__u16 *) &rq->ifr_ifru;
> 	pegasus_t *pegasus = netdev_priv(net);
> 	int res;
>
> @@ -1223,7 +1221,7 @@ static void pegasus_set_multicast(struct net_device *net)
> 	ctrl_callback(pegasus->ctrl_urb);
> }
>
> -static __u8 mii_phy_probe(pegasus_t * pegasus)
> +static __u8 mii_phy_probe(pegasus_t *pegasus)
> {
> 	int i;
> 	__u16 tmp;
> @@ -1239,10 +1237,10 @@ static __u8 mii_phy_probe(pegasus_t * pegasus)
> 	return 0xff;
> }
>
> -static inline void setup_pegasus_II(pegasus_t * pegasus)
> +static inline void setup_pegasus_II(pegasus_t *pegasus)
> {
> 	__u8 data = 0xa5;
> -
> +
> 	set_register(pegasus, Reg1d, 0);
> 	set_register(pegasus, Reg7b, 1);
> 	mdelay(100);
> @@ -1254,16 +1252,15 @@ static inline void setup_pegasus_II(pegasus_t * pegasus)
> 	set_register(pegasus, 0x83, data);
> 	get_registers(pegasus, 0x83, 1, &data);
>
> -	if (data == 0xa5) {
> +	if (data == 0xa5)
> 		pegasus->chip = 0x8513;
> -	} else {
> +	else
> 		pegasus->chip = 0;
> -	}
>
> 	set_register(pegasus, 0x80, 0xc0);
> 	set_register(pegasus, 0x83, 0xff);
> 	set_register(pegasus, 0x84, 0x01);
> -
> +
> 	if (pegasus->features & HAS_HOME_PNA && mii_mode)
> 		set_register(pegasus, Reg81, 6);
> 	else
> @@ -1272,7 +1269,7 @@ static inline void setup_pegasus_II(pegasus_t * pegasus)
>
>
> static int pegasus_count;
> -static struct workqueue_struct *pegasus_workqueue = NULL;
> +static struct workqueue_struct *pegasus_workqueue;
> #define CARRIER_CHECK_DELAY (2 * HZ)
>
> static void check_carrier(struct work_struct *work)
> @@ -1367,7 +1364,7 @@ static int pegasus_probe(struct usb_interface *intf,
> 	pegasus->mii.phy_id_mask = 0x1f;
> 	pegasus->mii.reg_num_mask = 0x1f;
> 	spin_lock_init(&pegasus->rx_pool_lock);
> -	pegasus->msg_enable = netif_msg_init (msg_level, NETIF_MSG_DRV
> +	pegasus->msg_enable = netif_msg_init(msg_level, NETIF_MSG_DRV
> 				| NETIF_MSG_PROBE | NETIF_MSG_LINK);
>
> 	pegasus->features = usb_dev_id[dev_index].private;
> @@ -1442,11 +1439,11 @@ static void pegasus_disconnect(struct usb_interface *intf)
> 	pegasus_dec_workqueue();
> }
>
> -static int pegasus_suspend (struct usb_interface *intf, pm_message_t message)
> +static int pegasus_suspend(struct usb_interface *intf, pm_message_t message)
> {
> 	struct pegasus *pegasus = usb_get_intfdata(intf);
> -
> -	netif_device_detach (pegasus->net);
> +
> +	netif_device_detach(pegasus->net);
> 	cancel_delayed_work(&pegasus->carrier_check);
> 	if (netif_running(pegasus->net)) {
> 		usb_kill_urb(pegasus->rx_urb);
> @@ -1455,11 +1452,11 @@ static int pegasus_suspend (struct usb_interface *intf, pm_message_t message)
> 	return 0;
> }
>
> -static int pegasus_resume (struct usb_interface *intf)
> +static int pegasus_resume(struct usb_interface *intf)
> {
> 	struct pegasus *pegasus = usb_get_intfdata(intf);
>
> -	netif_device_attach (pegasus->net);
> +	netif_device_attach(pegasus->net);
> 	if (netif_running(pegasus->net)) {
> 		pegasus->rx_urb->status = 0;
> 		pegasus->rx_urb->actual_length = 0;
> @@ -1498,8 +1495,8 @@ static struct usb_driver pegasus_driver = {
>
> static void __init parse_id(char *id)
> {
> -	unsigned int vendor_id=0, device_id=0, flags=0, i=0;
> -	char *token, *name=NULL;
> +	unsigned int vendor_id = 0, device_id = 0, flags = 0, i = 0;
> +	char *token, *name = NULL;
>
> 	if ((token = strsep(&id, ":")) != NULL)
> 		name = token;
> @@ -1510,14 +1507,14 @@ static void __init parse_id(char *id)
> 		device_id = simple_strtoul(token, NULL, 16);
> 	flags = simple_strtoul(id, NULL, 16);
> 	pr_info("%s: new device %s, vendor ID 0x%04x, device ID 0x%04x, flags: 0x%x\n",
> -	        driver_name, name, vendor_id, device_id, flags);
> +		driver_name, name, vendor_id, device_id, flags);
>
> 	if (vendor_id > 0x10000 || vendor_id == 0)
> 		return;
> 	if (device_id > 0x10000 || device_id == 0)
> 		return;
>
> -	for (i=0; usb_dev_id[i].name; i++);
> +	for (i = 0; usb_dev_id[i].name; i++);
> 	usb_dev_id[i].name = name;
> 	usb_dev_id[i].vendor = vendor_id;
> 	usb_dev_id[i].device = device_id;
> diff --git a/drivers/net/usb/pegasus.h b/drivers/net/usb/pegasus.h
> index 29f5211..65b78b3 100644
> --- a/drivers/net/usb/pegasus.h
> +++ b/drivers/net/usb/pegasus.h
> @@ -68,7 +68,7 @@ enum pegasus_registers {
> 	EpromData = 0x21,	/* 0x21 low, 0x22 high byte */
> 	EpromCtrl = 0x23,
> 	PhyAddr = 0x25,
> -	PhyData = 0x26, 	/* 0x26 low, 0x27 high byte */
> +	PhyData = 0x26,		/* 0x26 low, 0x27 high byte */
> 	PhyCtrl = 0x28,
> 	UsbStst = 0x2a,
> 	EthTxStat0 = 0x2b,
> @@ -154,162 +154,162 @@ struct usb_eth_dev {
>
> #else	/* PEGASUS_DEV */
>
> -PEGASUS_DEV( "3Com USB Ethernet 3C460B", VENDOR_3COM, 0x4601,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "ATEN USB Ethernet UC-110T", VENDOR_ATEN, 0x2007,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "USB HPNA/Ethernet", VENDOR_ABOCOM, 0x110c,
> -		DEFAULT_GPIO_RESET | PEGASUS_II | HAS_HOME_PNA )
> -PEGASUS_DEV( "USB HPNA/Ethernet", VENDOR_ABOCOM, 0x4104,
> -		DEFAULT_GPIO_RESET | HAS_HOME_PNA )
> -PEGASUS_DEV( "USB HPNA/Ethernet", VENDOR_ABOCOM, 0x4004,
> -		DEFAULT_GPIO_RESET | HAS_HOME_PNA )
> -PEGASUS_DEV( "USB HPNA/Ethernet", VENDOR_ABOCOM, 0x4007,
> -		DEFAULT_GPIO_RESET | HAS_HOME_PNA )
> -PEGASUS_DEV( "USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0x4102,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0x4002,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0x400b,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0x400c,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0xabc1,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0x200c,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "Accton USB 10/100 Ethernet Adapter", VENDOR_ACCTON, 0x1046,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "SpeedStream USB 10/100 Ethernet", VENDOR_ACCTON, 0x5046,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "Philips USB 10/100 Ethernet", VENDOR_ACCTON, 0xb004,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "ADMtek ADM8511 \"Pegasus II\" USB Ethernet",
> +PEGASUS_DEV("3Com USB Ethernet 3C460B", VENDOR_3COM, 0x4601,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("ATEN USB Ethernet UC-110T", VENDOR_ATEN, 0x2007,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("USB HPNA/Ethernet", VENDOR_ABOCOM, 0x110c,
> +		DEFAULT_GPIO_RESET | PEGASUS_II | HAS_HOME_PNA)
> +PEGASUS_DEV("USB HPNA/Ethernet", VENDOR_ABOCOM, 0x4104,
> +		DEFAULT_GPIO_RESET | HAS_HOME_PNA)
> +PEGASUS_DEV("USB HPNA/Ethernet", VENDOR_ABOCOM, 0x4004,
> +		DEFAULT_GPIO_RESET | HAS_HOME_PNA)
> +PEGASUS_DEV("USB HPNA/Ethernet", VENDOR_ABOCOM, 0x4007,
> +		DEFAULT_GPIO_RESET | HAS_HOME_PNA)
> +PEGASUS_DEV("USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0x4102,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0x4002,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0x400b,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0x400c,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0xabc1,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("USB 10/100 Fast Ethernet", VENDOR_ABOCOM, 0x200c,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Accton USB 10/100 Ethernet Adapter", VENDOR_ACCTON, 0x1046,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("SpeedStream USB 10/100 Ethernet", VENDOR_ACCTON, 0x5046,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Philips USB 10/100 Ethernet", VENDOR_ACCTON, 0xb004,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("ADMtek ADM8511 \"Pegasus II\" USB Ethernet",
> 		VENDOR_ADMTEK, 0x8511,
> -		DEFAULT_GPIO_RESET | PEGASUS_II | HAS_HOME_PNA )
> -PEGASUS_DEV( "ADMtek ADM8513 \"Pegasus II\" USB Ethernet",
> +		DEFAULT_GPIO_RESET | PEGASUS_II | HAS_HOME_PNA)
> +PEGASUS_DEV("ADMtek ADM8513 \"Pegasus II\" USB Ethernet",
> 		VENDOR_ADMTEK, 0x8513,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "ADMtek ADM8515 \"Pegasus II\" USB-2.0 Ethernet",
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("ADMtek ADM8515 \"Pegasus II\" USB-2.0 Ethernet",
> 		VENDOR_ADMTEK, 0x8515,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "ADMtek AN986 \"Pegasus\" USB Ethernet (evaluation board)",
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("ADMtek AN986 \"Pegasus\" USB Ethernet (evaluation board)",
> 		VENDOR_ADMTEK, 0x0986,
> -		DEFAULT_GPIO_RESET | HAS_HOME_PNA )
> -PEGASUS_DEV( "AN986A USB MAC", VENDOR_ADMTEK, 1986,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "AEI USB Fast Ethernet Adapter", VENDOR_AEILAB, 0x1701,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "Allied Telesyn Int. AT-USB100", VENDOR_ALLIEDTEL, 0xb100,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> +		DEFAULT_GPIO_RESET | HAS_HOME_PNA)
> +PEGASUS_DEV("AN986A USB MAC", VENDOR_ADMTEK, 1986,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("AEI USB Fast Ethernet Adapter", VENDOR_AEILAB, 0x1701,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Allied Telesyn Int. AT-USB100", VENDOR_ALLIEDTEL, 0xb100,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> /*
>  * Distinguish between this Belkin adaptor and the Belkin bluetooth adaptors
>  * with the same product IDs by checking the device class too.
>  */
> -PEGASUS_DEV_CLASS( "Belkin F5D5050 USB Ethernet", VENDOR_BELKIN, 0x0121, 0x00,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "Belkin F5U122 10/100 USB Ethernet", VENDOR_BELKIN, 0x0122,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "Billionton USB-100", VENDOR_BILLIONTON, 0x0986,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "Billionton USBLP-100", VENDOR_BILLIONTON, 0x0987,
> -		DEFAULT_GPIO_RESET | HAS_HOME_PNA )
> -PEGASUS_DEV( "iPAQ Networking 10/100 USB", VENDOR_COMPAQ, 0x8511,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "Billionton USBEL-100", VENDOR_BILLIONTON, 0x0988,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "Billionton USBE-100", VENDOR_BILLIONTON, 0x8511,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "Corega FEther USB-TX", VENDOR_COREGA, 0x0004,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "Corega FEther USB-TXS", VENDOR_COREGA, 0x000d,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "D-Link DSB-650TX", VENDOR_DLINK, 0x4001,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "D-Link DSB-650TX", VENDOR_DLINK, 0x4002,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "D-Link DSB-650TX", VENDOR_DLINK, 0x4102,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "D-Link DSB-650TX", VENDOR_DLINK, 0x400b,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "D-Link DSB-650TX", VENDOR_DLINK, 0x200c,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "D-Link DSB-650TX(PNA)", VENDOR_DLINK, 0x4003,
> -		DEFAULT_GPIO_RESET | HAS_HOME_PNA )
> -PEGASUS_DEV( "D-Link DSB-650", VENDOR_DLINK, 0xabc1,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "GOLDPFEIL USB Adapter", VENDOR_ELCON, 0x0002,
> -		DEFAULT_GPIO_RESET | PEGASUS_II | HAS_HOME_PNA )
> -PEGASUS_DEV( "ELECOM USB Ethernet LD-USB20", VENDOR_ELECOM,  0x4010,
> -		DEFAULT_GPIO_RESET  | PEGASUS_II )
> -PEGASUS_DEV( "EasiDock Ethernet", VENDOR_MOBILITY, 0x0304,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "Elsa Micolink USB2Ethernet", VENDOR_ELSA, 0x3000,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "GIGABYTE GN-BR402W Wireless Router", VENDOR_GIGABYTE, 0x8002,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "Hawking UF100 10/100 Ethernet", VENDOR_HAWKING, 0x400c,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "HP hn210c Ethernet USB", VENDOR_HP, 0x811c,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "IO DATA USB ET/TX", VENDOR_IODATA, 0x0904,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "IO DATA USB ET/TX-S", VENDOR_IODATA, 0x0913,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "IO DATA USB ETX-US2", VENDOR_IODATA, 0x093a,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "Kingston KNU101TX Ethernet", VENDOR_KINGSTON, 0x000a,
> +PEGASUS_DEV_CLASS("Belkin F5D5050 USB Ethernet", VENDOR_BELKIN, 0x0121, 0x00,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Belkin F5U122 10/100 USB Ethernet", VENDOR_BELKIN, 0x0122,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Billionton USB-100", VENDOR_BILLIONTON, 0x0986,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("Billionton USBLP-100", VENDOR_BILLIONTON, 0x0987,
> +		DEFAULT_GPIO_RESET | HAS_HOME_PNA)
> +PEGASUS_DEV("iPAQ Networking 10/100 USB", VENDOR_COMPAQ, 0x8511,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Billionton USBEL-100", VENDOR_BILLIONTON, 0x0988,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("Billionton USBE-100", VENDOR_BILLIONTON, 0x8511,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Corega FEther USB-TX", VENDOR_COREGA, 0x0004,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("Corega FEther USB-TXS", VENDOR_COREGA, 0x000d,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("D-Link DSB-650TX", VENDOR_DLINK, 0x4001,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("D-Link DSB-650TX", VENDOR_DLINK, 0x4002,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("D-Link DSB-650TX", VENDOR_DLINK, 0x4102,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("D-Link DSB-650TX", VENDOR_DLINK, 0x400b,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("D-Link DSB-650TX", VENDOR_DLINK, 0x200c,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("D-Link DSB-650TX(PNA)", VENDOR_DLINK, 0x4003,
> +		DEFAULT_GPIO_RESET | HAS_HOME_PNA)
> +PEGASUS_DEV("D-Link DSB-650", VENDOR_DLINK, 0xabc1,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("GOLDPFEIL USB Adapter", VENDOR_ELCON, 0x0002,
> +		DEFAULT_GPIO_RESET | PEGASUS_II | HAS_HOME_PNA)
> +PEGASUS_DEV("ELECOM USB Ethernet LD-USB20", VENDOR_ELECOM,  0x4010,
> +		DEFAULT_GPIO_RESET  | PEGASUS_II)
> +PEGASUS_DEV("EasiDock Ethernet", VENDOR_MOBILITY, 0x0304,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("Elsa Micolink USB2Ethernet", VENDOR_ELSA, 0x3000,
> 		DEFAULT_GPIO_RESET)
> -PEGASUS_DEV( "LANEED USB Ethernet LD-USB/TX", VENDOR_LANEED, 0x4002,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "LANEED USB Ethernet LD-USBL/TX", VENDOR_LANEED, 0x4005,
> -		DEFAULT_GPIO_RESET | PEGASUS_II)
> -PEGASUS_DEV( "LANEED USB Ethernet LD-USB/TX", VENDOR_LANEED, 0x400b,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "LANEED USB Ethernet LD-USB/T", VENDOR_LANEED, 0xabc1,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "LANEED USB Ethernet LD-USB/TX", VENDOR_LANEED, 0x200c,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "Linksys USB10TX", VENDOR_LINKSYS, 0x2202,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "Linksys USB100TX", VENDOR_LINKSYS, 0x2203,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "Linksys USB100TX", VENDOR_LINKSYS, 0x2204,
> -		DEFAULT_GPIO_RESET | HAS_HOME_PNA )
> -PEGASUS_DEV( "Linksys USB10T Ethernet Adapter", VENDOR_LINKSYS, 0x2206,
> -		DEFAULT_GPIO_RESET | PEGASUS_II)
> -PEGASUS_DEV( "Linksys USBVPN1", VENDOR_LINKSYS2, 0x08b4,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "Linksys USB USB100TX", VENDOR_LINKSYS, 0x400b,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "Linksys USB10TX", VENDOR_LINKSYS, 0x200c,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "MELCO/BUFFALO LUA-TX", VENDOR_MELCO, 0x0001,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "MELCO/BUFFALO LUA-TX", VENDOR_MELCO, 0x0005,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "MELCO/BUFFALO LUA2-TX", VENDOR_MELCO, 0x0009,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "Microsoft MN-110", VENDOR_MICROSOFT, 0x007a,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "NETGEAR FA101", VENDOR_NETGEAR, 0x1020,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "OCT Inc.", VENDOR_OCT, 0x0109,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "OCT USB TO Ethernet", VENDOR_OCT, 0x0901,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "smartNIC 2 PnP Adapter", VENDOR_SMARTBRIDGES, 0x0003,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "SMC 202 USB Ethernet", VENDOR_SMC, 0x0200,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "SMC 2206 USB Ethernet", VENDOR_SMC, 0x0201,
> -		DEFAULT_GPIO_RESET | PEGASUS_II)
> -PEGASUS_DEV( "SOHOware NUB100 Ethernet", VENDOR_SOHOWARE, 0x9100,
> -		DEFAULT_GPIO_RESET )
> -PEGASUS_DEV( "SOHOware NUB110 Ethernet", VENDOR_SOHOWARE, 0x9110,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> -PEGASUS_DEV( "SpeedStream USB 10/100 Ethernet", VENDOR_SIEMENS, 0x1001,
> -		DEFAULT_GPIO_RESET | PEGASUS_II )
> +PEGASUS_DEV("GIGABYTE GN-BR402W Wireless Router", VENDOR_GIGABYTE, 0x8002,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("Hawking UF100 10/100 Ethernet", VENDOR_HAWKING, 0x400c,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("HP hn210c Ethernet USB", VENDOR_HP, 0x811c,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("IO DATA USB ET/TX", VENDOR_IODATA, 0x0904,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("IO DATA USB ET/TX-S", VENDOR_IODATA, 0x0913,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("IO DATA USB ETX-US2", VENDOR_IODATA, 0x093a,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Kingston KNU101TX Ethernet", VENDOR_KINGSTON, 0x000a,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("LANEED USB Ethernet LD-USB/TX", VENDOR_LANEED, 0x4002,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("LANEED USB Ethernet LD-USBL/TX", VENDOR_LANEED, 0x4005,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("LANEED USB Ethernet LD-USB/TX", VENDOR_LANEED, 0x400b,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("LANEED USB Ethernet LD-USB/T", VENDOR_LANEED, 0xabc1,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("LANEED USB Ethernet LD-USB/TX", VENDOR_LANEED, 0x200c,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Linksys USB10TX", VENDOR_LINKSYS, 0x2202,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("Linksys USB100TX", VENDOR_LINKSYS, 0x2203,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("Linksys USB100TX", VENDOR_LINKSYS, 0x2204,
> +		DEFAULT_GPIO_RESET | HAS_HOME_PNA)
> +PEGASUS_DEV("Linksys USB10T Ethernet Adapter", VENDOR_LINKSYS, 0x2206,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Linksys USBVPN1", VENDOR_LINKSYS2, 0x08b4,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("Linksys USB USB100TX", VENDOR_LINKSYS, 0x400b,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Linksys USB10TX", VENDOR_LINKSYS, 0x200c,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("MELCO/BUFFALO LUA-TX", VENDOR_MELCO, 0x0001,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("MELCO/BUFFALO LUA-TX", VENDOR_MELCO, 0x0005,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("MELCO/BUFFALO LUA2-TX", VENDOR_MELCO, 0x0009,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("Microsoft MN-110", VENDOR_MICROSOFT, 0x007a,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("NETGEAR FA101", VENDOR_NETGEAR, 0x1020,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("OCT Inc.", VENDOR_OCT, 0x0109,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("OCT USB TO Ethernet", VENDOR_OCT, 0x0901,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("smartNIC 2 PnP Adapter", VENDOR_SMARTBRIDGES, 0x0003,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("SMC 202 USB Ethernet", VENDOR_SMC, 0x0200,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("SMC 2206 USB Ethernet", VENDOR_SMC, 0x0201,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("SOHOware NUB100 Ethernet", VENDOR_SOHOWARE, 0x9100,
> +		DEFAULT_GPIO_RESET)
> +PEGASUS_DEV("SOHOware NUB110 Ethernet", VENDOR_SOHOWARE, 0x9110,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
> +PEGASUS_DEV("SpeedStream USB 10/100 Ethernet", VENDOR_SIEMENS, 0x1001,
> +		DEFAULT_GPIO_RESET | PEGASUS_II)
>
>
> #endif	/* PEGASUS_DEV */
> -- 
> 1.7.1
>
