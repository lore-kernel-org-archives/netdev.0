From: jamal <hadi@cyberus.ca>
Subject: RE: [RFC] make qdisc_restart more readable
Date: Fri, 11 May 2007 14:35:59 -0400
Message-ID: <1178908559.4126.19.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902D424F4@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:48124 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758519AbXEKSgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 14:36:02 -0400
Received: by wx-out-0506.google.com with SMTP id h31so959955wxd
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 11:36:01 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902D424F4@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-11-05 at 11:13 -0700, Waskiewicz Jr, Peter P wrote:

> After thinking about this a bit more: even if the queue is stopped,
> you'd end up requeueing anyways.  Plus, you'd need to re-acquire
> dev->queue_lock (which is what happens today).  I think the best way
> overall would be to check the queue state before you physically dequeue
> (whether it's in qdisc_restart() or in the qdisc's ->dequeue()).

For lockless drivers, I think it could be moved up; only thing is
nothing is stopping it from changing again at transmit time.
For drivers that are not lockless, i am wondering if its even useful
to have that check given we have already grabbed the tx lock.

>   That
> way you still hold dev->queue_lock in case the queue is stopped, and
> haven't yet pulled an skb causing a requeue event.

It certainly sounds like a useful optimization. Defer that thought - for
now i just want to make sure its doing what the previous code did.

I will repost the fixed patch later today after some testing; if you
have time i will appreciate some eyeballing. That piece of code is
hairy. Hopefully we can make it bald.

cheers,
jamal


