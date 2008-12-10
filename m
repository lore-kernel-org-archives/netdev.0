From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] replace deprecated RW_LOCK_UNLOCKED in
 net/dccp/proto.c
Date: Wed, 10 Dec 2008 14:00:44 -0500 (EST)
Message-ID: <alpine.DEB.1.10.0812101359030.11805@gandalf.stny.rr.com>
References: <alpine.DEB.1.10.0812101314460.11805@gandalf.stny.rr.com> <49400B7F.7040607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:64861 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756863AbYLJTAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 14:00:47 -0500
In-Reply-To: <49400B7F.7040607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 10 Dec 2008, Eric Dumazet wrote:

> cced netdev

Thanks,

> 
> Steven Rostedt a ?crit :
> >  
> >  struct inet_hashinfo __cacheline_aligned dccp_hashinfo = {
> > -	.lhash_lock	= RW_LOCK_UNLOCKED,
> > +	.lhash_lock	= __RW_LOCK_UNLOCKED(dccp_hashinfo.lhash_lock),
> >  	.lhash_users	= ATOMIC_INIT(0),
> >  	.lhash_wait = __WAIT_QUEUE_HEAD_INITIALIZER(dccp_hashinfo.lhash_wait),
> >  };
> > --
> 
> Hum... this rwlock doesnt exist anymore on net-next-2.6, all this stuff
> was converted to RCU for upcoming 2.6.29
> 
> struct inet_hashinfo dccp_hashinfo;
> EXPORT_SYMBOL_GPL(dccp_hashinfo);
> 
> I guess such a patch wont ease David job when 2.6.29 merge window opens

One of the requirements in the new rt git tree is that all rwlocks must 
use the __RW_LOCK_UNLOCK(lock) macro. I had to fix it in our tree, but 
whenever I do a clean up patch, I like to share it ;-)

-- Steve

