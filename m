From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 5/6] net: dsa: add missing calls in dsa_switch_destroy
Date: Thu, 29 Oct 2015 15:00:58 +0100
Message-ID: <20151029140058.GS2307@lunn.ch>
References: <56321DCD.3070702@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58134 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757177AbbJ2OBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 10:01:09 -0400
Content-Disposition: inline
In-Reply-To: <56321DCD.3070702@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2015 at 02:23:25PM +0100, Neil Armstrong wrote:
> Add missing netif_carrier_off and phy_disconnect calls to the
> dsa_switch_destroy function to make sure the netdev and phy
> ressources are clean before complete removal.
> 
> Signed-off-by: Frode Isaksen <fisaksen@baylibre.com>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  net/dsa/dsa.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 597a462..11452e4 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -454,7 +454,9 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
>  		if (!ds->ports[port])
>  			continue;
> 
> +		netif_carrier_off(ds->ports[port]);
>  		unregister_netdev(ds->ports[port]);
> +		phy_disconnect(p->phy);
>  		free_netdev(ds->ports[port]);
>  	}

Once you make it actually compile....

I'm not sure this is safe. The loop above this one has just destroyed
some phys, and now you are potentially disconnecting a phy you just
destroyed, causing it to be accessed?

I would suggest you first fix the ordering in dsa_switch_destroy()
and then add the missing netif_carrier_off() and phy_disconnect().

Thanks
	Andrew
