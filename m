From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 00:22:07 +0200
Message-ID: <20080817222207.GB2546@ami.dom.local>
References: <20080813.151918.61294677.davem@davemloft.net> <20080814112433.GA12476@ff.dom.local> <48A82ADE.5010903@gmail.com> <20080817.143444.252525600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:28250 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbYHQWVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 18:21:20 -0400
Received: by ug-out-1314.google.com with SMTP id c2so131273ugf.37
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2008 15:21:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080817.143444.252525600.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 02:34:44PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 17 Aug 2008 15:42:54 +0200
> 
> > Jarek Poplawski wrote, On 08/14/2008 01:24 PM:
> > 
> > > On Wed, Aug 13, 2008 at 03:19:18PM -0700, David Miller wrote:
> > > ...
> > >> Ok, so what I'm going to do is check in my patch and then try
> > >> to figure out how to resolve this "both bits clear" scenerio.
> > > 
> > > BTW, here is my older doubt revisited, where I hope to be re-considered/
> > > re-convinced, if possible...
> > 
> > 
> > After problems while testing this by Denys in another thread
> > I withdraw this patch.
> 
> Well, I knew it was completely wrong from the beginning, sorry
> to say :-)
> 
> This stuff can't be done outside of RCU, period.  I moved all of this
> work into RCU for a reason, I really meant it, and none of the reasons
> for that move have changed :-)
> 
> If we want to do it under RTNL we have to do something like schedule a
> workqueue from the RCU handler and then take the RTNL there.

Actually, I've only asked you to withdraw this patch for now, but I'm
still not convinced you're right. You should better show me first the
place where this can make a difference. (I think this test broke for
some other non RCU reason.) So, maybe you're right, but I've to check
this more.

BTW, I guess you've seen this other thread: "panic 2.6.27-rc3-git2,
qdisc_dequeue_head" where Denys and I fight with this new locking.
Alas, it looks to me as a real mess, and I currently try with this
previous idea of netdev_queue->qdisc_lock, which you didn't like too.
But, after looking at the current bugs shown by debugging I really 
think we'll have bugs here all the time without simplifying this.
I think my concept should work soon, but if you don't agree with
this at all we can stop and wait for better ideas.

Thanks,
Jarek P.



