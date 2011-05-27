From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Sat, 28 May 2011 00:25:55 +0100
Message-ID: <1306538755.2759.31.camel@bwh-desktop>
References: <20110516.140958.625993829749556424.davem@davemloft.net>
	 <20110519100331.GA25103@rere.qmqm.pl> <20110524091437.GA10779@rere.qmqm.pl>
	 <20110524.153930.610330240390616957.davem@davemloft.net>
	 <20110524215923.GA20138@rere.qmqm.pl> <1306505626.2759.4.camel@bwh-desktop>
	 <20110527152809.GA7620@rere.qmqm.pl> <1306511150.2759.17.camel@bwh-desktop>
	 <20110527163409.GA8497@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:5614 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757475Ab1E0XZ7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 19:25:59 -0400
In-Reply-To: <20110527163409.GA8497@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-05-27 at 18:34 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Fri, May 27, 2011 at 04:45:50PM +0100, Ben Hutchings wrote:
> > On Fri, 2011-05-27 at 17:28 +0200, Micha=C5=82 Miros=C5=82aw wrote:
[...]
> > >      (note: ETHTOOL_S{SG,...} are not ever going away)
> > >    - causes NETIF_F_* to be an ABI
> > If feature flag numbers are not stable then what is the point of
> > /sys/class/net/<name>/features?  Also, I'm not aware that features =
have
> > ever been renumbered in the past.
>=20
> Since no NETIF_F_* were exported earlier, I assume /sys/class/net/*/f=
eatures
> is a debugging aid. What is it used for besides that?

xen-api <https://github.com/xen-org/xen-api> uses it in
scripts/InterfaceReconfigureVswitch.py.  Though it doesn't seem to be
used for a particularly good reason...

> [...]
> > > Both versions are rough at the edges, but working. Both assume th=
at no
> > > behaviour changes are to be made for old '-K' options.
> > No, my changes are intended to enhance the old options.
>=20
> Kernel side already enhances them to not forget other features
> 'wanted' state. What other enhancements are on your mind?

So it does; for some reason I didn't realise that.  Then I suppose ther=
e
isn't a benefit from using ETHTOOL_SFEATURES for existing feature flags=
=2E

> BTW, I just recalled that ETHTOOL_F_WISH is set only as an informatio=
n
> about bits in features[].valid masks. So zero return does not mean, t=
hat
> other features (not in .valid masks) haven't changed.

That was already true.

> This means that
> userspace needs to reread features after any SFEATURES call, not just
> those returning non-zero.

Not necessarily, though of course it is helpful to report consequential
feature changes.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

