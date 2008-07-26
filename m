From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Sat, 26 Jul 2008 12:53:08 +0200
Message-ID: <20080726105308.GA2524@ami.dom.local>
References: <20080725193416.GB3107@ami.dom.local> <1217014575.4758.7.camel@johannes.berg> <20080725200137.GC3107@ami.dom.local> <20080726.021846.236624483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@axxeo.de, peterz@infradead.org,
	Larry.Finger@lwfinger.net, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, mingo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.178]:57714 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbYGZKxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 06:53:20 -0400
Received: by ik-out-1112.google.com with SMTP id c28so3112758ika.5
        for <netdev@vger.kernel.org>; Sat, 26 Jul 2008 03:53:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080726.021846.236624483.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 26, 2008 at 02:18:46AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 25 Jul 2008 22:01:37 +0200
> 
> > On Fri, Jul 25, 2008 at 09:36:15PM +0200, Johannes Berg wrote:
> > > On Fri, 2008-07-25 at 21:34 +0200, Jarek Poplawski wrote:
> > > 
> > > No, we need to be able to lock out multiple TX paths at once.
> > 
> > IMHO, it can do the same. We could e.g. insert a locked spinlock into
> > this noop_tx_handler(), to give everyone some waiting.
> 
> I think there might be an easier way, but we may have
> to modify the state bits a little.

Yes, this looks definitely easier, but here is this one little bit
more, plus additional code to handle this in various places. Ingo's
proposal needs a (one?!) bit more thinking in one place, but it
shouldn't add even a bit to tx path (and it looks really cool!). Of
course, it could be re-considered in some other time too.

BTW, it seems with "Ingo's method" this netif_queue_stopped() check
could be removed too - the change of handlers could be done with
single qdiscs as well.

Jarek P.
