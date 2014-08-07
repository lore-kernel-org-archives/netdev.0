From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] rtl8150: Prefix macros with RTL8150 to avoid collides
Date: Thu, 7 Aug 2014 12:57:00 +0300
Message-ID: <20140807095700.GC4839@bender.nucleusys.com>
References: <1407391461-1833-1-git-send-email-xerofoiify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open list:USB RTL8150 DRIVER" <linux-usb@vger.kernel.org>,
	"open list:USB RTL8150 DRIVER" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>, davem@davemloft.net
To: Nick Krause <xerofoiify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407391461-1833-1-git-send-email-xerofoiify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ACK


On 14-08-07 08:04:21, Nick Krause wrote:
> Avoid collides in global namespaces by prefixing macros with RTL8150 as
> suggested by David Miller. Collides as follows:
> 
> drivers/net/usb/rtl8150.c:30:0: warning: "RSR" redefined
> arch/xtensa/include/asm/processor.h:189:0: note: this is the location of the previous definition
> 
> with help from kernelnewbies. Test compiled on sandybridge.
> 
> Signed-off-by: Nick Krause <xerofoify@gmail.com>
> Suggested-by: David Miller <davem@davemloft.net>
> ---
>  drivers/net/usb/rtl8150.c | 102 +++++++++++++++++++++++-----------------------
>  1 file changed, 52 insertions(+), 50 deletions(-)
> 
> diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
> index 6e87e57..1e1c408 100644
> --- a/drivers/net/usb/rtl8150.c
> +++ b/drivers/net/usb/rtl8150.c
> @@ -21,27 +21,27 @@
>  #define DRIVER_AUTHOR "Petko Manolov <petkan@users.sourceforge.net>"
>  #define DRIVER_DESC "rtl8150 based usb-ethernet driver"
>  
> -#define	IDR			0x0120
> -#define	MAR			0x0126
> -#define	CR			0x012e
> -#define	TCR			0x012f
> -#define	RCR			0x0130
> -#define	TSR			0x0132
> -#define	RSR			0x0133
> -#define	CON0			0x0135
> -#define	CON1			0x0136
> -#define	MSR			0x0137
> -#define	PHYADD			0x0138
> -#define	PHYDAT			0x0139
> -#define	PHYCNT			0x013b
> -#define	GPPC			0x013d
> -#define	BMCR			0x0140
> -#define	BMSR			0x0142
> -#define	ANAR			0x0144
> -#define	ANLP			0x0146
> -#define	AER			0x0148
> -#define CSCR			0x014C  /* This one has the link status */
> -#define CSCR_LINK_STATUS	(1 << 3)
> +#define	RTL8150_IDR			0x0120
> +#define	RTL8150_MAR			0x0126
> +#define	RTL8150_CR			0x012e
> +#define	RTL8150_TCR			0x012f
> +#define	RTL8150_RCR			0x0130
> +#define	RTL8150_TSR			0x0132
> +#define	RTL8150_RSR			0x0133
> +#define	RTL8150_CON0			0x0135
> +#define	RTL8150_CON1			0x0136
> +#define	RTL8150_MSR			0x0137
> +#define	RTL8150_PHYADD			0x0138
> +#define	RTL8150_PHYDAT			0x0139
> +#define	RTL8150_PHYCNT			0x013b
> +#define	RTL8150_GPPC			0x013d
> +#define	RTL8150_BMCR			0x0140
> +#define	RTL8150_BMSR			0x0142
> +#define	RTL8150_ANAR			0x0144
> +#define	RTL8150_ANLP			0x0146
> +#define	RTL8150_AER			0x0148
> +#define RTL8150_CSCR			0x014C  /*This one has the link status*/
> +#define RTL8150_CSCR_LINK_STATUS	(1 << 3)
>  
>  #define	IDR_EEPROM		0x1202
>  
> @@ -220,14 +220,14 @@ static int read_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 * reg)
>  	tmp = indx | PHY_READ | PHY_GO;
>  	i = 0;
>  
> -	set_registers(dev, PHYADD, sizeof(data), data);
> -	set_registers(dev, PHYCNT, 1, &tmp);
> +	set_registers(dev, RTL8150_PHYADD, sizeof(data), data);
> +	set_registers(dev, RTL8150_PHYCNT, 1, &tmp);
>  	do {
> -		get_registers(dev, PHYCNT, 1, data);
> +		get_registers(dev, RTL8150_PHYCNT, 1, data);
>  	} while ((data[0] & PHY_GO) && (i++ < MII_TIMEOUT));
>  
>  	if (i <= MII_TIMEOUT) {
> -		get_registers(dev, PHYDAT, 2, data);
> +		get_registers(dev, RTL8150_PHYDAT, 2, data);
>  		*reg = data[0] | (data[1] << 8);
>  		return 0;
>  	} else
> @@ -245,10 +245,10 @@ static int write_mii_word(rtl8150_t * dev, u8 phy, __u8 indx, u16 reg)
>  	tmp = indx | PHY_WRITE | PHY_GO;
>  	i = 0;
>  
> -	set_registers(dev, PHYADD, sizeof(data), data);
> -	set_registers(dev, PHYCNT, 1, &tmp);
> +	set_registers(dev, RTL8150_PHYADD, sizeof(data), data);
> +	set_registers(dev, RTL8150_PHYCNT, 1, &tmp);
>  	do {
> -		get_registers(dev, PHYCNT, 1, data);
> +		get_registers(dev, RTL8150_PHYCNT, 1, data);
>  	} while ((data[0] & PHY_GO) && (i++ < MII_TIMEOUT));
>  
>  	if (i <= MII_TIMEOUT)
> @@ -261,7 +261,7 @@ static inline void set_ethernet_addr(rtl8150_t * dev)
>  {
>  	u8 node_id[6];
>  
> -	get_registers(dev, IDR, sizeof(node_id), node_id);
> +	get_registers(dev, RTL8150_IDR, sizeof(node_id), node_id);
>  	memcpy(dev->netdev->dev_addr, node_id, sizeof(node_id));
>  }
>  
> @@ -275,17 +275,17 @@ static int rtl8150_set_mac_address(struct net_device *netdev, void *p)
>  
>  	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
>  	netdev_dbg(netdev, "Setting MAC address to %pM\n", netdev->dev_addr);
> -	/* Set the IDR registers. */
> -	set_registers(dev, IDR, netdev->addr_len, netdev->dev_addr);
> +	/* Set the RTL8150_IDR registers. */
> +	set_registers(dev, RTL8150_IDR, netdev->addr_len, netdev->dev_addr);
>  #ifdef EEPROM_WRITE
>  	{
>  	int i;
>  	u8 cr;
> -	/* Get the CR contents. */
> -	get_registers(dev, CR, 1, &cr);
> +	/* Get the RTL8150_CR contents. */
> +	get_registers(dev, RTL8150_CR, 1, &cr);
>  	/* Set the WEPROM bit (eeprom write enable). */
>  	cr |= 0x20;
> -	set_registers(dev, CR, 1, &cr);
> +	set_registers(dev, RTL8150_CR, 1, &cr);
>  	/* Write the MAC address into eeprom. Eeprom writes must be word-sized,
>  	   so we need to split them up. */
>  	for (i = 0; i * 2 < netdev->addr_len; i++) {
> @@ -294,7 +294,7 @@ static int rtl8150_set_mac_address(struct net_device *netdev, void *p)
>  	}
>  	/* Clear the WEPROM bit (preventing accidental eeprom writes). */
>  	cr &= 0xdf;
> -	set_registers(dev, CR, 1, &cr);
> +	set_registers(dev, RTL8150_CR, 1, &cr);
>  	}
>  #endif
>  	return 0;
> @@ -305,9 +305,9 @@ static int rtl8150_reset(rtl8150_t * dev)
>  	u8 data = 0x10;
>  	int i = HZ;
>  
> -	set_registers(dev, CR, 1, &data);
> +	set_registers(dev, RTL8150_CR, 1, &data);
>  	do {
> -		get_registers(dev, CR, 1, &data);
> +		get_registers(dev, RTL8150_CR, 1, &data);
>  	} while ((data & 0x10) && --i);
>  
>  	return (i > 0) ? 1 : 0;
> @@ -617,16 +617,18 @@ static int enable_net_traffic(rtl8150_t * dev)
>  	if (!rtl8150_reset(dev)) {
>  		dev_warn(&dev->udev->dev, "device reset failed\n");
>  	}
> -	/* RCR bit7=1 attach Rx info at the end;  =0 HW CRC (which is broken) */
> +	/* RTL8150_RCR bit7=1 attach Rx info at the end;
> +	 * =0 HW CRC (which is broken)
> +	 */
>  	rcr = 0x9e;
>  	tcr = 0xd8;
>  	cr = 0x0c;
>  	if (!(rcr & 0x80))
>  		set_bit(RTL8150_HW_CRC, &dev->flags);
> -	set_registers(dev, RCR, 1, &rcr);
> -	set_registers(dev, TCR, 1, &tcr);
> -	set_registers(dev, CR, 1, &cr);
> -	get_registers(dev, MSR, 1, &msr);
> +	set_registers(dev, RTL8150_RCR, 1, &rcr);
> +	set_registers(dev, RTL8150_TCR, 1, &tcr);
> +	set_registers(dev, RTL8150_CR, 1, &cr);
> +	get_registers(dev, RTL8150_MSR, 1, &msr);
>  
>  	return 0;
>  }
> @@ -635,9 +637,9 @@ static void disable_net_traffic(rtl8150_t * dev)
>  {
>  	u8 cr;
>  
> -	get_registers(dev, CR, 1, &cr);
> +	get_registers(dev, RTL8150_CR, 1, &cr);
>  	cr &= 0xf3;
> -	set_registers(dev, CR, 1, &cr);
> +	set_registers(dev, RTL8150_CR, 1, &cr);
>  }
>  
>  static void rtl8150_tx_timeout(struct net_device *netdev)
> @@ -666,7 +668,7 @@ static void rtl8150_set_multicast(struct net_device *netdev)
>  		/* ~RX_MULTICAST, ~RX_PROMISCUOUS */
>  		rx_creg &= 0x00fc;
>  	}
> -	async_set_registers(dev, RCR, sizeof(rx_creg), rx_creg);
> +	async_set_registers(dev, RTL8150_RCR, sizeof(rx_creg), rx_creg);
>  	netif_wake_queue(netdev);
>  }
>  
> @@ -706,8 +708,8 @@ static void set_carrier(struct net_device *netdev)
>  	rtl8150_t *dev = netdev_priv(netdev);
>  	short tmp;
>  
> -	get_registers(dev, CSCR, 2, &tmp);
> -	if (tmp & CSCR_LINK_STATUS)
> +	get_registers(dev, RTL8150_CSCR, 2, &tmp);
> +	if (tmp & RTL8150_CSCR_LINK_STATUS)
>  		netif_carrier_on(netdev);
>  	else
>  		netif_carrier_off(netdev);
> @@ -723,7 +725,7 @@ static int rtl8150_open(struct net_device *netdev)
>  	if (!dev->rx_skb)
>  		return -ENOMEM;
>  
> -	set_registers(dev, IDR, 6, netdev->dev_addr);
> +	set_registers(dev, RTL8150_IDR, 6, netdev->dev_addr);
>  
>  	usb_fill_bulk_urb(dev->rx_urb, dev->udev, usb_rcvbulkpipe(dev->udev, 1),
>  		      dev->rx_skb->data, RTL8150_MTU, read_bulk_callback, dev);
> @@ -786,8 +788,8 @@ static int rtl8150_get_settings(struct net_device *netdev, struct ethtool_cmd *e
>  	ecmd->port = PORT_TP;
>  	ecmd->transceiver = XCVR_INTERNAL;
>  	ecmd->phy_address = dev->phy;
> -	get_registers(dev, BMCR, 2, &bmcr);
> -	get_registers(dev, ANLP, 2, &lpa);
> +	get_registers(dev, RTL8150_BMCR, 2, &bmcr);
> +	get_registers(dev, RTL8150_ANLP, 2, &lpa);
>  	if (bmcr & BMCR_ANENABLE) {
>  		u32 speed = ((lpa & (LPA_100HALF | LPA_100FULL)) ?
>  			     SPEED_100 : SPEED_10);
> -- 
> 2.0.1
> 
