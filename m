From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 1/8] S2io: cosmetic changes
Date: Thu, 14 Oct 2004 10:39:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416E8F9D.7040300@pobox.com>
References: <003e01c4b18b$0578cd70$6c10100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Francois Romieu'" <romieu@fr.zoreil.com>, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, raghavendra.koushik@s2io.com,
        rapuru.sriram@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@s2io.com
In-Reply-To: <003e01c4b18b$0578cd70$6c10100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ravinandan Arakali wrote:
> Hi All,
> This is the first patch in the 8 part series. I'll be sending
> the remaining immediately following this patch.

OK this is MUCH improved, thanks much.

There is one final problem with your patches:  your email program 
(Outlook, it appears?) is mangling patches, preventing them from being 
applied by a script that looks directly at the email.  Example from the 
first few lines of your first patch:
> --- vanilla-linux/drivers/net/s2io.c	2004-10-06 11:31:09.552305224 -0700
> +++ linux-2.6.8.1/drivers/net/s2io.c	2004-10-06 13:03:08.087360376 -0700
> @@ -69,7 +69,7 @@
> =20
>  /* S2io Driver name & version. */
>  static char s2io_driver_name[] =3D "s2io";
> -static char s2io_driver_version[] =3D "Version 1.0";
> +static char s2io_driver_version[] =3D "Version 1.7.5.1";
> =20
>  #define LINK_IS_UP(val64) (!(val64 & (ADAPTER_STATUS_RMAC_REMOTE_FAULT =
> | \
>  				      ADAPTER_STATUS_RMAC_LOCAL_FAULT)))
> @@ -99,45 +99,45 @@
>  };
> =20
>  static char ethtool_stats_keys[][ETH_GSTRING_LEN] =3D {


Now we move on the content portion of the review :)

> This first patch contains cosmetic changes such as indentation, 
> change in comment styles, variable name changes etc.
> 
> Randy, we'll implement your comment about C99 syntax along with
> all the other comments received, in the next submission.
> 
> Signed-off-by: Raghavendra Koushik <raghavendra.koushik@s2io.com>

Patch 1 comments:

1) undescribed non-cosmetic change:

> @@ -1240,82 +1290,72 @@
>          * force link down. Since link is already up, we will get
>          * link state change interrupt after this reset
>          */
> -       writeq(0x8007051500000000ULL, &bar0->dtx_control);
> +       writeq(0x80010515001E0000ULL, &bar0->dtx_control);
>         val64 = readq(&bar0->dtx_control);
> -       writeq(0x80070515000000E0ULL, &bar0->dtx_control);
> +       udelay(50);
> +       writeq(0x80010515001E00E0ULL, &bar0->dtx_control);
>         val64 = readq(&bar0->dtx_control);
> +       udelay(50);
>         writeq(0x80070515001F00E4ULL, &bar0->dtx_control);
>         val64 = readq(&bar0->dtx_control);
> +       udelay(50);
>  
>         return SUCCESS;

Resolution:  describe change in patch description, or move change to 
another patch


2) undescribed non-cosmetic change:

>  #ifdef CONFIG_S2IO_NAPI
>         dev->poll = s2io_poll;
> -       dev->weight = 128;      /* For now. */
> +       dev->weight = 90;       /* For now. */
>  #endif

Resolution:  describe change in patch description, or move change to 
another patch

3) non-cosmetic change, that should not be present in upstream sources:

> +#ifdef SET_ETHTOOL_OPS
>         SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
> -
> +#endif

Compatibility defines should be kept in an external package, to keep the 
kernel source relatively clean.  There exist compatibility packages such 
as "kcompat" (http://sf.net/projects/gkernel/) that allow you to develop 
a driver using the current kernel API, and then add the needed compat 
definitions in a separate module.

Resolution:  remove #ifdef

4) non-cosmetic change, that should not be present in upstream sources:

> +#ifndef SET_ETHTOOL_OPS
> +#define SUPPORTED_10000baseT_Full (1 << 12)
> +#endif

Resolution:  remove all three lines I quoted

5) don't add this #ifdef either:

> +#ifdef SET_ETHTOOL_OPS
>  static struct ethtool_ops netdev_ethtool_ops;
> +#endif




More comments follow in upcoming emails.
