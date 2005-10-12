From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Add Wake on LAN support to sis900
Date: Tue, 11 Oct 2005 20:53:04 -0700
Message-ID: <20051011205304.34bc07ad.akpm@osdl.org>
References: <20051006111326.GA3242@renditai.milesteg.arr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Venzano <venza@brownhat.org>
In-Reply-To: <20051006111326.GA3242@renditai.milesteg.arr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniele Venzano <venza@brownhat.org> wrote:
>
> The patch availble below adds support for Wake on LAN to the sis900
> driver. Some register addresses were added to sis900.h and two new
> functions were implemented in sis900.c. WoL status is controlled by
> ethtool.
> Patch is against 2.6.13.
> 
> Comments are welcome, but also consider for inclusion in the -mm series.
> 
> --- ../../trunk/sis900.h	2005-07-17 10:43:23.000000000 +0200
> +++ sis900.h	2005-10-06 12:49:37.000000000 +0200

Please prepare patches in `patch -p1' form.  See
http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt.

> ...
> +	/* Detect Wake on Lan support */
> +	ret = inl(CFGPMC & PMESP);
> +	if (netif_msg_probe(sis_priv) && (ret & PME_D3C) == 0)
> +		printk(KERN_INFO "%s: Wake on LAN only available from suspend to RAM.", net_dev->name);
> +

How come?  Why doesn't it work after an ordinary `halt -p'?

> @@ -2015,6 +2082,8 @@
>  	.get_settings	= sis900_get_settings,
>  	.set_settings	= sis900_set_settings,
>  	.nway_reset	= sis900_nway_reset,
> +	.get_wol	= sis900_get_wol,
> +	.set_wol	= sis900_set_wol
>  };

We normally add a comma to the final field so that subsequent patches look
cleaner.
