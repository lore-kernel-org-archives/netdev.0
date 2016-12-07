From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next v2] dsa:mv88e6xxx: dispose irq mapping for
 chip->irq
Date: Wed, 7 Dec 2016 15:11:44 +0100
Message-ID: <20161207141144.GJ18817@lunn.ch>
References: <1481106907-30908-1-git-send-email-volodymyr.bendiuga@westermo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, volodymyr.bendiuga-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Volodymyr Bendiuga <volodymyr.bendiuga-qeDNsGSBLoYwFerOooGFRg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1481106907-30908-1-git-send-email-volodymyr.bendiuga-qeDNsGSBLoYwFerOooGFRg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2016 at 11:35:07AM +0100, Volodymyr Bendiuga wrote:
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga-qeDNsGSBLoYwFerOooGFRg@public.gmane.org>

You need some text in the Change log. Say why this change is needed,
etc.

Looking through other users of of_irq_get(), i don't see any disposing
of the mapping. It is not obvious you need to do this. The name does
not give any hint.

Maybe we should add an of_irq_put() which would clean up the mapping?

      Andrew


> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 173ea97..0c3271d 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -4483,7 +4483,7 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
>  		mutex_unlock(&chip->reg_lock);
>  
>  		if (err)
> -			goto out;
> +			goto out_dispose;
>  
>  		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT)) {
>  			err = mv88e6xxx_g2_irq_setup(chip);
> @@ -4513,6 +4513,9 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
>  		mv88e6xxx_g1_irq_free(chip);
>  		mutex_unlock(&chip->reg_lock);
>  	}
> +
> +out_dispose:
> +	irq_dispose_mapping(chip->irq);
>  out:
>  	return err;
>  }
> @@ -4530,6 +4533,7 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
>  		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT))
>  			mv88e6xxx_g2_irq_free(chip);
>  		mv88e6xxx_g1_irq_free(chip);
> +		irq_dispose_mapping(chip->irq);
>  	}
>  }
>  
> -- 
> 2.7.4
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
