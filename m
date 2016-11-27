From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] mv88e6xxx: Fix mv88e6xxx_g1_irq_free() interrupt count
Date: Sun, 27 Nov 2016 22:22:56 +0100
Message-ID: <20161127212256.GC13318@lunn.ch>
References: <1480279424-7830-1-git-send-email-afaerber@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>,
        Michal Hrusecki <Michal.Hrusecky@nic.cz>,
        Tomas Hlavacek <tomas.hlavacek@nic.cz>,
        Bed??icha Ko??atu <bedrich.kosata@nic.cz>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        linux-kernel@vger.kernel.org
To: Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58749 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752379AbcK0VXO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 16:23:14 -0500
Content-Disposition: inline
In-Reply-To: <1480279424-7830-1-git-send-email-afaerber@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 27, 2016 at 09:43:44PM +0100, Andreas Färber wrote:
> mv88e6xxx_g1_irq_setup() sets up chip->g1_irq.nirqs interrupt mappings,
> so free the same amount. This will be 8 or 9 in practice, less than 16.

Hi Andreas

The patch is correct, but please read
Documentation/networking/netdev-FAQ.txt
and then resubmit the patch.

    Andrew

> 
> Fixes: dc30c35be720 ("net: dsa: mv88e6xxx: Implement interrupt support.")
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Andreas Färber <afaerber@suse.de>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 98302358ceb9..95b9efb33ec7 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -421,7 +421,7 @@ static void mv88e6xxx_g1_irq_free(struct mv88e6xxx_chip *chip)
>  
>  	free_irq(chip->irq, chip);
>  
> -	for (irq = 0; irq < 16; irq++) {
> +	for (irq = 0; irq < chip->g1_irq.nirqs; irq++) {
>  		virq = irq_find_mapping(chip->g1_irq.domain, irq);
>  		irq_dispose_mapping(virq);
>  	}
> -- 
> 2.6.6
> 
