From: Matt Mackall <mpm@selenic.com>
Subject: Re: Reproducible panics with tulip
Date: Fri, 18 Mar 2005 19:13:21 -0800
Message-ID: <20050319031321.GA25554@waste.org>
References: <1111178167.1147.9.camel@localhost.localdomain> <20050318215229.GA24509@electric-eye.fr.zoreil.com> <20050318223939.GB24509@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Nyberg <alexn@dsv.su.se>, jgarzik@pobox.com, netdev@oss.sgi.com,
        davem@davemloft.net
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050318223939.GB24509@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 18, 2005 at 11:39:39PM +0100, Francois Romieu wrote:
> 
> zap_completion_queue can be called in any context through netpoll_send_udp.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> 
> diff -puN net/core/netpoll.c~netconsole-000 net/core/netpoll.c
> --- a/net/core/netpoll.c~netconsole-000	2005-03-18 23:29:28.499641348 +0100
> +++ b/net/core/netpoll.c	2005-03-18 23:33:13.856959994 +0100
> @@ -142,7 +142,7 @@ static void zap_completion_queue(void)
>  		while (clist != NULL) {
>  			struct sk_buff *skb = clist;
>  			clist = clist->next;
> -			__kfree_skb(skb);
> +			dev_kfree_skb_any(skb);
>  		}
>  	}

Please, cc: me on such things. I sent this fix a while back, but DaveM
never acked it.

-- 
Mathematics is the supreme nostalgia of our time.
