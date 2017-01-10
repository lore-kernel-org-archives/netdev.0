From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/8] net: dsa: Add support for platform data
Date: Tue, 10 Jan 2017 21:41:24 +0100
Message-ID: <20170110204124.GL22820@lunn.ch>
References: <20170110201235.21771-1-f.fainelli@gmail.com>
 <20170110201235.21771-7-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Stuart Yoder <stuart.yoder@nxp.com>,
        Ingo Tuchscherer <ingo.tuchscherer@linux.vnet.ibm.com>,
        "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54482 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750701AbdAJUlo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Jan 2017 15:41:44 -0500
Content-Disposition: inline
In-Reply-To: <20170110201235.21771-7-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -452,11 +455,14 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
>  	struct net_device *ethernet_dev;
>  	struct device_node *ethernet;
>  
> -	ethernet = of_parse_phandle(port->dn, "ethernet", 0);
> -	if (!ethernet)
> -		return -EINVAL;
> +	if (port->dn) {
> +		ethernet = of_parse_phandle(port->dn, "ethernet", 0);
> +		if (!ethernet)
> +			return -EINVAL;
> +		ethernet_dev = of_find_net_device_by_node(ethernet);
> +	} else
> +		ethernet_dev = dev_to_net_device(dst->pd->netdev);

Hi Florian

This is not going to work with John's rework of my multi CPU ports
code. I think you are going to have to modify the platform_data
structure to support multi-CPU ports.

I put higher priority on cleanly integrating multi-CPU ports using
device tree, than supporting legacy platforms. I'm O.K. with
preparatory patches, but i think we should wait for actually platform
data changes until after Johns code has landed and we can design the
platform_data to work with it.

	      Andrew
