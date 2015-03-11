From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] netfilter: ipset: make ip_set_get_ip*_port to use
 skb_network_offset
Date: Wed, 11 Mar 2015 20:10:12 +0100 (CET)
Message-ID: <alpine.DEB.2.10.1503112009530.12147@blackhole.kfki.hu>
References: <1425638646-5906-1-git-send-email-al.drozdov@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexander Drozdov <al.drozdov@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425638646-5906-1-git-send-email-al.drozdov@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 6 Mar 2015, Alexander Drozdov wrote:

> All the ipset functions respect skb->network_header value,
> except for ip_set_get_ip4_port() & ip_set_get_ip6_port(). The
> functions should use skb_network_offset() to get the transport
> header offset.
> 
> Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>

Patch is applied, thanks.

Best regards,
Jozsef

> ---
>  net/netfilter/ipset/ip_set_getport.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/ipset/ip_set_getport.c b/net/netfilter/ipset/ip_set_getport.c
> index 29fb01d..1981f02 100644
> --- a/net/netfilter/ipset/ip_set_getport.c
> +++ b/net/netfilter/ipset/ip_set_getport.c
> @@ -98,7 +98,7 @@ ip_set_get_ip4_port(const struct sk_buff *skb, bool src,
>  		    __be16 *port, u8 *proto)
>  {
>  	const struct iphdr *iph = ip_hdr(skb);
> -	unsigned int protooff = ip_hdrlen(skb);
> +	unsigned int protooff = skb_network_offset(skb) + ip_hdrlen(skb);
>  	int protocol = iph->protocol;
>  
>  	/* See comments at tcp_match in ip_tables.c */
> @@ -135,7 +135,9 @@ ip_set_get_ip6_port(const struct sk_buff *skb, bool src,
>  	__be16 frag_off = 0;
>  
>  	nexthdr = ipv6_hdr(skb)->nexthdr;
> -	protoff = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr), &nexthdr,
> +	protoff = ipv6_skip_exthdr(skb,
> +				   skb_network_offset(skb) +
> +					sizeof(struct ipv6hdr), &nexthdr,
>  				   &frag_off);
>  	if (protoff < 0 || (frag_off & htons(~0x7)) != 0)
>  		return false;
> -- 
> 1.9.1
> 

-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
