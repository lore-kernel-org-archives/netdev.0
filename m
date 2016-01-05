From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 15/24] dsa: Register netdev before phy
Date: Mon, 04 Jan 2016 17:59:31 -0800
Message-ID: <568B2383.2010608@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-16-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35931 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbcAECAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 21:00:04 -0500
Received: by mail-pf0-f181.google.com with SMTP id 65so166295892pff.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 18:00:03 -0800 (PST)
In-Reply-To: <1451929022-5580-16-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> When the phy is connected, an info message is printed. If the netdev
> it is attached to has not been registered yet, the name
> 'uninitialised' in the output. By registering the netdev first, then
> connecting they phy, we can avoid this.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---

[snip]

> +	ret = dsa_slave_phy_setup(p, slave_dev);
> +	if (ret) {
> +		netdev_err(master, "error %d setting up slave phy\n", ret);
> +		free_netdev(slave_dev);
> +		return ret;
> +	}
> +
>  	netif_carrier_off(slave_dev);

Humm, I think this should be moved before dsa_slave_phy_setup() because
some of the PHY library calls made in dsa_slave_phy_setup() are starting
the PHY library state machine, so this call here might end up undoing
some of what the library just did. This definitively belongs before the
register_netdev() call though.
-- 
Florian
