From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] net: xen-netback: convert to hw_features
Date: Tue, 19 Apr 2011 16:15:48 +0100
Message-ID: <1303226148.5997.233.camel@zakaz.uk.xensource.com>
References: <20110419115612.C4ACA13909@rere.qmqm.pl>
	 <1303219073.5997.191.camel@zakaz.uk.xensource.com>
	 <20110419133019.GA3973@rere.qmqm.pl>
	 <1303220340.5997.197.camel@zakaz.uk.xensource.com>
	 <20110419134352.GB4716@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:6438 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205Ab1DSPPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 11:15:50 -0400
In-Reply-To: <20110419134352.GB4716@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-04-19 at 14:43 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> On Tue, Apr 19, 2011 at 02:39:00PM +0100, Ian Campbell wrote:
> > On Tue, 2011-04-19 at 14:30 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> > > On Tue, Apr 19, 2011 at 02:17:53PM +0100, Ian Campbell wrote:
> > > > I fixed it with the following, I also moved the !can_sg MTU cla=
mping
> > > > into a set_features hook (like we do with netfront). Am I right=
 that
> > > > this pattern copes with changes to SG via ethtool etc better? I=
 think
> > > > it's more future proof in any case.
> > > This looks wrong. Even if SG is turned on, you might get big skbs=
 which
> > > are linearized. There is a difference in SG capability and SG off=
load
> > > status and as I see it the capability is what you need to test fo=
r MTU.
> > So the existing stuff in drivers/net/xen-netfront.c is wrong too?
>=20
> Looks like it. But I don't really know what are the real constraints =
for MTU.
> What I know is that SG even if turned on needs not be used (and curre=
ntly
> it's not e.g. if checksum offload is disabled).

The interesting case is the opposite one, isn't it? IOW if NETIF_F_SG i=
s
disabled but the frontend/backend agree that they have the capability t=
o
handle >PAGE_SIZE skbs

In my experience, the normal reason for disabling the NETIF_F_SG offloa=
d
status is that the underlying capability is somehow buggy, otherwise is
there any reason to turn it off?

> So MTU setting should not depend on SG offload state but on some capa=
bility.

Ian.


