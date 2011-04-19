From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: xen-netback: convert to hw_features
Date: Tue, 19 Apr 2011 15:43:52 +0200
Message-ID: <20110419134352.GB4716@rere.qmqm.pl>
References: <20110419115612.C4ACA13909@rere.qmqm.pl> <1303219073.5997.191.camel@zakaz.uk.xensource.com> <20110419133019.GA3973@rere.qmqm.pl> <1303220340.5997.197.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:55282 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405Ab1DSNny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 09:43:54 -0400
Content-Disposition: inline
In-Reply-To: <1303220340.5997.197.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 19, 2011 at 02:39:00PM +0100, Ian Campbell wrote:
> On Tue, 2011-04-19 at 14:30 +0100, Micha=B3 Miros=B3aw wrote:
> > On Tue, Apr 19, 2011 at 02:17:53PM +0100, Ian Campbell wrote:
> > > I fixed it with the following, I also moved the !can_sg MTU clamp=
ing
> > > into a set_features hook (like we do with netfront). Am I right t=
hat
> > > this pattern copes with changes to SG via ethtool etc better? I t=
hink
> > > it's more future proof in any case.
> > This looks wrong. Even if SG is turned on, you might get big skbs w=
hich
> > are linearized. There is a difference in SG capability and SG offlo=
ad
> > status and as I see it the capability is what you need to test for =
MTU.
> So the existing stuff in drivers/net/xen-netfront.c is wrong too?

Looks like it. But I don't really know what are the real constraints fo=
r MTU.
What I know is that SG even if turned on needs not be used (and current=
ly
it's not e.g. if checksum offload is disabled). So MTU setting should n=
ot
depend on SG offload state but on some capability.

Best Regards,
Micha=B3 Miros=B3aw
