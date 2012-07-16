From: Timo Teras <timo.teras@iki.fi>
Subject: Re: iptables CLAMP MSS to PMTU not working?
Date: Mon, 16 Jul 2012 10:55:46 +0300
Message-ID: <20120716105546.14a6490d@vostro>
References: <20120712120021.3dc5cd68@vostro>
	<20120712132419.50b4acaf@vostro>
	<20120716084946.67b91a69@vostro>
	<20120716092058.270f6008@vostro>
	<20120716072305.GJ1869@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50742 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568Ab2GPH4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 03:56:07 -0400
Received: by eekc13 with SMTP id c13so62380eek.19
        for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 00:56:05 -0700 (PDT)
In-Reply-To: <20120716072305.GJ1869@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Jul 2012 09:23:05 +0200 Steffen Klassert
<steffen.klassert@secunet.com> wrote:

> On Mon, Jul 16, 2012 at 09:20:58AM +0300, Timo Teras wrote:
> > On Mon, 16 Jul 2012 08:49:46 +0300 Timo Teras <timo.teras@iki.fi>
> > wrote:
> > 
> > > Looking at the changelog, this would likely be side effect of:
> > > 
> > > commit 261663b0ee2ee8e3947f4c11c1a08be18cd2cea1
> > > Author: Steffen Klassert <steffen.klassert@secunet.com>
> > > Date:   Wed Nov 23 02:14:50 2011 +0000
> > > 
> > >     ipv4: Don't use the cached pmtu informations for input routes
> > > 
> > > At least from performance side, it would be better if CLAMPMSS to
> > > PMTU would clamp to the learned, cached mtu.
> > 
> > Actually, this is worse. Since XFRM is ignored - it breaks
> > fragmentation for IPsec targets.
> > 
> > Could this be reverted?
> 
> I did this patch to avoid to propagate learned PMTU informations.
> It restores the behaviour we had before we moved the PMTU informations
> to the inetpeer. Unfortunately CLAMPMSS really wants to have the PMTU
> informations of an input route, which is not possible any more after
> this patch.
>
> Anyway, this patch seems to be obsolete in the net-next tree, as
> the cached pmtu informations are back in the route. So we should
> remove the check for an output route from ipv4_mtu() in the net-next
> tree. This should bring CLAMPMSS back to work, at least for upcoming
> kernel versions.

Right, saw those commits. But before net-next hits release, I'd really
need a fix for 3.3/3.4/3.5. Non-working fragmentation with IPsec, and
this CLAMPMSS thingy are an upgrade stopper for me.

Would it be safe to just revert this commit, with the side-effect of
exposing cached pmtu too agressively?

Or would it be better to try to backport the relevant changes of moving
pmtu back to route table?
