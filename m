From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Thu, 15 Nov 2007 10:20:05 -0800
Message-ID: <20071115102005.0cf46f9a@freepuppy.rosehill>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>
	<20071115082600.GA2366@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S\. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58349 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765011AbXKOSWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 13:22:33 -0500
In-Reply-To: <20071115082600.GA2366@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 15 Nov 2007 09:26:00 +0100
Jarek Poplawski <jarkao2@o2.pl> wrote:

> On 15-11-2007 04:38, Stephen Hemminger wrote:
> > Simple mtu change when device is down.
> > Fix http://bugzilla.kernel.org/show_bug.cgi?id=9382.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> > 
> > 
> > --- a/drivers/net/via-velocity.c	2007-10-22 09:38:11.000000000 -0700
> > +++ b/drivers/net/via-velocity.c	2007-11-14 19:34:30.000000000 -0800
> > @@ -1963,6 +1963,11 @@ static int velocity_change_mtu(struct ne
> >  		return -EINVAL;
> >  	}
> >  
> > +	if (!netif_running(dev)) {
> > +		dev->mtu = new_mtu;
> > +		return 0;
> > +	}
> > +
> >  	if (new_mtu != oldmtu) {
> >  		spin_lock_irqsave(&vptr->lock, flags);
> 
> Shouldn't this latter 'if' be removed now, btw?

No, it makes sense that if mtu is same, no action need be taken.

Actually, it would make sense to push the same check up into
the netdevice core management.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
