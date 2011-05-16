From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Mon, 16 May 2011 22:08:59 +0100
Message-ID: <1305580139.2885.47.camel@bwh-desktop>
References: <20110516121339.GA1094@rere.qmqm.pl>
	 <1305335142.2851.70.camel@bwh-desktop> <20110514103539.GA5214@rere.qmqm.pl>
	 <1305513923.19966.20.camel@localhost>
	 <20110516132807.1A89F13A6A@rere.qmqm.pl>
	 <1305553066.19966.32.camel@localhost> <20110516142340.GA2980@rere.qmqm.pl>
	 <1305557597.2885.5.camel@bwh-desktop>  <20110516205137.GA7667@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57717 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411Ab1EPVJB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 17:09:01 -0400
In-Reply-To: <20110516205137.GA7667@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-16 at 22:51 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Mon, May 16, 2011 at 03:53:17PM +0100, Ben Hutchings wrote:
> > On Mon, 2011-05-16 at 16:23 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > > On Mon, May 16, 2011 at 02:37:46PM +0100, Ben Hutchings wrote:
> > > > On Mon, 2011-05-16 at 15:28 +0200, Micha=C5=82 Miros=C5=82aw wr=
ote:
> > > > > Remove NETIF_F_COMPAT since it's redundant and will be unused=
 after
> > > > > all drivers are converted to fix/set_features.
> > > > >=20
> > > > > Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmq=
m.pl>
> > > > > ---
> > > > >=20
> > > > > For net as we don't want to have ETHTOOL_F_COMPAT hit stable =
release.
> > > > [...]
> > > > ETHTOOL_F_WISH means that the requested features could not all =
be
> > > > enabled, *but are remembered*.  ETHTOOL_F_COMPAT means they wer=
e not
> > > > remembered.
> > > Hmm. So, lets just revert 39fc0ce5710c53bad14aaba1a789eec810c556f=
9
> > > (net: Implement SFEATURES compatibility for not updated drivers).
> > That's also problematic because it means we can't make any use of t=
he
> > 'available' masks from ETHTOOL_GFEATURES.
> >=20
> > The patch I sent is actually tested with a modified ethtool.  The
> > fallback works.  I don't think you've tested whether any of your
> > proposals can actually practically be used by ethtool.
>=20
> While reading your patches I noted some differences in the way we see
> the new [GS]FEATURES ops.
>=20
> First, you make NETIF_F_* flags part of the ethtool ABI. In my approa=
ch
> feature names become an ABI instead. That's what ETH_SS_FEATURES stri=
ng
> set is for, and that's what comments in kernel's <linux/ethtool.h>
> include say.

We've been through this before.  I can't use those names in ethtool
because they aren't the same as ethtool used previously.  I could make
it map strings to strings, but I don't see the point.

> dev->features are exposed directly by kernel only in two ways:
>  1. /sys/class/net/*/features - since NETIF_F_* flags are not exporte=
d
>     in headers for userspace, this should be treated like a debugging
>     facility and not an ABI
>  2. ETHTOOL_[GS]FLAGS - these export 5 flags (LRO, VLAN offload, NTup=
le,
>     and RX hashing) that are renamed to ETH_FLAG_* - only those const=
ants
>     are in the ABI and only in relation with ETHTOOL_[GS]FLAGS
>=20
> Second, you reimplement 'ethtool -K' using ETHTOOL_SFEATURES. Does th=
is mean
> that we want to get rid of ETHTOOL_[GS]{FLAGS,SG,...} from kernel?

We must not.

> The
> assumptions in those calls are a bit different from ETHTOOL_[GS]FEATU=
RES
> but there is an conversion layer in kernel that allows old binaries t=
o
> work correctly in the common case. (-EOPNOTSUPP is still returned for
> drivers which can't change particular feature. The difference is seen
> only in that disabling and enabling e.g. checksumming won't disable o=
ther
> dependent features in the result.)
>=20
> Right now we already agree that NETIF_F_COMPAT should go.
>=20
> I'll send my idea of the ethtool code using ETHTOOL_[GS]FEATURES and
> keeping NETIF_F_* flags internal to the kernel. It adds new modes (-w=
/-W).
> This might be made even more useful by adding simple wildcard matchin=
g.

I've explained before that I do not want to add new options to do
(mostly) the same thing.  Users should have not have to use a different
command depending on the kernel version.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

