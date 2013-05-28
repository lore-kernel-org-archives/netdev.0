From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 net-next 2/5] net: implement support
 for low latency socket polling
Date: Mon, 27 May 2013 17:26:21 -0700
Message-ID: <1369700781.3301.497.camel@edumazet-glaptop>
References: <20130527074351.29882.51106.stgit@ladj378.jer.intel.com>
	<20130527074411.29882.88391.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alex Rosenbaum <alexr@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>, Andi Kleen <andi@firstfloor.org>,
	Eilon Greenstien <eilong@broadcom.com>, Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130527074411.29882.88391.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-27 at 10:44 +0300, Eliezer Tamir wrote:

> diff --git a/include/net/sock.h b/include/net/sock.h
> index 66772cf..c7c3ea6 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -281,6 +281,7 @@ struct cg_proto;
>    *	@sk_error_report: callback to indicate errors (e.g. %MSG_ERRQUEUE)
>    *	@sk_backlog_rcv: callback to process the backlog
>    *	@sk_destruct: called at sock freeing time, i.e. when all refcnt == 0
> +  *	@sk_napi_id: id of the last napi context to receive data for sk
>   */
>  struct sock {
>  	/*
> @@ -399,6 +400,9 @@ struct sock {
>  	int			(*sk_backlog_rcv)(struct sock *sk,
>  						  struct sk_buff *skb);
>  	void                    (*sk_destruct)(struct sock *sk);
> +#ifdef CONFIG_NET_LL_RX_POLL
> +	unsigned int		sk_napi_id;
> +#endif
>  };

I believe this is a bad choice for data locality.

I would rather move it in the same cache line than sk_rxhash




------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
