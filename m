From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Fri, 12 Feb 2016 01:14:24 +0100
Message-ID: <56BD23E0.1090403@gmx.de>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bryan.Whitehead@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:63049 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890AbcBLAOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Feb 2016 19:14:35 -0500
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> +static int mchp9352_open(struct net_device *dev)
> +{

> +
> +	MCHP_TRACE(pdata, ifup, "Testing irq handler using IRQ %d", dev->irq);
> +	pdata->software_irq_signal = 0;
> +
> +	/* Testing irq handler */
> +	smp_wmb();

Should not there at least be a matching smp_rmb() in the irq handler?
Maybe an atomic_t would be a better choice for a flag like
software_irq_signal here.

> +
> +static int mchp9352_drv_probe(struct platform_device *pdev)

> +
> +	netif_carrier_off(dev);
> +
> +	retval = register_netdev(dev);
> +	if (retval) {
> +		MCHP_WARN(pdata, probe, "Error %i registering device", retval);
> +		goto out_free_irq;
> +	} else {
> +		MCHP_TRACE(pdata, probe,
> +			   "Network interface: \"%s\"", dev->name);
> +	}

Note that as soon as the network device is registered "open" may be
called so everything should be set up already. In this case the mac
address (dev->dev_addr) is accessed in open but may not yet contain
valid data when register_netdev is called.

Regards,
Lino
