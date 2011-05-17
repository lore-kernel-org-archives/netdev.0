From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Tue, 17 May 2011 10:45:43 +0200
Message-ID: <20110517084543.GB18423@rere.qmqm.pl>
References: <20110514103539.GA5214@rere.qmqm.pl>
 <1305513923.19966.20.camel@localhost>
 <20110516132807.1A89F13A6A@rere.qmqm.pl>
 <1305553066.19966.32.camel@localhost>
 <20110516142340.GA2980@rere.qmqm.pl>
 <1305557597.2885.5.camel@bwh-desktop>
 <20110516205137.GA7667@rere.qmqm.pl>
 <1305580139.2885.47.camel@bwh-desktop>
 <20110516215034.GA8463@rere.qmqm.pl>
 <1305583775.2885.65.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57405 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752142Ab1EQIpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 04:45:44 -0400
Content-Disposition: inline
In-Reply-To: <1305583775.2885.65.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 11:09:35PM +0100, Ben Hutchings wrote:
> On Mon, 2011-05-16 at 23:50 +0200, Micha=B3 Miros=B3aw wrote:
> > On Mon, May 16, 2011 at 10:08:59PM +0100, Ben Hutchings wrote:
> > > On Mon, 2011-05-16 at 22:51 +0200, Micha=B3 Miros=B3aw wrote:
> > > > On Mon, May 16, 2011 at 03:53:17PM +0100, Ben Hutchings wrote:
> > > > > On Mon, 2011-05-16 at 16:23 +0200, Micha=B3 Miros=B3aw wrote:
> > > > > > On Mon, May 16, 2011 at 02:37:46PM +0100, Ben Hutchings wro=
te:
> > > > > > > On Mon, 2011-05-16 at 15:28 +0200, Micha=B3 Miros=B3aw wr=
ote:
> > > > > > > > Remove NETIF_F_COMPAT since it's redundant and will be =
unused after
> > > > > > > > all drivers are converted to fix/set_features.
> > > > > > > >=20
> > > > > > > > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmq=
m.pl>
> > > > > > > > ---
> > > > > > > >=20
> > > > > > > > For net as we don't want to have ETHTOOL_F_COMPAT hit s=
table release.
> > > > > > > [...]
> > > > > > > ETHTOOL_F_WISH means that the requested features could no=
t all be
> > > > > > > enabled, *but are remembered*.  ETHTOOL_F_COMPAT means th=
ey were not
> > > > > > > remembered.
> > > > > > Hmm. So, lets just revert 39fc0ce5710c53bad14aaba1a789eec81=
0c556f9
> > > > > > (net: Implement SFEATURES compatibility for not updated dri=
vers).
> > > > > That's also problematic because it means we can't make any us=
e of the
> > > > > 'available' masks from ETHTOOL_GFEATURES.
> > > > >=20
> > > > > The patch I sent is actually tested with a modified ethtool. =
 The
> > > > > fallback works.  I don't think you've tested whether any of y=
our
> > > > > proposals can actually practically be used by ethtool.
> > > >=20
> > > > While reading your patches I noted some differences in the way =
we see
> > > > the new [GS]FEATURES ops.
> > > >=20
> > > > First, you make NETIF_F_* flags part of the ethtool ABI. In my =
approach
> > > > feature names become an ABI instead. That's what ETH_SS_FEATURE=
S string
> > > > set is for, and that's what comments in kernel's <linux/ethtool=
=2Eh>
> > > > include say.
> > >=20
> > > We've been through this before.  I can't use those names in ethto=
ol
> > > because they aren't the same as ethtool used previously.  I could=
 make
> > > it map strings to strings, but I don't see the point.
> > >=20
> > > > dev->features are exposed directly by kernel only in two ways:
> > > >  1. /sys/class/net/*/features - since NETIF_F_* flags are not e=
xported
> > > >     in headers for userspace, this should be treated like a deb=
ugging
> > > >     facility and not an ABI
> > > >  2. ETHTOOL_[GS]FLAGS - these export 5 flags (LRO, VLAN offload=
, NTuple,
> > > >     and RX hashing) that are renamed to ETH_FLAG_* - only those=
 constants
> > > >     are in the ABI and only in relation with ETHTOOL_[GS]FLAGS
> > > >=20
> > > > Second, you reimplement 'ethtool -K' using ETHTOOL_SFEATURES. D=
oes this mean
> > > > that we want to get rid of ETHTOOL_[GS]{FLAGS,SG,...} from kern=
el?
> > > We must not.
> >=20
> > So what's the point in reimplementing old options via ETHTOOL_SFEAT=
URES?
>=20
> Where, in ethtool?  The benefits include:
> - Kernel remembers all the features the user wants on, even if the
> combination is impossible.  Turning TX checksumming off and on no lon=
ger
> forces TSO off.

This is what you get by using old ethtool on new kernel. And only for
converted drivers, whether using SFEATURES or old calls.

> - ethtool can distinguish and report whether a feature is unsupported=
 or
> its dependencies are not met.

In this case, when feature is unsupported at all, you still get -EOPNOT=
SUPP.
If you get no error from old call but after readback (via GSG, etc.) th=
e
feature is still disabled - it means that there are some unmet dependen=
cies.
This is the same information you get from [GS]FEATURES calls.

> > > > The
> > > > assumptions in those calls are a bit different from ETHTOOL_[GS=
]FEATURES
> > > > but there is an conversion layer in kernel that allows old bina=
ries to
> > > > work correctly in the common case. (-EOPNOTSUPP is still return=
ed for
> > > > drivers which can't change particular feature. The difference i=
s seen
> > > > only in that disabling and enabling e.g. checksumming won't dis=
able other
> > > > dependent features in the result.)
> > > >=20
> > > > Right now we already agree that NETIF_F_COMPAT should go.
> > > >=20
> > > > I'll send my idea of the ethtool code using ETHTOOL_[GS]FEATURE=
S and
> > > > keeping NETIF_F_* flags internal to the kernel. It adds new mod=
es (-w/-W).
> > > > This might be made even more useful by adding simple wildcard m=
atching.
> > > I've explained before that I do not want to add new options to do
> > > (mostly) the same thing.  Users should have not have to use a dif=
ferent
> > > command depending on the kernel version.
> >=20
> > We can avoid new option by checking feature-strings for unrecognise=
d
> > arguments to -K. This way, we will have the old options which work
> > regardless of kernel version ('tx', 'rx', 'sg', etc.) and new optio=
ns
> > which need recent kernel anyway (separated 'tx-checksum-*', 'loopba=
ck',
> > others coming in for 2.6.40).
> This is just too subtle a distinction.  It will mostly confuse users.

We should just document the difference. I expect users who don't care a=
bout
new features to not read docs. So 'tx' will still mean 'all TX checksum=
ming'
for them, and they will expect it to turn all TX checksumming
offloads driver supports. If the set changes (like: even in earlier ker=
nels,
some drivers add NETIF_F_SCTP_CSUM to this set) you'll need to update
ethtool userspace. That won't happen if you keep using old calls for
old options as the change will be contained in kernel-side wrapper.

> > Also, this way fallbacks in userspace are avoided.
> No, ethtool will be supporting kernels <2.6.40 for many years yet.

Sure it will. I meant no fallbacks for old options (because they aren't
needed for the tool to work correctly) and no fallback for new options
(as that is not supported in old kernels anyway).

Best Regards,
Micha=B3 Miros=B3aw
