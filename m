From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Wed, 23 Jul 2008 12:58:16 +0200
Message-ID: <1216810696.7257.175.camel@twins>
References: <20080722.160409.216536011.davem@davemloft.net>
	 <20080723062036.GA4561@ff.dom.local>
	 <20080723.005921.113868915.davem@davemloft.net>
	 <20080723085452.GB4561@ff.dom.local> <1216803786.7257.146.camel@twins>
	 <20080723093459.GC4561@ff.dom.local> <1216806614.7257.152.camel@twins>
	 <20080723101352.GD4561@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	kaber@trash.net, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	mingo@redhat.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:58169 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbYGWK6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 06:58:16 -0400
In-Reply-To: <20080723101352.GD4561@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-23 at 10:13 +0000, Jarek Poplawski wrote:
> On Wed, Jul 23, 2008 at 11:50:14AM +0200, Peter Zijlstra wrote:
> ....
> > definite NAK on using raw spinlock ops...
> > 
> > I'll go look at this multiqueue stuff to see if there is anything to be
> > done.. David, what would be a good commit to start reading?
> 
> ....In the case David ever sleeps: I think, the current Linus' git is
> good enough (the problem is with netdevice.h: netif_tx_lock()).

Ah, right,...

that takes a whole bunch of locks at once..

Is that really needed? - when I grep for its usage its surprisingly few
drivers using it and even less generic code.

When I look at the mac802.11 code in ieee80211_tx_pending() it looks
like it can do with just one lock at a time, instead of all - but I
might be missing some obvious details.

So I guess my question is, is netif_tx_lock() here to stay, or is the
right fix to convert all those drivers to use __netif_tx_lock() which
locks only a single queue?

