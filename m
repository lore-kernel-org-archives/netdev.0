From: Michael Riesch <michael@riesch.at>
Subject: Re: [PATCH 4/4] asix: Add a new driver for the AX88172A
Date: Sun, 08 Jul 2012 17:39:35 +0200
Message-ID: <1341761975.2038.28.camel@schesaplana>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	 <1341574388-7464-5-git-send-email-christian.riesch@omicron.at>
	 <1341596255.2923.7.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: michael@riesch.at
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Christian Riesch <christian.riesch@omicron.at>,
	netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay03.ispgateway.de ([80.67.29.28]:49058 "EHLO
	smtprelay03.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859Ab2GHPvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2012 11:51:36 -0400
In-Reply-To: <1341596255.2923.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-06 at 18:37 +0100, Ben Hutchings wrote:
> > +	priv->mdio->priv = (void *)dev;
> > +	priv->mdio->read = &asix_mdio_bus_read;
> > +	priv->mdio->write = &asix_mdio_bus_write;
> > +	priv->mdio->name = "Asix MDIO Bus";
> > +	snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "asix-%s",
> > +		 dev_name(dev->net->dev.parent));
> [...]
> 
> I think you need to ensure that the bus identifier is unique throughout
> its lifetime, but net devices can be renamed and that could lead to a
> collision.  Perhaps you could use the ifindex or the USB device path

Ben,

the dev_name function in the code above returns the sysfs filename of
the USB device (e.g. 1-0:1.0).

> (though that might be too long).

This may be a problem. The bus identifier may be 17 characters long, so
if we leave the endpoint/configuration part (:1.0) and the prefix away
it should be fine in any "normal" system. However, on a system with a
more-than-9-root-hubs 5-tier 127-devices-each USB infrastructure it
results in collisions. So is this approach acceptable?

Using the ifindex sounds good to me,

snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "asix-%d",
	dev->net->ifindex);

works on any system with less than 10^12 network interfaces.

Regards,
Michael
