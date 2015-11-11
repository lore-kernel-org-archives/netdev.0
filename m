From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: fix xt_TEE and xt_TPROXY dependencies
Date: Wed, 11 Nov 2015 14:19:00 +0100
Message-ID: <20151111131900.GB6079@salvia>
References: <8068952.JJURCanWFy@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8068952.JJURCanWFy@wuerfel>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 10, 2015 at 01:22:15PM +0100, Arnd Bergmann wrote:
> Kconfig is too smart for its own good: a Kconfig line that states
> 
> 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
> 
> means that if IP6_NF_IPTABLES is set to 'm', then NF_DEFRAG_IPV6 will
> also be set to 'm', regardless of the state of the symbol from which
> it is selected. When the xt_TEE driver is built-in and nothing else
> forces NF_DEFRAG_IPV6 to be built-in, this causes a link-time error:
> 
> net/built-in.o: In function `tee_tg6':
> net/netfilter/xt_TEE.c:46: undefined reference to `nf_dup_ipv6'
> 
> This works around that behavior by changing the dependency to
> 'if IP6_NF_IPTABLES != n', which is interpreted as boolean expression
> rather than a tristate and causes the NF_DEFRAG_IPV6 symbol to
> be built-in as well.
> 
> The bug only occurs once in thousands of 'randconfig' builds and
> does not really impact real users. From inspecting the other
> surrounding Kconfig symbols, I am guessing that NETFILTER_XT_TARGET_TPROXY
> and NETFILTER_XT_MATCH_SOCKET have the same issue. If not, this
> change should still be harmless.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> I have done a few thousand randconfig builds with this applied, and the
> problem did not come back, but it is super-rare.
> 
> Several people have tried to fix this in the past, but so far
> every patch was wrong. Maybe this one is lucky.

Also applied, thanks Arnd!
