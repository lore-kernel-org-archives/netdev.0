From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 5/5] net: dsa: bcm_sf2: Register our slave MDIO bus
Date: Tue, 07 Jun 2016 10:46:35 -0400
Message-ID: <87oa7dxdis.fsf@ketchup.mtl.sfl>
References: <1465254895-11152-1-git-send-email-f.fainelli@gmail.com> <1465254895-11152-6-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemlof.net, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45890 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453AbcFGOqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 10:46:40 -0400
In-Reply-To: <1465254895-11152-6-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli <f.fainelli@gmail.com> writes:

>  static int bcm_sf2_sw_setup(struct dsa_switch *ds)
>  {
>  	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
> @@ -972,6 +1099,12 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
>  		goto out_unmap;
>  	}
>  
> +	ret = bcm_sf2_mdio_register(ds);
> +	if (ret) {
> +		pr_err("failed to register MDIO bus\n");
> +		goto out_unmap;
> +	}
> +
>  	/* Disable all interrupts and request them */
>  	bcm_sf2_intr_disable(priv);

Hum reviewing that again, I see that if one of the 2 subsequent calls to
request_irq fails, you end up with an unregistered MDIO bus.

We have the same issue in the mv88e6xxx legacy probe code if dsa.c fails
to allocate the dsa_switch structure. I'm moving the MDIO register code
to the setup function like you are doing here (good idea!) to fix that.

Thanks,

        Vivien
