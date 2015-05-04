From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 1/8] net: dsa: Move dsa_switch_tree final
 setup in separate function
Date: Sun, 03 May 2015 22:01:20 -0400 (EDT)
Message-ID: <20150503.220120.1999292394047077367.davem@davemloft.net>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com>
	<1430359064-23454-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58462 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbbEDCBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 22:01:22 -0400
In-Reply-To: <1430359064-23454-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 29 Apr 2015 18:57:37 -0700

> +static void dsa_setup_dst_end(struct net_device *dev, struct dsa_switch_tree *dst)
> +{
> +	/*
> +	 * If we use a tagging format that doesn't have an ethertype
> +	 * field, make sure that all packets from this point on get
> +	 * sent to the tag format's receive function.
> +	 */
> +	wmb();
> +	dev->dsa_ptr = (void *)dst;

I know you're just moving code, but this cast seems pointless to me.

dev->dsa_ptr is of type "struct dsa_switch_tree".
