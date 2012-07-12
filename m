From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 3/3] asix: Add a new driver for the AX88172A
Date: Thu, 12 Jul 2012 01:44:48 -0700
Message-ID: <1342082688.1970.32.camel@joe2Laptop>
References: <1342081106-8647-1-git-send-email-christian.riesch@omicron.at>
	 <1342081106-8647-4-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Michael Riesch <michael@riesch.at>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:47995 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757087Ab2GLIot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 04:44:49 -0400
In-Reply-To: <1342081106-8647-4-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-12 at 10:18 +0200, Christian Riesch wrote:
> The Asix AX88172A is a USB 2.0 Ethernet interface that supports both an
> internal PHY as well as an external PHY (connected via MII).

Hi Christian.

I've just some trivial comments.

[]
> diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
[]
> @@ -271,12 +272,19 @@ int asix_get_phy_addr(struct usbnet *dev)
>  	}
>  	netdev_dbg(dev->net, "asix_get_phy_addr() returning 0x%04x\n",
>  		   *((__le16 *)buf));

netdev_<level> uses a terminating newline like this but
most of your new code doesn't have them.  Please add them
where appropriate.

> diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
[]
> +static void ax88172a_adjust_link(struct net_device *netdev)
> +{
> +	struct phy_device *phydev = netdev->phydev;
> +	struct usbnet *dev = netdev_priv(netdev);
> +	struct ax88172a_private *priv =
> +		(struct ax88172a_private *)dev->driver_priv;

void * doesn't need a typecast.

[]

> +	priv->mdio->irq = kzalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> +	if (!priv->mdio->irq) {
> +		netdev_err(dev->net, "Could not allocate mdio->irq");

newline please

[]

> +	ret = mdiobus_register(priv->mdio);
> +	if (ret) {
> +		netdev_err(dev->net, "Could not register MDIO bus")

newline please, I'll stop mentioning it...

> +static void ax88172a_remove_mdio(struct usbnet *dev)
> +{
> +	struct ax88172a_private *priv =
> +		(struct ax88172a_private *)dev->driver_priv;

No cast necessary, I'll stop here too...

[]

> +static int ax88172a_reset(struct usbnet *dev)
> +{
> +	struct asix_data *data = (struct asix_data *)&dev->data;
> +	struct ax88172a_private *priv =
> +		(struct ax88172a_private *)dev->driver_priv;
> +	int ret;
> +	u16 rx_ctl;
> +	netdev_dbg(dev->net, "%s called", __func__);

function tracing logging isn't really necessary because
there are other mechanisms like ftrace to do this.

[]

> +	ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
> +				AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
> +				AX88772_IPG2_DEFAULT, 0, NULL);

Most of the code is nicely aligned to open parenthesis,
but some is not.

cheers, Joe
