From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Thu, 11 Jan 2007 12:09:02 +0100
Message-ID: <20070111110902.GA3561@ff.dom.local>
References: <20070111082958.GB1672@ff.dom.local> <20070111083526.GC1672@ff.dom.local> <20070111083934.GA2578@ff.dom.local> <20070111.012755.15271378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, greearb@candelatech.com,
	herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:39821 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030274AbXAKLHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 06:07:07 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20070111.012755.15271378.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 11, 2007 at 01:27:55AM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Thu, 11 Jan 2007 09:39:34 +0100
> 
> > Sure, but is this even legal to be preempted during
> > reading or modifying rcu list or be blocked while 
> > holding rcu protected pointer? Doesn't this disturb
> > rcu cycle and make possible memory release problems?
> 
> It's fine in this case.
> 
> Since the list cannot be changed by anyone else, and the hash linked
> list (as seen by readers) is modified atomically by a single store, it
> all works out.
> 
> Readers only look at foo->next in the hash traversal.  Since the
> preceeding element cannot change outside of the current writer,
> the ->next pointer to update is protected.
> 
> Readers therefore will either see the hash list with the entry or
> without.
> 
> We then use call_rcu() to make sure any reading threads that happened
> to get a glimpse of the hash entry before the hlist_del_rcu()
> completed will go away and drop their references before we free that
> entry.
> 
> I really don't see any problem here. :-)

Probably because you care more about internals and less 
about docs examples. It seems I'm too much about regulations. 
 
OK, I take your word and will try to stop annoy this list
with imagined RCU bugs, sorry.

Thanks for your precious (sleeping?) time
and explanations. Best regards,

Jarek P.
