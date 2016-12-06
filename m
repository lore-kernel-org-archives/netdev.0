From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] dsa:mv88e6xxx: allow address 0x1 in smi_init
Date: Tue, 6 Dec 2016 15:27:11 +0100
Message-ID: <20161206142711.GE26615@lunn.ch>
References: <1481029592-19496-1-git-send-email-volodymyr.bendiuga@westermo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, volodymyr.bendiuga@gmail.com
To: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44115 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751936AbcLFO1j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 09:27:39 -0500
Content-Disposition: inline
In-Reply-To: <1481029592-19496-1-git-send-email-volodymyr.bendiuga@westermo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 06, 2016 at 02:06:32PM +0100, Volodymyr Bendiuga wrote:
> Westermo devices use this address.

I think we can have a better change log entry than that. How about:

Some devices, such as the mv88e6097 do have ADDR[0] external and so it
is possible to configure the device to use SMI address 0x1. Remove the
restriction, as there are boards using this address.

Thanks
	Andrew

> 
> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 4212fb6..05942e3 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -4253,10 +4253,6 @@ static void mv88e6xxx_phy_destroy(struct mv88e6xxx_chip *chip)
>  static int mv88e6xxx_smi_init(struct mv88e6xxx_chip *chip,
>  			      struct mii_bus *bus, int sw_addr)
>  {
> -	/* ADDR[0] pin is unavailable externally and considered zero */
> -	if (sw_addr & 0x1)
> -		return -EINVAL;
> -
>  	if (sw_addr == 0)
>  		chip->smi_ops = &mv88e6xxx_smi_single_chip_ops;
>  	else if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_MULTI_CHIP))
> -- 
> 2.7.4
> 
