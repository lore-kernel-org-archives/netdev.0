From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] net: dsa: loop: Free resources if initialization is
 deferred
Date: Wed, 10 May 2017 12:30:39 +0800 (SGT)
Message-ID: <alpine.DEB.2.20.1705101229410.3326@hadrien>
References: <20170510041503.29363-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170510041503.29363-1-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 10 May 2017, Christophe JAILLET wrote:

> Free some devm'allocated memory in case of deferred driver initialization.
> This avoid to waste some memory in such a case.

I really think it would be helpful to mention the special behavior of
-EPROBE_DEFER.  It doesn't take much space, and it coud be helpful to
someone in the future.

julia

>
> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
>  drivers/net/dsa/dsa_loop.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/dsa/dsa_loop.c b/drivers/net/dsa/dsa_loop.c
> index a19e1781e9bb..557afb418320 100644
> --- a/drivers/net/dsa/dsa_loop.c
> +++ b/drivers/net/dsa/dsa_loop.c
> @@ -260,8 +260,11 @@ static int dsa_loop_drv_probe(struct mdio_device *mdiodev)
>  		return -ENOMEM;
>
>  	ps->netdev = dev_get_by_name(&init_net, pdata->netdev);
> -	if (!ps->netdev)
> +	if (!ps->netdev) {
> +		devm_kfree(&mdiodev->dev, ps);
> +		devm_kfree(&mdiodev->dev, ds);
>  		return -EPROBE_DEFER;
> +	}
>
>  	pdata->cd.netdev[DSA_LOOP_CPU_PORT] = &ps->netdev->dev;
>
> --
> 2.11.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
