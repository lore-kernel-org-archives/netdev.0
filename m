From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH v2 3/4] net: dsa: mv88e6xxx: add common and ppu
 remove function
Date: Wed, 28 Oct 2015 15:35:24 +0100
Message-ID: <20151028143524.GF2307@lunn.ch>
References: <5630D7FC.4010509@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57453 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966158AbbJ1Ofb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2015 10:35:31 -0400
Content-Disposition: inline
In-Reply-To: <5630D7FC.4010509@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2015 at 03:13:16PM +0100, Neil Armstrong wrote:
> With the previously introduced remove callback, add a
> mv88e6xxx common remove function to cleanup all resources.
> 
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  drivers/net/dsa/mv88e6xxx.c | 18 ++++++++++++++++++
>  drivers/net/dsa/mv88e6xxx.h |  2 ++
>  2 files changed, 20 insertions(+)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index b1b14f5..6287096 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -331,6 +331,16 @@ void mv88e6xxx_ppu_state_init(struct dsa_switch *ds)
>  	ps->ppu_timer.function = mv88e6xxx_ppu_reenable_timer;
>  }
> 
> +void mv88e6xxx_ppu_state_remove(struct dsa_switch *ds)
> +{
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	
> +	del_timer_sync(&ps->ppu_timer);
> +
> +	cancel_work_sync(&ps->bridge_work);
> +	flush_work(&ps->bridge_work);
> +}
> +

You add this function, but you don't use it anywhere?  Also, why
cancel bridge work, not ppu_work? Or has that been consolidated
in some patch i'm missing?

   Andrew
