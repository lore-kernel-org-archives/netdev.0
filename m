From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] fib_trie: rescan if key is lost during dump
Date: Fri, 25 Jan 2008 08:13:15 -0800
Message-ID: <20080125081315.467fad70@deepthought>
References: <20080124135112.32b5c1c7@deepthought>
	<20080125082300.GA2257@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35949 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752439AbYAYQNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 11:13:40 -0500
In-Reply-To: <20080125082300.GA2257@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Jan 2008 09:23:00 +0100
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On 24-01-2008 22:51, Stephen Hemminger wrote:
> > Normally during a dump the key of the last dumped entry is used for
> > continuation, but since lock is dropped it might be lost. In that case
> > fallback to the old counter based N^2 behaviour.  This means the dump will end up
> > skipping some routes which matches what FIB_HASH does.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ...
> > @@ -1918,35 +1931,37 @@ static int fn_trie_dump(struct fib_table
> >  	struct leaf *l;
> >  	struct trie *t = (struct trie *) tb->tb_data;
> >  	t_key key = cb->args[2];
> > +	int count = cb->args[3];
> >  
> >  	rcu_read_lock();
> 
> Sorry, but I lost the point: is rtnl held or not held here at the moment?
> If held, how this rcu_read_lock can help? Maybe some additional comment
> in the code?
> 
> Thanks,
> Jarek P.

There are two different issues, (therefore two different patches).
1. How to handle multipart resume when the key was deleted during the
   period the lock was dropped.

   That is what this patch addresses.

2. RCU is unnecessary here because of use of RTNL.  I am going to defer
   on this till after #1. That patch is much less important.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
