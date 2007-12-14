From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Fri, 14 Dec 2007 15:11:36 -0800
Message-ID: <20071214151136.ae0f969b.akpm@linux-foundation.org>
References: <E1J35d6-00041l-00@gondolin.me.apana.org.au>
	<20071214002209.ac748206.akpm@linux-foundation.org>
	<20071214083037.GA15602@gondor.apana.org.au>
	<20071214.111514.03773174.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42799 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1765845AbXLNXMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 18:12:46 -0500
In-Reply-To: <20071214.111514.03773174.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2007 11:15:14 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 14 Dec 2007 16:30:37 +0800
> 
> > On Fri, Dec 14, 2007 at 12:22:09AM -0800, Andrew Morton wrote:
> > >
> > > I don't see how it could warn about that.  Nor should it - one might want
> > > to check that rtnl_lock is held inside preempt_disable() or spin_lock or
> > > whatever.
> > > 
> > > It might make sense to warn if ASSERT_RTNL is called in in_interrupt()
> > > contexts though.
> > 
> > Well the paths where ASSERT_RTNL is used should never be in an
> > atomic context.  In the past it has been quite useful in pointing
> > out bogus locking practices.
> > 
> > There is currently one path where it's known to warn because of
> > this and it (promiscuous mode) is on my todo list.
> > 
> > Oh and it only warns when you have mutex debugging enabled.
> 
> Right, this change is just totally bogus.
> 
> I'm all for using existing facilities to replace hand-crafted copies,
> but this case is removing useful debugging functionality so it's
> wrong.

I don't believe that ASSERT_RTNL() presently warns when called from atomic
contexts.  If it does then I missed it.

