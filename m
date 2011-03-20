From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] netfilter: get rid of atomic ops in fast path
Date: Sun, 20 Mar 2011 15:41:32 +0100
Message-ID: <4D86121C.7050503@trash.net>
References: <1300468038.2888.160.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300468038.2888.160.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 18.03.2011 18:07, schrieb Eric Dumazet:
> We currently use a percpu spinlock to 'protect' rule bytes/packets
> counters, after various attempts to use RCU instead.
> 
> Lately we added a seqlock so that get_counters() can run without
> blocking BH or 'writers'. But we really use the seqcount in it.
> 
> Spinlock itself is only locked by the current/owner cpu, so we can
> remove it completely.
> 
> This cleanups api, using correct 'writer' vs 'reader' semantic.
> 
> At replace time, the get_counters() call makes sure all cpus are done
> using the old table.

I think this will have to wait until net-next opens up again since
its not a bugfix.
