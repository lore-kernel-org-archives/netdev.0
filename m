From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.10-rc1 15/15] wireless/orinoco: Wireless scanning support
Date: Tue, 26 Oct 2004 21:33:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026193355.GA22696@electric-eye.fr.zoreil.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098818888.9874.6.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1098818888.9874.6.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[...]
> --- a/drivers/net/wireless/orinoco.c	2004-10-26 13:44:23.281599064 -0400
> +++ b/drivers/net/wireless/orinoco.c	2004-08-17 17:26:31.000000000 -0400
> @@ -1442,6 +1442,80 @@
>  	       dev->name, s, status);
>  }
>  
> +/* Search scan results for requested BSSID, join it if found */
> +static void orinoco_join_ap(struct net_device *dev)
> +{
> +	struct orinoco_private *priv = netdev_priv(dev);
> +	struct hermes *hw = &priv->hw;
> +	int err;
> +	unsigned long flags;
> +	struct join_req {
> +		u8 bssid[ETH_ALEN];
> +		u16 channel;
> +	} __attribute__ ((packed)) req;
> +	const int atom_len = offsetof(struct prism2_scan_apinfo, atim);
> +	struct prism2_scan_apinfo *atom;
> +	int offset = 4;
> +	int found = 0;
> +	u8 *buf = NULL;
> +	u16 len;
> +
> +	/* Allocate buffer for scan results */
> +	buf = kmalloc(MAX_SCAN_LEN, GFP_KERNEL);
> +	if (!buf)
> +		return;
> +
> +	if (orinoco_lock(priv, &flags) != 0)
> +		return;

Leak.

--
Ueimor
