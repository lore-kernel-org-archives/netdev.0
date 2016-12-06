From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net:dsa:mv88e6xxx: delete timer and cancel ppu_work
Date: Tue, 6 Dec 2016 15:22:26 +0100
Message-ID: <20161206142226.GD26615@lunn.ch>
References: <1481029062-16668-1-git-send-email-volodymyr.bendiuga@westermo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, volodymyr.bendiuga@gmail.com,
        Jonas Johansson <jonas.johansson@westermo.se>
To: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44143 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751951AbcLFOkh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 09:40:37 -0500
Content-Disposition: inline
In-Reply-To: <1481029062-16668-1-git-send-email-volodymyr.bendiuga@westermo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 06, 2016 at 01:57:42PM +0100, Volodymyr Bendiuga wrote:
> Signed-off-by: Jonas Johansson <jonas.johansson@westermo.se>
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index ca453f3..4212fb6 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -4528,8 +4528,11 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
>  out_mdio:
>  	mv88e6xxx_mdio_unregister(chip);
>  out_g2_irq:
> -	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT) && chip->irq > 0)
> +	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G2_INT) && chip->irq > 0) {
>  		mv88e6xxx_g2_irq_free(chip);
> +		del_timer(&chip->ppu_timer);
> +		cancel_work_sync(&chip->ppu_work);
> +	}

Why do this here, inside this if statement?

Vivien has also just reworked the PPU code. Please take a look at his
patches and see if they fix the issue.

	Thanks
		Andrew
