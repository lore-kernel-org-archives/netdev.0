From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 03/16] net: reduce and unify printk level in
 netdev_fix_features()
Date: Sat, 22 Jan 2011 15:12:22 -0800
Message-ID: <1295737942.25868.114.camel@Joe-Laptop>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
	 <29e476c368b6580f7ff5215ca759b69c75d0e021.1295734271.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3267 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751790Ab1AVXMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 18:12:23 -0500
In-Reply-To: <29e476c368b6580f7ff5215ca759b69c75d0e021.1295734271.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-01-22 at 23:14 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Reduce printk() levels to KERN_INFO in netdev_fix_features() as this =
will
> be used by ethtool and might spam dmesg unnecessarily.
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 01d7ce2..168588f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5127,58 +5127,52 @@ static void rollback_registered(struct net_de=
vice *dev)
>  	rollback_registered_many(&single);
>  }
> =20
> -u32 netdev_fix_features(u32 features, const char *name)
> +u32 netdev_fix_features(struct net_device *dev, u32 features)

Perhaps this would be simpler as:
void netdev_fix_features(struct net_device *dev)

>  {
>  	/* Fix illegal checksum combinations */
>  	if ((features & NETIF_F_HW_CSUM) &&
>  	    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {

	if (dev->features & etc...) {
		dev->features &=3D etc...)

> +		netdev_info(dev,0
> +			"mixed HW and IP checksum settings.\n");

=46its nicely on a single line:

		netdev_info(dev, "mixed HW and IP checksum settings\n");=20

>  		features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
>  	}
> =20
>  	if ((features & NETIF_F_NO_CSUM) &&
>  	    (features & (NETIF_F_HW_CSUM|NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)=
)) {
> -		if (name)
> -			printk(KERN_NOTICE "%s: mixed no checksumming and other settings.=
\n",
> -				name);
> +		netdev_info(dev,
> +			"mixed no checksumming and other settings.\n");

Here too, etc...

		netdev_info(dev, "mixed no checksumming and other settings\n");


