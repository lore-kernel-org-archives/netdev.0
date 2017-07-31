From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Simplify
 lan9303_xxx_packet_processing() usage
Date: Mon, 31 Jul 2017 15:46:40 +0200
Message-ID: <20170731134640.GD24562@lunn.ch>
References: <20170731113355.4284-1-privat@egil-hjelmeland.no>
 <20170731113355.4284-3-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170731113355.4284-3-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2017 at 01:33:55PM +0200, Egil Hjelmeland wrote:
> Simplify usage of lan9303_enable_packet_processing,
> lan9303_disable_packet_processing()
> 
> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
> ---
>  drivers/net/dsa/lan9303-core.c | 24 ++++++++++--------------
>  1 file changed, 10 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
> index 4d2bb8144c15..705267a1d2ba 100644
> --- a/drivers/net/dsa/lan9303-core.c
> +++ b/drivers/net/dsa/lan9303-core.c
> @@ -559,15 +559,16 @@ static int lan9303_handle_reset(struct lan9303 *chip)
>  /* stop processing packets for all ports */
>  static int lan9303_disable_processing(struct lan9303 *chip)
>  {
> -	int ret;
> +	int p;
>  
> -	ret = lan9303_disable_packet_processing(chip, 0);
> -	if (ret)
> -		return ret;
> -	ret = lan9303_disable_packet_processing(chip, 1);
> -	if (ret)
> -		return ret;
> -	return lan9303_disable_packet_processing(chip, 2);
> +	for (p = 0; p <= 2; p++) {
> +		int ret;
> +
> +		ret = lan9303_disable_packet_processing(chip, p);
> +		if (ret)
> +			return ret;
> +	}
> +	return 0;
>  }
>  
>  static int lan9303_check_device(struct lan9303 *chip)
> @@ -760,7 +761,6 @@ static int lan9303_port_enable(struct dsa_switch *ds, int port,
>  	/* enable internal packet processing */
>  	switch (port) {
>  	case 1:
> -		return lan9303_enable_packet_processing(chip, port);
>  	case 2:
>  		return lan9303_enable_packet_processing(chip, port);
>  	default:
> @@ -779,13 +779,9 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
>  	/* disable internal packet processing */
>  	switch (port) {
>  	case 1:
> -		lan9303_disable_packet_processing(chip, port);
> -		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 1,
> -				  MII_BMCR, BMCR_PDOWN);
> -		break;
>  	case 2:
>  		lan9303_disable_packet_processing(chip, port);
> -		lan9303_phy_write(ds, chip->phy_addr_sel_strap + 2,
> +		lan9303_phy_write(ds, chip->phy_addr_sel_strap + port,
>  				  MII_BMCR, BMCR_PDOWN);
>  		break;
>  	default:

:-)

So maybe i would squash this part into the previous patch. You were
touching the functions anyway, and the change is obvious, so easy to
review.

But it is also O.K. this way. The cover note could of helped. You
could of said something like: "Changes made in the first patch allow
some simplifications to be made in the same code in the second patch.

Breaking changes up is hard, and you cannot please everybody, all the
time.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
