From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Fix IXP 2000 network driver building.
Date: Mon, 12 Oct 2009 13:10:59 +0100
Message-ID: <1255349459.2931.7.camel@achroite>
References: <1255276546-31903-1-git-send-email-vince@simtec.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Vincent Sanders <vince@simtec.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24760 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755604AbZJLMLi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 08:11:38 -0400
In-Reply-To: <1255276546-31903-1-git-send-email-vince@simtec.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-10-11 at 16:55 +0100, Vincent Sanders wrote:
> The IXP 2000 network driver was failing to build as it has its own
> statistics gathering which was not compatible with the recent network
> device operations changes. This patch fixes the driver in the obvious
> way and has been compile tested. I have been unable to get the ixp200=
0
> maintainer to comment or test this fix.
[...]
> =EF=BB=BFdiff --git a/drivers/net/ixp2000/ixpdev.c
> b/drivers/net/ixp2000/ixpdev.c
> index 1272434..79cb6fa 100644
> --- a/drivers/net/ixp2000/ixpdev.c
> +++ b/drivers/net/ixp2000/ixpdev.c
> @@ -21,6 +21,7 @@
>  #include "ixp2400_tx.ucode"
>  #include "ixpdev_priv.h"
>  #include "ixpdev.h"
> +#include "pm3386.h"
> =20
>  #define DRV_MODULE_VERSION     "0.2"
> =20
> @@ -271,6 +272,15 @@ static int ixpdev_close(struct net_device *dev)
>         return 0;
>  }
> =20
> +static struct net_device_stats *ixpdev_get_stats(struct net_device
> *dev)
> +{
> +       struct ixpdev_priv *ip =3D netdev_priv(dev);
> +
> +       pm3386_get_stats(ip->channel, &(ip->stats));
> +
> +       return &(ip->stats);
> +}
> +
[...]

Is there any reason you can't use dev->stats instead of this private
field?

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

