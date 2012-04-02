From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: check the length of the data before dereferencing
 it
Date: Mon, 02 Apr 2012 05:19:33 +0200
Message-ID: <1333336773.2325.6531.camel@edumazet-glaptop>
References: <1333336250-4110-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1333336250-4110-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-04-02 at 11:10 +0800, Changli Gao wrote:
> We should check the length of the data before dereferencing it when parsing
> the TCP options.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/ipv4/tcp_input.c |    2 ++
>  1 file changed, 2 insertions(+)
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index e886e2f..5099f08 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3845,6 +3845,8 @@ void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *o
>  			length--;
>  			continue;
>  		default:
> +			if (length < 2)
> +				return;
>  			opsize = *ptr++;
>  			if (opsize < 2) /* "silly options" */
>  				return;

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


