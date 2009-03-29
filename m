From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for March 27 (netfilter build error)
Date: Sat, 28 Mar 2009 21:26:42 -0700
Message-ID: <49CEF882.5000005@oracle.com>
References: <20090327231924.4e4168c5.sfr@canb.auug.org.au> <49CD0368.2010805@oracle.com> <20090327.160107.184169637.davem@davemloft.net> <20090328102852.GA7697@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, davem@davemloft.net,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net, netfilter-devel@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090328102852.GA7697@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cyrill Gorcunov wrote:
> [David Miller - Fri, Mar 27, 2009 at 04:01:07PM -0700]
> | From: Randy Dunlap <randy.dunlap@oracle.com>
> | Date: Fri, 27 Mar 2009 09:48:40 -0700
> | 
> | > Stephen Rothwell wrote:
> | > > Hi all,
> | > > 
> | > > Changes since 20090326:
> | > 
> | > 
> | > with CONFIG_IPV6=n:
> | > 
> | > ERROR: "__ipv6_addr_type" [net/netfilter/xt_cluster.ko] undefined!
> | > 
> | > config attached.
> | 
> | Patrick and netfilter folks, please have a look, thanks!
> | 
> 
> Pablo, seems like something as inlined below is
> missed? (except I doubt about CONFIG_IPV6_MODULE
> here)
> 
>         Cyrill

works_for_me.  Thanks.
but missing S-O-B.

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>


> ---
>  net/netfilter/xt_cluster.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> Index: linux-2.6.git/net/netfilter/xt_cluster.c
> ===================================================================
> --- linux-2.6.git.orig/net/netfilter/xt_cluster.c
> +++ linux-2.6.git/net/netfilter/xt_cluster.c
> @@ -67,8 +67,10 @@ xt_cluster_is_multicast_addr(const struc
>  		is_multicast = ipv4_is_multicast(ip_hdr(skb)->daddr);
>  		break;
>  	case NFPROTO_IPV6:
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>  		is_multicast = ipv6_addr_type(&ipv6_hdr(skb)->daddr) &
>  						IPV6_ADDR_MULTICAST;
> +#endif
>  		break;
>  	default:
>  		WARN_ON(1);


-- 
~Randy
