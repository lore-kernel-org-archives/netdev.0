From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-2.6] ethtool: Remove fallback to old ethtool
 operations for ETHTOOL_SFEATURES
Date: Mon, 16 May 2011 03:45:23 +0100
Message-ID: <1305513923.19966.20.camel@localhost>
References: <1305335142.2851.70.camel@bwh-desktop>
	 <20110514103539.GA5214@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28363 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab1EPCpf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2011 22:45:35 -0400
In-Reply-To: <20110514103539.GA5214@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-05-14 at 12:35 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Sat, May 14, 2011 at 02:05:42AM +0100, Ben Hutchings wrote:
> > ethtool_set_feature_compat() squashes the feature mask into a boole=
an,
> > which is not correct for ethtool_ops::set_flags.
> >=20
> > We could fix this, but the fallback code for ETHTOOL_SFEATURES actu=
ally
> > makes things more complicated for the ethtool utility and any other
> > application using the ethtool API.  They will still need to fall ba=
ck to
> > the old offload control commands in order to support older kernel
> > versions.  The fallback code in the kernel adds a third possibility=
 for
> > them to handle.  So make ETHTOOL_SFEATURES fail when the driver
> > implements the old offload control operations, and let userland do =
the
> > fallback.
>=20
> BTW, the idea behind the compat code is that if ETHTOOL_[GS]FEATURES =
is
> available, then there should be no need to fallback to old ops. For
> a userspace tool that targets only kernels >=3D 2.6.39 there's no nee=
d
> to care about old ops at all.

Well that's not true, because those tools still have to deal with
ETHTOOL_F_COMPAT.  And we're supposed to have all drivers converted for
2.6.40, so the hypothetical new tool only has to wait one more release.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

