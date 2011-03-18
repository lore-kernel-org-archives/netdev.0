From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: implement dev_disable_lro() hw_features
 compatibility
Date: Fri, 18 Mar 2011 18:13:06 +0000
Message-ID: <1300471986.2589.26.camel@bwh-desktop>
References: <37d3c96bc52c87fcd4cdd39c9c852b1d2bbc249d.1300466356.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:32269 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937Ab1CRSOV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 14:14:21 -0400
In-Reply-To: <37d3c96bc52c87fcd4cdd39c9c852b1d2bbc249d.1300466356.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-18 at 18:42 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Implement compatibility with new hw_features for dev_disable_lro().

Good point, but...

> This is a transition path - dev_disable_lro() should be later
> integrated into netdev_fix_features() after all drivers are converted=
=2E
>
> There's no point in exporting __ethtool_set_flags() as it and dev_dis=
able_lro()
> are always built-in.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---
>=20
> Patch is build-tested only, as I don't have any LRO-capable hardware.
> It might be prettier to move dev_disable_lro() to ethtool.c.

It *looks* right.

>  net/core/dev.c     |   20 ++++++++++++--------
>  net/core/ethtool.c |    2 +-
>  2 files changed, 13 insertions(+), 9 deletions(-)
>=20
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0b88eba..105e082 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1353,14 +1353,18 @@ EXPORT_SYMBOL(dev_close);
>   */
>  void dev_disable_lro(struct net_device *dev)
>  {
> -	if (dev->ethtool_ops && dev->ethtool_ops->get_flags &&
> -	    dev->ethtool_ops->set_flags) {
> -		u32 flags =3D dev->ethtool_ops->get_flags(dev);
> -		if (flags & ETH_FLAG_LRO) {
> -			flags &=3D ~ETH_FLAG_LRO;
> -			dev->ethtool_ops->set_flags(dev, flags);
> -		}
> -	}
> +	extern int __ethtool_set_flags(struct net_device *, u32);
[...]

Local function declarations are a very bad idea, as they are not checke=
d
against the function definition.  Please declare the function in
<linux/ethtool.h>; that does not oblige us to export it.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

