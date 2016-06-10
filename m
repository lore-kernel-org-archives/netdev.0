From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/4] net: dsa: bcm_sf2: Add VLAN support
Date: Fri, 10 Jun 2016 14:00:46 +0200
Message-ID: <20160610120046.GB2338@lunn.ch>
References: <1465519328-14249-1-git-send-email-f.fainelli@gmail.com>
 <1465519328-14249-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, jiri@mellanox.com,
	idosch@mellanox.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41457 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263AbcFJMAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2016 08:00:49 -0400
Content-Disposition: inline
In-Reply-To: <1465519328-14249-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -148,6 +155,9 @@ struct bcm_sf2_priv {
>  	struct device_node		*master_mii_dn;
>  	struct mii_bus			*slave_mii_bus;
>  	struct mii_bus			*master_mii_bus;
> +
> +	/* Cache of programmed VLANs */
> +	struct bcm_sf2_vlan		vlans[VLAN_N_VID];

Hi Florian

This is a 16Kbyte array. So i assume the whole priv structure needs 5
pages. Have you had any trouble allocating this much memory,
particularly once it has been used for a while and fragmented?

I just wondered if it might be better to use vmalloc() for the
vlans.

	Andrew
