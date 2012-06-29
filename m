From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fq_codel: report congestion
 notification at enqueue time
Date: Fri, 29 Jun 2012 00:53:57 -0700 (PDT)
Message-ID: <20120629.005357.1447732177584445832.davem@davemloft.net>
References: <1340947448.29822.41.camel@edumazet-glaptop>
	<20120628.222934.767995619021650710.davem@davemloft.net>
	<1340949008.29822.73.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nanditad@google.com, netdev@vger.kernel.org, codel@lists.bufferbloat.net,
	ycheng@google.com, ncardwell@google.com, mattmathis@google.com
To: eric.dumazet@gmail.com
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1340949008.29822.73.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jun 2012 07:50:08 +0200

> Hmm, problem is the sender thinks the packet was queued for
> transmission.
> 
>         ret = macvlan_queue_xmit(skb, dev);
>         if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
>                 struct macvlan_pcpu_stats *pcpu_stats;
> 
>                 pcpu_stats = this_cpu_ptr(vlan->pcpu_stats);
>                 u64_stats_update_begin(&pcpu_stats->syncp);
>                 pcpu_stats->tx_packets++;
>                 pcpu_stats->tx_bytes += len;
>                 u64_stats_update_end(&pcpu_stats->syncp);
>         } else {
>                 this_cpu_inc(vlan->pcpu_stats->tx_dropped);
>         }
> 
> NET_XMIT_CN has a lazy semantic it seems.
> 
> I will just dont rely on it.

I think we cannot just ignore this issue.  I will take a deeper look,
because we should have NET_XMIT_CN be very well defined and adjust any
mis-use.
