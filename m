From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next PATCH V3-evictor] net: frag evictor, avoid killing
 warm frag queues
Date: Thu, 6 Dec 2012 13:32:48 +0100
Message-ID: <20121206123248.GA24493@breakpoint.cc>
References: <1354319937.20109.285.camel@edumazet-glaptop>
 <20121204133007.20215.52566.stgit@dragon>
 <1354699462.20888.207.camel@localhost>
 <1354796760.20888.217.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52381 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423368Ab2LFMdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 07:33:04 -0500
Content-Disposition: inline
In-Reply-To: <1354796760.20888.217.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <jbrouer@redhat.com> wrote:
> CPUs are fighting for the same LRU head (inet_frag_queue) element,
> which is bad for scalability.  We could fix this by unlinking the
> element once a CPU graps it, but it would require us to change a
> read_lock to a write_lock, thus we might not gain much performance.
> 
> I already (implicit) fix this is a later patch, where I'm moving the
> LRU lists to be per CPU.  So, I don't know if it's worth fixing.

Do you think its worth trying to remove the lru list altogether and
just evict from the hash in a round-robin fashion instead?
