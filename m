From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/5] netfilter: add nf_ipv6_ops hook to fix xt_addrtype
 with IPv6
Date: Mon, 3 Jun 2013 00:06:45 +0200
Message-ID: <20130602220645.GA14760@breakpoint.cc>
References: <1369843394-24251-1-git-send-email-pablo@netfilter.org>
 <1369843394-24251-2-git-send-email-pablo@netfilter.org>
 <CAKD1Yr3aauNq0NAi1-RDxcD_D5GDwzO87WxUARhyh=iQe91A5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAKD1Yr3aauNq0NAi1-RDxcD_D5GDwzO87WxUARhyh=iQe91A5Q@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lorenzo Colitti <lorenzo@google.com> wrote:
> > While the former might seem preferable, Pablo pointed out that there
> > are more xt modules with link-time dependeny issues regarding ipv6,
> > so lets go for 2).
> 
> I had to do this recently for the ping socket as well:
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=6d0bfe22611602f36617bc7aa2ffa1bbb2f54c67
>
> +/* Compatibility glue so we can support IPv6 when it's compiled as a module */
> +struct pingv6_ops {
> [...]
> + int (*ipv6_chk_addr)(struct net *net, const struct in6_addr *addr,
> +     struct net_device *dev, int strict);
> +};
>
> Is it a better idea to share these structures and have just one
> structure containing all IPv6 dummy functions?

I think so, yes.

> If it was in an include
> file, it would be easily accessible to most of the tree even when
> CONFIG_IPV6={n,m}, and we could have the ipv6 module init (and exit)
> code just set all the function pointers. That way, we wouldn't have to
> reinvent this particular wheel in multiple places of the code.

FWIW, I agree.  We should avoid having multiple copies of this.
