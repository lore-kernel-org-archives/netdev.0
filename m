From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Wed, 31 Jan 2007 01:16:29 +0900 (JST)
Message-ID: <20070131.011629.84005028.yoshfuji@linux-ipv6.org>
References: <20070129213013.GA26841@hmsreliant.homelinux.net>
	<20070130.072536.129403235.yoshfuji@linux-ipv6.org>
	<20070130130208.GA3723@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:47537 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096AbXA3QPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 11:15:14 -0500
In-Reply-To: <20070130130208.GA3723@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070130130208.GA3723@hmsreliant.homelinux.net> (at Tue, 30 Jan 2007 08:02:08 -0500), Neil Horman <nhorman@tuxdriver.com> says:

> > I do not think we should copy neighbor information from (one of)
> > default routers, but use temporary neigh entry (or neigh in new state)
> > for such datagrams in stead.  We should aware that:
> > 
> Not sure how that is different from what I'm proposing.  a neighbor entry that
> maps a given host on the current subnet to the MAC of the default router, that
> then gets flushed when DAD completes is temporary, as far as I can see.
> 
> >  1) default router's link-layer address may change.
> True, but if this changes, all our network connectivity is lost, until the
> normal neighbor solicitation process completes anyway.

No, router may update its link-layer address by NA with Override flag set.
In that case, we must use new link-layer for subsequent packets from
our opportunistic address duing DAD.

> >  2) we may have more than one default routers.
> True, but I would think we could select any of them and this would work.
> Granted, we wouldn't use all the default routers in the table as we would with
> routed frames, but I'm not sure how we avoid that.

I mean, if the status of the selected default router has changed or 
has been deleted, we should try other router, at least.

> >  3) the default router's link-layer may be invalidated.
> > 
> yes, but this would be bad for the same reason as (1)

We MUST take this into account.

--yoshfuji
