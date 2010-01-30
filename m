From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Fri, 29 Jan 2010 20:59:37 -0500
Message-ID: <1264816777.2793.510.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1264816634.2793.505.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-01-29 at 20:57 -0500, Jon Masters wrote:

> Ah so I should have realized before but I wasn't looking at valid values
> for the range of the hashtable yet, nf_conntrack_htable_size is getting
> wildly out of whack. It goes from:
> 
> (gdb) print nf_conntrack_hash_rnd
> $1 = 2688505299
> (gdb) print nf_conntrack_htable_size
> $2 = 16384
> 
> nf_conntrack_events: 1
> nf_conntrack_max: 65536
> 
> Shortly after booting, before being NULLed shortly after starting some
> virtual machines (the hash isn't reset, whereas it is recomputed if the
> hashtable is re-initialized after an intentional resizing operation):

I mean the *seed* isn't changed, so I don't think it was resized
intentionally. I wonder where else htable_size is fiddled with.

Jon.


