From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net:mv88e6xxx: dispose irq mapping
Date: Tue, 6 Dec 2016 15:19:23 +0100
Message-ID: <20161206141923.GB26615@lunn.ch>
References: <1481018743-27208-1-git-send-email-volodymyr.bendiuga@westermo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44096 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753564AbcLFOT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 09:19:27 -0500
Content-Disposition: inline
In-Reply-To: <1481018743-27208-1-git-send-email-volodymyr.bendiuga@westermo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 06, 2016 at 11:05:43AM +0100, Volodymyr Bendiuga wrote:
> If this is not done, then it is not possible to map
> irq next time, after EPROBE_DEFER.
> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>

Hi Volodymyr

Thanks for your patches.

Please could you include in the subject line which tree it is for. See

Documentation/networking/netdev-FAQ.txt


> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 05942e3..12e7d38 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -420,6 +420,7 @@ static void mv88e6xxx_g1_irq_free(struct mv88e6xxx_chip *chip)
>  	mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, mask);
>  
>  	free_irq(chip->irq, chip);
> +	irq_dispose_mapping(chip->irq);

This seems like the wrong place to do this.

The mapping is created by chip->irq = of_irq_get(np, 0); in
mv88e6xxx_probe(). So the correct place to dispose of this mapping would be in
mv88e6xxx_remove() and the error path of mv88e6xxx_probe().

Thanks
	Andrew
