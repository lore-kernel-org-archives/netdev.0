From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCHv3 2/2] tg3: Allow ethtool to enable/disable loopback.
Date: Wed, 4 May 2011 13:11:12 +0200
Message-ID: <20110504111112.GA15486@rere.qmqm.pl>
References: <1304471935-402-1-git-send-email-maheshb@google.com>
 <1304471935-402-2-git-send-email-maheshb@google.com>
 <1304471935-402-3-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Tom Herbert <therbert@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60291 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752751Ab1EDLLO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 07:11:14 -0400
Content-Disposition: inline
In-Reply-To: <1304471935-402-3-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 03, 2011 at 06:18:55PM -0700, Mahesh Bandewar wrote:
> This patch adds tg3_set_features() to handle loopback mode. Currently=
 the
> capability is added for the devices which support internal MAC loopba=
ck mode.
> So when enabled, it enables internal-MAC loopback.
[...]
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 7c7c9a8..46de633 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -6319,6 +6319,51 @@ static u32 tg3_fix_features(struct net_device =
*dev, u32 features)
>  	return features;
>  }
> =20
> +static int tg3_set_features(struct net_device *dev, u32 features)
> +{
> +	struct tg3 *tp =3D netdev_priv(dev);
> +	u32 cur_mode =3D 0;
> +	int err =3D 0;
> +
> +	if (!netif_running(dev)) {
> +		err =3D -EAGAIN;
> +		goto sfeatures_out;
> +	}

netdev_update_features() is not designed to handle -EAGAIN from
ndo_set_features callback. It might be useful to implement this
handling, but in this case you should just return 0 and check
dev->features in ndo_open callback.

Best Regards,
Micha=B3 Miros=B3aw
