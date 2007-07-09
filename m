From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: Mon, 09 Jul 2007 16:18:59 +0200
Message-ID: <469243D3.3090208@trash.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>	<20070622034703.28886.5@janus.isnogud.escape.de>	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de>	<467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net>	<467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net>	<467D4965.40601@trash.net> <467D4D65.2080806@hartkopp.net>	<467D54AB.5010407@trash.net> <ygfzm2ciemk.fsf@janus.isnogud.escape.de>	<468BA83A.7070500@trash.net> <ygfodil7qpi.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	David Miller <davem@davemloft.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	j.hadi123@gmail.com, netdev@vger.kernel.org
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63826 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247AbXGIOTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 10:19:17 -0400
In-Reply-To: <ygfodil7qpi.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> + * CAN network devices *should* support a local loopback functionality
> + * (see Documentation/networking/can.txt). To test the handling of CAN
> + * interfaces that do not support the loopback both driver types are
> + * implemented inside this vcan driver. In the case that the driver does
> + * not support the loopback the IFF_LOOPBACK remains clear in dev->flags.
> + * This causes the PF_CAN core to perform the loopback as a fallback solution.
> + */
> +
> +static int loopback = 0; /* vcan default: no loopback, just free the skb */
> +module_param(loopback, int, S_IRUGO);
> +MODULE_PARM_DESC(loopback, "Loop back sent frames. vcan default: 0 (Off)");

...

> +static void vcan_setup(struct net_device *dev)
> +{
> +	DBG("dev %s\n", dev->name);
> +
> +	dev->type              = ARPHRD_CAN;
> +	dev->mtu               = sizeof(struct can_frame);
> +	dev->hard_header_len   = 0;
> +	dev->addr_len          = 0;
> +	dev->tx_queue_len      = 0;
> +	dev->flags             = IFF_NOARP;
> +
> +	/* set flags according to driver capabilities */
> +	if (loopback)
> +		dev->flags |= IFF_LOOPBACK;


Still configuration of the network device based on module parameters.
What about people that want loopback and non-loopback devices at the
same time?
