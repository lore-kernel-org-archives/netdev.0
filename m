From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Fri, 27 May 2011 17:28:10 +0200
Message-ID: <20110527152809.GA7620@rere.qmqm.pl>
References: <20110516.140958.625993829749556424.davem@davemloft.net>
 <20110519100331.GA25103@rere.qmqm.pl>
 <20110524091437.GA10779@rere.qmqm.pl>
 <20110524.153930.610330240390616957.davem@davemloft.net>
 <20110524215923.GA20138@rere.qmqm.pl>
 <1306505626.2759.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37784 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754112Ab1E0P2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 11:28:11 -0400
Content-Disposition: inline
In-Reply-To: <1306505626.2759.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2011 at 03:13:46PM +0100, Ben Hutchings wrote:
> On Tue, 2011-05-24 at 23:59 +0200, Micha=B3 Miros=B3aw wrote:
> > On Tue, May 24, 2011 at 03:39:30PM -0400, David Miller wrote:
> > > From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > > Date: Tue, 24 May 2011 11:14:37 +0200
> > > > On Thu, May 19, 2011 at 12:03:31PM +0200, Micha=B3 Miros=B3aw w=
rote:
> > > >> On Mon, May 16, 2011 at 02:09:58PM -0400, David Miller wrote:
> > > >> > You guys really need to sort this out properly.
> > > >> > Please resubmit whatever final solution is agreed upon.
> > > >> I noticed that v2.6.39 was tagged today. We should definitely =
remove
> > > >> NETIF_F_COMPAT so it won't bite us in the future. The other pa=
tch that
> > > >> fixes ethtool_ops->set_flags compatibility is a bugfix, so it =
should go
> > > >> in - if we decide that the SFEATURES compatibility should be r=
emoved
> > > >> it won't matter.
[...]
> > We could just wait for 2.6.40 and pretend this code part never exis=
ted. ;-)
> I think I will make ethtool check for a minimum kernel version of 2.6=
=2E40
> before using ETHTOOL_{G,S}FEATURES.

> > I'll rebase the first patch tomorrow. Without it the compatibility =
in
> > ETHTOOL_SFEATURES for non-converted drivers is busted wrt set_flags=
=2E
> This is an improvement, but I still think the fallback is fundamental=
ly
> broken - there's no good way for userland to tell what (if anything)
> went wrong when the return value has ETHTOOL_F_COMPAT set.

The same situation happens with ETHTOOL_F_WISH (userspace needs to rere=
ad
the features to find out what happened) and with old ETHTOOL_S{TSO,SG,.=
=2E.}
(those return success if any of the features in the group changes and a=
lso
posibly disable other features when one is disabled). This wasn't reall=
y
checked before.

Ben, I think I commented on your proposal of the userspace part, but I =
might
have missed some of your arguments about mine. Let's sum those up:

Your version:
   - reimplements ETHTOOL_Sxx via ETHTOOL_SFEATURES in userspace for ke=
rnels
     supporting the latter (note: ETHTOOL_S{SG,...} are not ever going =
away)
   - causes NETIF_F_* to be an ABI
   - does not support new features

My version:
   - implements only new features via ETHTOOL_SFEATURES (old calls are =
still used)
   - makes feature names an ABI (for scripts actually, not the tool)
   - supports any new features kernel reports without code changes

Both versions are rough at the edges, but working. Both assume that no
behaviour changes are to be made for old '-K' options.

Best Regards,
Micha=B3 Miros=B3aw
