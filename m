From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 net-next-2.6] netfilter: x_tables: dont block BH
 while reading counters
Date: Thu, 16 Dec 2010 09:57:09 -0800
Message-ID: <20101216095709.18f16c53@nehalam>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	<1292340702.5934.5.camel@edumazet-laptop>
	<1292342958.9155.91.camel@firesoul.comx.local>
	<1292343855.5934.27.camel@edumazet-laptop>
	<1292508266.31289.12.camel@firesoul.comx.local>
	<1292508733.2883.152.camel@edumazet-laptop>
	<1292509489.31289.20.camel@firesoul.comx.local>
	<1292509775.2883.187.camel@edumazet-laptop>
	<1292511761.2883.236.camel@edumazet-laptop>
	<1292515625.2883.336.camel@edumazet-laptop>
	<1292518436.2883.393.camel@edumazet-laptop>
	<20101216093149.71f082c7@nehalam>
	<1292521986.2883.472.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	Patrick McHardy <kaber@trash.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Steven Rostedt <srostedt@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292521986.2883.472.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Dec 2010 18:53:06 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> @@ -759,7 +742,7 @@ static struct xt_counters *alloc_counters(const struct xt_table *table)
>  	 * about).
>  	 */
>  	countersize = sizeof(struct xt_counters) * private->number;
> -	counters = vmalloc(countersize);
> +	counters = vzalloc(countersize);
>  
>  	if (counters == NULL)
>  		return ERR_PTR(-ENOMEM);
> @@ -1007,7 +990,7 @@ static int __do_replace(struct net *net, const char *name,
>  	struct arpt_entry *iter;
>  
>  	ret = 0;
> -	counters = vmalloc(num_counters * sizeof(struct xt_counters));
> +	counters = vzalloc(num_counters * sizeof(struct xt_counters));
>  	if (!counters) {
>  		ret = -ENOMEM;
>  		goto out;

This seems like a different and unrelated change.

-- 
