From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
 implementation & Netlink protocol
Date: Tue, 03 Mar 2009 14:16:12 -0800 (PST)
Message-ID: <20090303.141612.160287111.davem@davemloft.net>
References: <20090303170435.GE1480@hmsreliant.think-freely.org>
	<20090303181909.GA29236@ioremap.net>
	<20090303192107.GJ1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40057
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761860AbZCCWQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:16:30 -0500
In-Reply-To: <20090303192107.GJ1480@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 3 Mar 2009 14:21:07 -0500

> On Tue, Mar 03, 2009 at 09:19:09PM +0300, Evgeniy Polyakov wrote:
> > > +struct net_dm_config_msg {
> > > +	size_t entries;
> > > +	struct net_dm_config_entry options[0];
> > > +};
> > 
> > Isn't size_t have different size on different platforms?
> > 
> Probably, but we're only sending this data over netlink sockets, so despite the
> platform, I don't really see this as an issue.  About the only place for concern
> I think are cases like x86_64 and ppc64, in the event you have a 64 bit kernel
> and 32 bit user space, and in those the app can be adjusted to compensate for
> this.  I suppose I can fixate the size if its a real concern, but I don't think
> it really is.

Neil, that is _THE_ concern.  You have to use portable types that
will be both sized and aligned identically on both 32-bit and
64-bit variants of a given platform.

This means size_t is absolutely not usable.

We really don't have a clean way to add compat layer translators
for netlink, so you have to get this right from the beginning.
