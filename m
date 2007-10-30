From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH][RFC] Add support for the RDC R6040 Fast Ethernet controller
Date: Tue, 30 Oct 2007 10:29:27 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0710301024400.4673@kivilampi-30.cs.helsinki.fi>
References: <200710292251.43257.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46273 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156AbXJ3I33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 04:29:29 -0400
In-Reply-To: <200710292251.43257.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Oct 2007, Florian Fainelli wrote:

> +static int  mdio_read(struct net_device *dev, int phy_id, int location);
> +static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
> +static int r6040_open(struct net_device *dev);
> +static int r6040_start_xmit(struct sk_buff *skb, struct net_device *dev);
> +static irqreturn_t r6040_interrupt(int irq, void *dev_id);
> +static int r6040_close(struct net_device *dev);
> +static void set_multicast_list(struct net_device *dev);
> +static struct ethtool_ops netdev_ethtool_ops;
> +static int r6040_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
> +static void r6040_down(struct net_device *dev);
> +static void r6040_up(struct net_device *dev);
> +static void r6040_tx_timeout(struct net_device *dev);
> +static void r6040_timer(unsigned long);
> +static void r6040_mac_address(struct net_device *dev);
> +
> +static int phy_mode_chk(struct net_device *dev);
> +static int phy_read(int ioaddr, int phy_adr, int reg_idx);
> +static void phy_write(int ioaddr, int phy_adr, int reg_idx, int dat);
> +static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev);
> +#ifdef CONFIG_R6040_NAPI
> +static int r6040_poll(struct napi_struct *napi, int budget);
> +#endif
> +

...Most of those forward declarations can go if the functions are ordered 
properly. One can trivially notice that the mdio_{read,write} are 
unnecessary already:

> +static int mdio_read(struct net_device *dev, int phy_id, int regnum)
> +{
> +	struct r6040_private *lp = netdev_priv(dev);
> +	long ioaddr = dev->base_addr;
> +	return  (phy_read(ioaddr, lp->phy_addr, regnum)) ;
> +}
> +
> +static void mdio_write(struct net_device *dev, int phy_id, int regnum, int value)
> +{
> +	struct r6040_private *lp = netdev_priv(dev);
> +	long ioaddr = dev->base_addr;
> +
> +	phy_write(ioaddr, lp->phy_addr, regnum, value);
> +}


-- 
 i.
