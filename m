From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Fri, 27 May 2011 16:45:50 +0100
Message-ID: <1306511150.2759.17.camel@bwh-desktop>
References: <20110516.140958.625993829749556424.davem@davemloft.net>
	 <20110519100331.GA25103@rere.qmqm.pl> <20110524091437.GA10779@rere.qmqm.pl>
	 <20110524.153930.610330240390616957.davem@davemloft.net>
	 <20110524215923.GA20138@rere.qmqm.pl> <1306505626.2759.4.camel@bwh-desktop>
	 <20110527152809.GA7620@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27494 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab1E0Ppx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 11:45:53 -0400
In-Reply-To: <20110527152809.GA7620@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-05-27 at 17:28 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Fri, May 27, 2011 at 03:13:46PM +0100, Ben Hutchings wrote:
> > On Tue, 2011-05-24 at 23:59 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > > On Tue, May 24, 2011 at 03:39:30PM -0400, David Miller wrote:
> > > > From: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> > > > Date: Tue, 24 May 2011 11:14:37 +0200
> > > > > On Thu, May 19, 2011 at 12:03:31PM +0200, Micha=C5=82 Miros=C5=
=82aw wrote:
> > > > >> On Mon, May 16, 2011 at 02:09:58PM -0400, David Miller wrote=
:
> > > > >> > You guys really need to sort this out properly.
> > > > >> > Please resubmit whatever final solution is agreed upon.
> > > > >> I noticed that v2.6.39 was tagged today. We should definitel=
y remove
> > > > >> NETIF_F_COMPAT so it won't bite us in the future. The other =
patch that
> > > > >> fixes ethtool_ops->set_flags compatibility is a bugfix, so i=
t should go
> > > > >> in - if we decide that the SFEATURES compatibility should be=
 removed
> > > > >> it won't matter.
> [...]
> > > We could just wait for 2.6.40 and pretend this code part never ex=
isted. ;-)
> > I think I will make ethtool check for a minimum kernel version of 2=
=2E6.40
> > before using ETHTOOL_{G,S}FEATURES.
>=20
> > > I'll rebase the first patch tomorrow. Without it the compatibilit=
y in
> > > ETHTOOL_SFEATURES for non-converted drivers is busted wrt set_fla=
gs.
> > This is an improvement, but I still think the fallback is fundament=
ally
> > broken - there's no good way for userland to tell what (if anything=
)
> > went wrong when the return value has ETHTOOL_F_COMPAT set.
>=20
> The same situation happens with ETHTOOL_F_WISH (userspace needs to re=
read
> the features to find out what happened) and with old ETHTOOL_S{TSO,SG=
,...}
> (those return success if any of the features in the group changes and=
 also
> posibly disable other features when one is disabled). This wasn't rea=
lly
> checked before.
>=20
> Ben, I think I commented on your proposal of the userspace part, but =
I might
> have missed some of your arguments about mine. Let's sum those up:
>=20
> Your version:
>    - reimplements ETHTOOL_Sxx via ETHTOOL_SFEATURES in userspace for =
kernels
>      supporting the latter

No, it implements 'ethtool -K' using ETHTOOL_SFEATURES.  Maybe you
consider the ethtool utility to be a thin wrapper over the ethtool API,
but that is not my intent.

>      (note: ETHTOOL_S{SG,...} are not ever going away)
>    - causes NETIF_F_* to be an ABI

If feature flag numbers are not stable then what is the point of
/sys/class/net/<name>/features?  Also, I'm not aware that features have
ever been renumbered in the past.

I think ethtool should maintain a feature bitmask rather than the
separate flags it currently does, and I previously attempted this using
a private set of flags.  Shortly afterward that, you proposed to
introduce the new features interfaces, and it seemed to me to make sens=
e
to use the net device feature flags in ethtool.

David, do you think feature flag numbers should be considered a
userspace (i.e. stable) ABI or not?

>    - does not support new features

Not immediately.  I intend to do that afterward.

> My version:
>    - implements only new features via ETHTOOL_SFEATURES (old calls ar=
e still used)
>    - makes feature names an ABI (for scripts actually, not the tool)
>    - supports any new features kernel reports without code changes

Right.  I definitely should incorporate your code for looking up
features by string.

> Both versions are rough at the edges, but working. Both assume that n=
o
> behaviour changes are to be made for old '-K' options.

No, my changes are intended to enhance the old options.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

