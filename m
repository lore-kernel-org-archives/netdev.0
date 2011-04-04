From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] netfilter: get rid of atomic ops in fast
 path
Date: Mon, 04 Apr 2011 17:05:04 +0200
Message-ID: <4D99DE20.2060404@trash.net>
References: <1300468038.2888.160.camel@edumazet-laptop> <1301836523.2837.159.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1301836523.2837.159.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03.04.2011 15:15, Eric Dumazet wrote:
> We currently use a percpu spinlock to 'protect' rule bytes/packets
> counters, after various attempts to use RCU instead.
> 
> Lately we added a seqlock so that get_counters() can run without
> blocking BH or 'writers'. But we really only need the seqcount in it.
> 
> Spinlock itself is only locked by the current/owner cpu, so we can
> remove it completely.
> 
> This cleanups api, using correct 'writer' vs 'reader' semantic.
> 
> At replace time, the get_counters() call makes sure all cpus are done
> using the old table.

Applied, thanks Eric.
