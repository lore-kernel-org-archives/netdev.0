From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: don't do window scaling for a picked up
 connection
Date: Sun, 1 Apr 2012 18:21:55 +0200
Message-ID: <20120401162155.GA10861@1984>
References: <1333292683-31414-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1333292683-31414-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 01, 2012 at 11:04:43PM +0800, Changli Gao wrote:
> For a picked up connection, the window scaling option is also lost, because this
> option is only valid in SYN or SYN/ACK segments. We should remove the useless
> expression to save the CPU power.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/netfilter/nf_conntrack_proto_tcp.c |    1 -
>  1 file changed, 1 deletion(-)
> diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
> index 361eade..22f0500 100644
> --- a/net/netfilter/nf_conntrack_proto_tcp.c
> +++ b/net/netfilter/nf_conntrack_proto_tcp.c
> @@ -584,7 +584,6 @@ static bool tcp_in_window(const struct nf_conn *ct,
>  			 * Let's try to use the data from the packet.
>  			 */
>  			sender->td_end = end;
> -			win <<= sender->td_scale;

This breaks conntrackd and its ability to recover flows by injecting
the window scaling via ctnetlink.
