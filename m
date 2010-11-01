From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/4] Ethtool: convert get_sg/set_sg calls to
 hw_features flag
Date: Mon, 01 Nov 2010 21:15:50 +0000
Message-ID: <1288646150.2231.62.camel@achroite.uk.solarflarecom.com>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
	 <9d89236b6e4ff8c66937fbd7d8ce76602e680c5b.1288496404.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25144 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156Ab0KAVPy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 17:15:54 -0400
In-Reply-To: <9d89236b6e4ff8c66937fbd7d8ce76602e680c5b.1288496404.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-10-30 at 06:28 +0200, Micha=C5=82 Miros=C5=82aw wrote:
[...]
> @@ -1088,7 +1076,19 @@ static int __ethtool_set_sg(struct net_device =
*dev, u32 data)
>  		if (err)
>  			return err;
>  	}
> -	return dev->ethtool_ops->set_sg(dev, data);
> +
> +	if (dev->ethtool_ops->hw_set_sg) {
> +		err =3D dev->ethtool_ops->hw_set_sg(dev, data);
> +		if (err)
> +			return min(err, 0);
> +	}
> +
> +	if (data)
> +		dev->features |=3D NETIF_F_SG;
> +	else
> +		dev->features &=3D ~NETIF_F_SG;
> +
> +	return 0;
>  }
[...]

The odd semantics of positive return values really need to be documente=
d
- both in the commit message and in the comment on struct ethtool_ops.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

