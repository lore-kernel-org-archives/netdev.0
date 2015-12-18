From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ila: add NETFILTER dependency
Date: Fri, 18 Dec 2015 18:26:06 +0100
Message-ID: <20151218172606.GB1299@salvia>
References: <2011239.T7zzuZGeyk@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Tom Herbert <tom@herbertland.com>,
	netfilter-devel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2011239.T7zzuZGeyk@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 18, 2015 at 03:37:37PM +0100, Arnd Bergmann wrote:
> The recently added generic ILA translation facility fails to
> build when CONFIG_NETFILTER is disabled:
> 
> net/ipv6/ila/ila_xlat.c:229:20: warning: 'struct nf_hook_state' declared inside parameter list
> net/ipv6/ila/ila_xlat.c:235:27: error: array type has incomplete element type 'struct nf_hook_ops'
>  static struct nf_hook_ops ila_nf_hook_ops[] __read_mostly = {
> 
> This adds an explicit Kconfig dependency to avoid that case.

I'm afraid this extra Kconfig dependency that Arnd adds to fix this is
a symptom that there is something that doesn't belong there.

I overlook this new hook on priority -1, how does this integrate into
our infrastructure?

And mainly, isn't there any better way to integrate this into the
stack?

And why didn't you Cc netfilter-devel for code that involves
Netfilter?

We have to evaluate how this integrates into what we have, if it
breaks when it interacts with other components that we have.

I'm very sorry to say, but none of this has happened so far.
