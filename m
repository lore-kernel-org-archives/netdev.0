From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Mon, 14 May 2007 14:51:18 +0200
Message-ID: <20070514125118.GA3382@ff.dom.local>
References: <20070511.140309.59656886.davem@davemloft.net> <20070511141225.cf7a6909.akpm@linux-foundation.org> <20070514060700.GA1000@ff.dom.local> <20070513.233937.99203647.davem@davemloft.net> <20070514072845.GA2081@ff.dom.local> <20070514080829.GB2081@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	jura@netams.com, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:38166 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752203AbXENMor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 08:44:47 -0400
Content-Disposition: inline
In-Reply-To: <20070514080829.GB2081@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2007 at 10:08:29AM +0200, Jarek Poplawski wrote:
> On Mon, May 14, 2007 at 09:28:45AM +0200, Jarek Poplawski wrote:
> > On Sun, May 13, 2007 at 11:39:37PM -0700, David Miller wrote:
> ...
> > > For each unique netdev type, use a different locking class.
> > > 
> > > That will fix this forever, anything else is a situation specific
> > > band-aid (but then again isn't that what every lockdep annotation is
> > > :-).
...
> > Yes, this is very good idea, and I wonder, why you didn't try
> > this yourself (after my "ignore"). I thought a little about
> > this, but was afraid of it's wide range. Some things - like
> > in vlans - should be removed then, for this to work. I'll try
> > to send something like this soon (but I'm not so optimistic
> > it will cure all or forever...).
> 
> So, because of this next planned patch (I hope not later than
> tomorrow), my two last patches for vlan and ppp_generic shouldn't 
> be applied - their functionality will be moved to register_netdevice.

...or maybe not so easy... Here is the first problem: vlan does
register_netdevice(new_dev) with new_dev->type == real_dev->type,
so it still couldn't be recognized as something different from
the real ppp or eth. We need some trick... Probably we could
also think about using dev->name (or both), but there always would
be a problem with the size of a static table reserved for this.

So, now it seems something like my patch with lockdep class for ppp
could be settled with this, but more complex situations like vlan
still need special treatment.

Maybe we should also care not to go too far with this: I didn't read
other such reports recently, but here the problems seem to be made
mainly by some virtual devices without queues...

Jarek P.
