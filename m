From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] phy: new SMSC LAN83C185 PHY driver
Date: Sun, 7 May 2006 20:56:51 +0200
Message-ID: <20060507185651.GA28912@electric-eye.fr.zoreil.com>
References: <E1Fcj4p-00061b-3o@fencepost.gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: afleming@freescale.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35791 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751200AbWEGS7P
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 14:59:15 -0400
To: Herbert Valerio Riedel <hvr@gnu.org>
Content-Disposition: inline
In-Reply-To: <E1Fcj4p-00061b-3o@fencepost.gnu.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> new file mode 100644
> index 0000000..b96eb52
> --- /dev/null
> +++ b/drivers/net/phy/smsc.c
[...]
> +/* prototypes */
> +static int lan83c185_config_init(struct phy_device *);
> +static int lan83c185_config_intr(struct phy_device *);
> +static int lan83c185_ack_interrupt(struct phy_device *);

The forward declarations are useless.

> +static int lan83c185_config_init(struct phy_device *phydev)
> +{
> +	pr_debug ("%s: config_init\n", phydev->attached_dev->name);

drivers/net/phy/*c does not use space before brace when functions
are called.

[...]
> +static struct phy_driver lan83c185_driver = {
> +	.phy_id		= 0x0007c0a0, /* OUI=0x00800f, Model#=0x0a */
> +	.phy_id_mask    = 0xfffffff0,
> +	.name		= "SMSC LAN83C185",
> +	
> +	.features       = (PHY_BASIC_FEATURES | SUPPORTED_Pause 
> +			   | SUPPORTED_Asym_Pause),
> +	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
> +
> +	/* basic functions */
> +	.config_aneg	= genphy_config_aneg,
> +	.read_status	= genphy_read_status,
> +	.config_init	= lan83c185_config_init,
> +
> +	/* IRQ related */
> +	.ack_interrupt  = lan83c185_ack_interrupt,
> +        .config_intr    = lan83c185_config_intr,

Whitespace/tab damage.

[...]
> +static int __init smsc_init(void)
> +{
> +        int rc;
> +
> +        if ((rc = phy_driver_register (&lan83c185_driver)))
> +                goto err_register_lan83c185_driver;
> +
> +        return 0;
> +	
> +	/* phy_driver_unregister (&lan83c185_driver); */
> + err_register_lan83c185_driver:

Wow. :o)

What about:

static int __init smsc_init(void)
{
	return phy_driver_register(&lan83c185_driver);
}

> +/*
> + * Overrides for Emacs so that we follow Linus's tabbing style.
> + * Emacs will notice this stuff at the end of the file and automatically
> + * adjust the settings for this buffer only.  This must remain at the end
> + * of the file.
> + * ---------------------------------------------------------------------------
> + * Local variables:
> + * c-file-style: "linux"
> + * End:
> + */

Bloat. Where files in drivers/net include similar stuff, the lengthy
explanation was removed.

The pr_debug statements ought to go imvho.

The patch contains a few tabs/whitespace at end of lines.

-- 
Ueimor
