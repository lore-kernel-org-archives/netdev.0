From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 1/4] net: implement support
 for low latency socket polling
Date: Tue, 21 May 2013 07:35:38 -0700
Message-ID: <1369146938.3301.225.camel@edumazet-glaptop>
References: <20130521142641.18498.52856.stgit@ladj378.jer.intel.com>
	<20130521142650.18498.71715.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Don,
	Or Gerlitz <or.gerlitz@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	HPA <hpa@zytor.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Eilon Greenstien <eilong@broadcom.com>, Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20130521142650.18498.71715.stgit@ladj378.jer.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-21 at 17:26 +0300, Eliezer Tamir wrote:

> +/* should be called when destroying a napi struct */
> +static inline void inc_ll_gen_id(void)
> +{
> +	ll_global_gen_id++;
> +}
> +
> +static inline void skb_mark_ll(struct sk_buff *skb, struct napi_struct *napi)
> +{
> +	skb->dev_ref = napi;
> +	skb->ll_gen_id = SKB_LL_GEN(ll_global_gen_id);
> +}
> +
> +static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
> +{
> +	if (skb->dev_ref && skb->ll_gen_id == SKB_LL_GEN(ll_global_gen_id)) {
> +		sk->dev_ref = skb->dev_ref;
> +		sk->ll_gen_id = ll_global_gen_id;
> +	} else
> +		sk->dev_ref = NULL; /* clear expired ref */
> +}
> +

Thats really hacky.

Please dont rush sending a new patch set every day.




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
