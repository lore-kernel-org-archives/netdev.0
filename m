From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: __ethtool_set_sg: check for function pointer
 before using it
Date: Thu, 17 Mar 2011 16:52:13 +0000
Message-ID: <1300380733.2569.3.camel@bwh-desktop>
References: <20110317163720.GA26284@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53693 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242Ab1CQQwQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 12:52:16 -0400
In-Reply-To: <20110317163720.GA26284@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-17 at 17:37 +0100, Roger Luethi wrote:
> __ethtool_set_sg does not check if dev->ethtool_ops->set_sg is define=
d
> which can result in a NULL pointer dereference when ethtool is used t=
o
> change SG settings for drivers without SG support.
>=20
> Signed-off-by: Roger Luethi <rl@hellgate.ch>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Micha=C5=82, was this just an oversight or is there some reason why we
shouldn't check set_sg immediately?

Ben.

> ---
>=20
> Bug verified. Patch only compile-tested.
>
>  net/core/ethtool.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index c1a71bb..a1086fb 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1457,6 +1457,9 @@ static int __ethtool_set_sg(struct net_device *=
dev, u32 data)
>  {
>  	int err;
> =20
> +	if (!dev->ethtool_ops->set_sg)
> +		return -EOPNOTSUPP;
> +
>  	if (data && !(dev->features & NETIF_F_ALL_CSUM))
>  		return -EINVAL;
> =20

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

