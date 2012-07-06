From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/4] asix: Add a new driver for the AX88172A
Date: Fri, 6 Jul 2012 18:37:35 +0100
Message-ID: <1341596255.2923.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	 <1341574388-7464-5-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53591 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757562Ab2GFRhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 13:37:40 -0400
In-Reply-To: <1341574388-7464-5-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 13:33 +0200, Christian Riesch wrote:
> The Asix AX88172A is a USB 2.0 Ethernet interface that supports both an
> internal PHY as well as an external PHY (connected via MII).
> 
> This patch adds a driver for the AX88172A and provides support for
> both modes and supports phylib.
[...]
> +static int ax88172a_init_mdio(struct usbnet *dev)
> +{
> +	struct ax88172a_private *priv =
> +		(struct ax88172a_private *)dev->driver_priv;
> +	int ret, i;
> +
> +	priv->mdio = mdiobus_alloc();
> +	if (!priv->mdio) {
> +		dbg("Could not allocate MDIO bus");
> +		return -1;
> +	}
> +
> +	priv->mdio->priv = (void *)dev;
> +	priv->mdio->read = &asix_mdio_bus_read;
> +	priv->mdio->write = &asix_mdio_bus_write;
> +	priv->mdio->name = "Asix MDIO Bus";
> +	snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "asix-%s",
> +		 dev_name(dev->net->dev.parent));
[...]

I think you need to ensure that the bus identifier is unique throughout
its lifetime, but net devices can be renamed and that could lead to a
collision.  Perhaps you could use the ifindex or the USB device path
(though that might be too long).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
