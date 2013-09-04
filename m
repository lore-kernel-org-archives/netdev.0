From: Florian Westphal <fw@strlen.de>
Subject: Re: linux-next: Tree for Sep 4 (netfilter: xt_TPROXY)
Date: Wed, 4 Sep 2013 23:09:40 +0200
Message-ID: <20130904210940.GP32493@breakpoint.cc>
References: <20130904181300.06fbf0698863cfaacf9fad9a@canb.auug.org.au>
 <52277212.5020006@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52277212.5020006@infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap <rdunlap@infradead.org> wrote:
> On 09/04/13 01:13, Stephen Rothwell wrote:
> > Hi all,
> > 
> > Please do not add any code for v3.13 to your linux-next included branches
> > until after v3.12-rc1 is released.
> > 
> > Changes since 20130902:
> > 
> 
> on x86_64:
> 
> when CONFIG_IPV6=m
> and CONFIG_NETFILTER_XT_TARGET_TPROXY=y:
> 
> net/built-in.o: In function `tproxy_tg6_v1':
> xt_TPROXY.c:(.text+0x5dc05): undefined reference to `udp6_lib_lookup'
> xt_TPROXY.c:(.text+0x5e32f): undefined reference to `udp6_lib_lookup'
> xt_TPROXY.c:(.text+0x5e432): undefined reference to `udp6_lib_lookup'
> net/built-in.o: In function `tproxy_tg_init':
> xt_TPROXY.c:(.init.text+0x1540): undefined reference to `nf_defrag_ipv6_enable'

Thanks for reporting.

I can reproduce same error with 3.10.6 stable tree, so its not
a recent problem.

As always, the tempting solution is to just forbid TPROXY=y with IPV6=m but
it would be better to get rid of the ipv6 link time deps..
