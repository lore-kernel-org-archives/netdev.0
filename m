From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Fri, 27 May 2011 18:34:09 +0200
Message-ID: <20110527163409.GA8497@rere.qmqm.pl>
References: <20110516.140958.625993829749556424.davem@davemloft.net>
 <20110519100331.GA25103@rere.qmqm.pl>
 <20110524091437.GA10779@rere.qmqm.pl>
 <20110524.153930.610330240390616957.davem@davemloft.net>
 <20110524215923.GA20138@rere.qmqm.pl>
 <1306505626.2759.4.camel@bwh-desktop>
 <20110527152809.GA7620@rere.qmqm.pl>
 <1306511150.2759.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50912 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774Ab1E0QeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 12:34:11 -0400
Content-Disposition: inline
In-Reply-To: <1306511150.2759.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2011 at 04:45:50PM +0100, Ben Hutchings wrote:
> On Fri, 2011-05-27 at 17:28 +0200, Micha=B3 Miros=B3aw wrote:
> > On Fri, May 27, 2011 at 03:13:46PM +0100, Ben Hutchings wrote:
> > > On Tue, 2011-05-24 at 23:59 +0200, Micha=B3 Miros=B3aw wrote:
> > > > On Tue, May 24, 2011 at 03:39:30PM -0400, David Miller wrote:
> > > > > From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > > > > Date: Tue, 24 May 2011 11:14:37 +0200
> > > > > > On Thu, May 19, 2011 at 12:03:31PM +0200, Micha=B3 Miros=B3=
aw wrote:
> > > > > >> On Mon, May 16, 2011 at 02:09:58PM -0400, David Miller wro=
te:
> > > > > >> > You guys really need to sort this out properly.
> > > > > >> > Please resubmit whatever final solution is agreed upon.
> > > > > >> I noticed that v2.6.39 was tagged today. We should definit=
ely remove
> > > > > >> NETIF_F_COMPAT so it won't bite us in the future. The othe=
r patch that
> > > > > >> fixes ethtool_ops->set_flags compatibility is a bugfix, so=
 it should go
> > > > > >> in - if we decide that the SFEATURES compatibility should =
be removed
> > > > > >> it won't matter.
> > [...]
> > > > We could just wait for 2.6.40 and pretend this code part never =
existed. ;-)
> > > I think I will make ethtool check for a minimum kernel version of=
 2.6.40
> > > before using ETHTOOL_{G,S}FEATURES.
> >=20
> > > > I'll rebase the first patch tomorrow. Without it the compatibil=
ity in
> > > > ETHTOOL_SFEATURES for non-converted drivers is busted wrt set_f=
lags.
> > > This is an improvement, but I still think the fallback is fundame=
ntally
> > > broken - there's no good way for userland to tell what (if anythi=
ng)
> > > went wrong when the return value has ETHTOOL_F_COMPAT set.
> >=20
> > The same situation happens with ETHTOOL_F_WISH (userspace needs to =
reread
> > the features to find out what happened) and with old ETHTOOL_S{TSO,=
SG,...}
> > (those return success if any of the features in the group changes a=
nd also
> > posibly disable other features when one is disabled). This wasn't r=
eally
> > checked before.
> >=20
> > Ben, I think I commented on your proposal of the userspace part, bu=
t I might
> > have missed some of your arguments about mine. Let's sum those up:
> >=20
> > Your version:
> >    - reimplements ETHTOOL_Sxx via ETHTOOL_SFEATURES in userspace fo=
r kernels
> >      supporting the latter
> No, it implements 'ethtool -K' using ETHTOOL_SFEATURES.  Maybe you
> consider the ethtool utility to be a thin wrapper over the ethtool AP=
I,
> but that is not my intent.

You're right. I assumed just that. -K and other modes of operation look
like they are adapting the ETHTOOL_* calls for human consumption.
There's some additional code for analysing register and other dumps,
but I see it as just merging two tools for convenience.

> >      (note: ETHTOOL_S{SG,...} are not ever going away)
> >    - causes NETIF_F_* to be an ABI
> If feature flag numbers are not stable then what is the point of
> /sys/class/net/<name>/features?  Also, I'm not aware that features ha=
ve
> ever been renumbered in the past.

Since no NETIF_F_* were exported earlier, I assume /sys/class/net/*/fea=
tures
is a debugging aid. What is it used for besides that?

[...]
> > Both versions are rough at the edges, but working. Both assume that=
 no
> > behaviour changes are to be made for old '-K' options.
> No, my changes are intended to enhance the old options.

Kernel side already enhances them to not forget other features
'wanted' state. What other enhancements are on your mind?

BTW, I just recalled that ETHTOOL_F_WISH is set only as an information
about bits in features[].valid masks. So zero return does not mean, tha=
t
other features (not in .valid masks) haven't changed. This means that
userspace needs to reread features after any SFEATURES call, not just
those returning non-zero.

Best Regards,
Micha=B3 Miros=B3aw
