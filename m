From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 4/4] net-next: dsa: qca8k: add support for multiple cpu
 ports
Date: Wed, 4 Jan 2017 15:12:31 +0100
Message-ID: <20170104141231.GM10768@lunn.ch>
References: <1483515484-21793-1-git-send-email-john@phrozen.org>
 <1483515484-21793-5-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42934 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935333AbdADOkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 09:40:16 -0500
Content-Disposition: inline
In-Reply-To: <1483515484-21793-5-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	/* Setup the cpu ports */
> +	for (i = 0; i < DSA_MAX_PORTS; i++) {
> +		struct net_device *netdev;
> +		int phy_mode = -1;
> +
> +		if (!dsa_is_cpu_port(ds, i))
> +			continue;
> +
> +		netdev = ds->dst->pd->chip->port_ethernet[i];
> +		if (!netdev) {
> +			pr_err("Can't find netdev for port%d\n", i);
> +			return -ENODEV;
> +		}
> +
> +		/* Initialize CPU port pad mode (xMII type, delays...) */
> +		phy_mode = of_get_phy_mode(netdev->dev.parent->of_node);
> +		if (phy_mode < 0) {
> +			pr_err("Can't find phy-mode for port:%d\n", i);
> +			return phy_mode;
> +		}

Hi John

We try to avoid having the switch drivers parse the DSA device
tree. There is code in the DSA core to do what you want here.

dsa.c: dsa_cpu_dsa_setup() will parse the phy-mode property, if you
have a fixed-phy node in the "cpu" or "dsa" node. It will then call
the drivers adjust_list_() function, which can then set the xMII type
etc.

The problem might be how to make use of this without breaking
backwards compatibility with older device tree blobs.

	  Andrew
