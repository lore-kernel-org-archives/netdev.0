From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: reallocate new socket option number for
 IPV6_AUTOFLOWLABEL
Date: Thu, 7 Aug 2014 00:13:13 +0200
Message-ID: <20140806221313.GA4426@breakpoint.cc>
References: <1407363050-3573-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: therbert@google.com, netfilter-devel@vger.kernel.org,
	davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407363050-3573-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> cb1ce2e ("ipv6: Implement automatic flow label generation on transmit")
> accidentally uses socket option 64, which is already used by ip6tables:
> 
>  IP6T_SO_SET_REPLACE / IP6T_SO_GET_INFO               64
>  IP6T_SO_SET_ADD_COUNTERS / IP6T_SO_GET_ENTRIES       65
> 
> There is comment include/uapi/linux/in6.h warning about that.
> 
> Cc: Tom Herbert <therbert@google.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  include/uapi/linux/in6.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/in6.h b/include/uapi/linux/in6.h
> index 22b7a69..1d929c0 100644
> --- a/include/uapi/linux/in6.h
> +++ b/include/uapi/linux/in6.h
> @@ -233,7 +233,6 @@ struct in6_flowlabel_req {
>  #if 0	/* not yet */
>  #define IPV6_USE_MIN_MTU	63
>  #endif
> -#define IPV6_AUTOFLOWLABEL	64
>  
>  /*
>   * Netfilter (1)
> @@ -250,6 +249,7 @@ struct in6_flowlabel_req {
>   */
>  #define IPV6_RECVTCLASS		66
>  #define IPV6_TCLASS		67
> +#define IPV6_AUTOFLOWLABEL	68

This clashes with IP6T_SO_GET_REVISION_MATCH 8-}
