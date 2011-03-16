From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] netfilter: get rid of atomic ops in fast path
Date: Wed, 16 Mar 2011 13:16:48 -0700 (PDT)
Message-ID: <20110316.131648.15245216.davem@davemloft.net>
References: <1300302005.3202.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, hawk@diku.dk
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300302005.3202.23.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Mar 2011 20:00:05 +0100

> We currently use a percpu spinlock to 'protect' rule bytes/packets
> counters, after various attempts to use RCU instead.
> 
> Lately we added a seqlock so that get_counters() can run without
> blocking BH or 'writers'. But we really use the seqcount in it.
> 
> Spinlock itself is only locked by the current cpu, so we can remove it
> completely.
> 
> This cleanups api, using correct 'writer' vs 'reader' semantic.
> 
> At replace time, the get_counters() call makes sure all cpus are done
> using the old table.
> 
> We could probably avoid blocking BH (we currently block them in xmit
> path), but thats a different topic ;)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

FWIW, I think this is a great idea.
