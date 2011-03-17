From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] netfilter: get rid of atomic ops in fast path
Date: Thu, 17 Mar 2011 11:39:01 +0100
Message-ID: <4D81E4C5.5060009@trash.net>
References: <1300302005.3202.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300302005.3202.23.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 16.03.2011 20:00, schrieb Eric Dumazet:
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
> ---
> This is a POC patch (based on net-next-2.6), only handling ip_tables.
> ip6/arp/... need similar changes.

Thanks Eric, this looks good to me.
