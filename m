From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-2.6] ethtool: Remove fallback to old ethtool
 operations for ETHTOOL_SFEATURES
Date: Sat, 14 May 2011 11:54:57 +0200
Message-ID: <20110514095457.GA31970@rere.qmqm.pl>
References: <1305335142.2851.70.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:42647 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751899Ab1ENJy6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 05:54:58 -0400
Content-Disposition: inline
In-Reply-To: <1305335142.2851.70.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 14, 2011 at 02:05:42AM +0100, Ben Hutchings wrote:
> ethtool_set_feature_compat() squashes the feature mask into a boolean=
,
> which is not correct for ethtool_ops::set_flags.
>=20
> We could fix this, but the fallback code for ETHTOOL_SFEATURES actual=
ly
> makes things more complicated for the ethtool utility and any other
> application using the ethtool API.  They will still need to fall back=
 to
> the old offload control commands in order to support older kernel
> versions.  The fallback code in the kernel adds a third possibility f=
or
> them to handle.  So make ETHTOOL_SFEATURES fail when the driver
> implements the old offload control operations, and let userland do th=
e
> fallback.
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

This will disable SFEATURES for drivers which implement changing newer
features that have no old ethtool ops (e.g.  NETIF_F_LOOPBACK), but are
not converted, yet. This might matter when bisecting.

It's easy to fix this. The code is going away for 2.6.40, though.
Do you want to get rid of ETHTOOL_F_COMPAT bit before 2.6.39?

BTW, what are the complications for userspace?

This change misses ethtool_get_features_compat() setting available bits=
=2E

Best Regards,
Micha=B3 Miros=B3aw
