From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Mon, 14 May 2007 10:08:29 +0200
Message-ID: <20070514080829.GB2081@ff.dom.local>
References: <20070511.140309.59656886.davem@davemloft.net> <20070511141225.cf7a6909.akpm@linux-foundation.org> <20070514060700.GA1000@ff.dom.local> <20070513.233937.99203647.davem@davemloft.net> <20070514072845.GA2081@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	jura@netams.com, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:38541 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753575AbXENIB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 04:01:58 -0400
Content-Disposition: inline
In-Reply-To: <20070514072845.GA2081@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2007 at 09:28:45AM +0200, Jarek Poplawski wrote:
> On Sun, May 13, 2007 at 11:39:37PM -0700, David Miller wrote:
...
> > For each unique netdev type, use a different locking class.
> > 
> > That will fix this forever, anything else is a situation specific
> > band-aid (but then again isn't that what every lockdep annotation is
> > :-).

Band-aid isn't probably too fair with lockdep. I think, it's very
similar as declaring types of variables for a compiler, it really
can't know until we tell this. And current locks' complexity is
probably beyond possibility of brain analyzing, anyway. (Probably
lockdep could be wiser too - at the cost of memory and speed -
if each lock were treated individually).

> 
> Yes, this is very good idea, and I wonder, why you didn't try
> this yourself (after my "ignore"). I thought a little about
> this, but was afraid of it's wide range. Some things - like
> in vlans - should be removed then, for this to work. I'll try
> to send something like this soon (but I'm not so optimistic
> it will cure all or forever...).

So, because of this next planned patch (I hope not later than
tomorrow), my two last patches for vlan and ppp_generic shouldn't 
be applied - their functionality will be moved to register_netdevice.
(But I think this current: "nesting" patch for ppp_generic does
something different and IMHO could be useful too.)

Jarek P.
