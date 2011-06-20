From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RESENT PATCH] net: tuntap: Fix tun_net_fix_features()
Date: Mon, 20 Jun 2011 20:25:06 +0100
Message-ID: <1308597906.2701.148.camel@bwh-desktop>
References: <d66c8380b6c50fdcfe2dce344b39bb470a75ba3f.1308595725.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:24384 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139Ab1FTTZJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 15:25:09 -0400
In-Reply-To: <d66c8380b6c50fdcfe2dce344b39bb470a75ba3f.1308595725.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-20 at 21:14 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> tun->set_features are meant to limit not force the features.
>
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
>=20
> ---
>  drivers/net/tun.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 4dab85e..56981c2 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -458,7 +458,7 @@ static u32 tun_net_fix_features(struct net_device=
 *dev, u32 features)
>  {
>  	struct tun_struct *tun =3D netdev_priv(dev);
> =20
> -	return (features & tun->set_features) | (features & ~TUN_USER_FEATU=
RES);
> +	return features & (tun->set_features | ~TUN_USER_FEATURES);

(A & B) | (A & C) <=3D> A & (B | C)

This is a cosmetic change, not a fix.  Maybe you think it is clearer bu=
t
then you should say that in the commit message.

Ben.

>  }
> =20
>  static const struct net_device_ops tun_netdev_ops =3D {

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

