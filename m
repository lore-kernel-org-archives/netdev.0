From: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [net-next 3/7] openvswitch: Enable memory mapped
	Netlink i/o
Date: Sat, 30 Nov 2013 13:35:49 +0100
Message-ID: <20131130123549.GH2067@breakpoint.cc>
References: <cover.1385813891.git.tgraf@suug.ch>
	<9f7f05a726935c434d43d92c2908a997c403725b.1385813891.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, fleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9f7f05a726935c434d43d92c2908a997c403725b.1385813891.git.tgraf-G/eBtMaohhA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org> wrote:
> Benchmark
>   * pktgen -> ovs internal port
>   * 5M pkts, 5M flows
>   * 4 threads, 8 cores
> 
> Before:
> Result: OK: 67418743(c67108212+d310530) usec, 5000000 (9000byte,0frags)
>   74163pps 5339Mb/sec (5339736000bps) errors: 0
[..]
> After:
> Result: OK: 24229690(c24127165+d102524) usec, 5000000 (9000byte,0frags)
>   206358pps 14857Mb/sec (14857776000bps) errors: 0

I'm curious.  Is the 'old' value with skb_zerocopy() or without?
Does ovs-vswitchd 'read-access' the entire packet or just e.g. the
header?

I ask because in netfilter nfqueue tests I could not see any difference
between 'zerocopy' vs. mmap in the receive-path tests I made a while
back.

[ I have no objections to your patch, of course ].
