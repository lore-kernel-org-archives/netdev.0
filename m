From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] ila: add NETFILTER dependency
Date: Fri, 18 Dec 2015 19:09:31 +0100
Message-ID: <20151218180931.GC29573@breakpoint.cc>
References: <2011239.T7zzuZGeyk@wuerfel>
 <20151218172606.GB1299@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Tom Herbert <tom@herbertland.com>,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151218172606.GB1299@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Fri, Dec 18, 2015 at 03:37:37PM +0100, Arnd Bergmann wrote:
> > The recently added generic ILA translation facility fails to
> > build when CONFIG_NETFILTER is disabled:
> > 
> > net/ipv6/ila/ila_xlat.c:229:20: warning: 'struct nf_hook_state' declared inside parameter list
> > net/ipv6/ila/ila_xlat.c:235:27: error: array type has incomplete element type 'struct nf_hook_ops'
> >  static struct nf_hook_ops ila_nf_hook_ops[] __read_mostly = {
> > 
> > This adds an explicit Kconfig dependency to avoid that case.
> 
> I'm afraid this extra Kconfig dependency that Arnd adds to fix this is
> a symptom that there is something that doesn't belong there.
> 
> I overlook this new hook on priority -1, how does this integrate into
> our infrastructure?

Looks problematic since address changes post ipv6 dnat translations,
its certainly unexpected for nft since we have magic address mangling
after -2 and 0 priroized tables...

However ... how is ILA supposed to work?

ila_xlat_outgoing has no callers, so it appears we only do this
stateless nat on ingress...?
