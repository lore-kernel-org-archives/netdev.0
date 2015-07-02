From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 1/6] net: sched: extend percpu stats helpers
Date: Thu, 02 Jul 2015 08:19:45 -0700
Message-ID: <55955691.9070609@gmail.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:36725 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127AbbGBPTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 11:19:50 -0400
Received: by obdbs4 with SMTP id bs4so51791297obd.3
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 08:19:49 -0700 (PDT)
In-Reply-To: <1435842455-30501-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-02 06:07 AM, Eric Dumazet wrote:
> qdisc_bstats_update_cpu() and other helpers were added to support
> percpu stats for qdisc.
> 
> We want to add percpu stats for tc action, so this patch add common
> helpers.
> 
> qdisc_bstats_update_cpu() is renamed to qdisc_bstats_cpu_update()
> qdisc_qstats_drop_cpu() is renamed to qdisc_qstats_cpu_drop()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> ---

Acked-by: John Fastabend <john.r.fastabend@intel.com>

stupid nit below,

>  include/net/sch_generic.h | 27 +++++++++++++++++----------
>  net/core/dev.c            |  4 ++--
>  2 files changed, 19 insertions(+), 12 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 2738f6f87908..0cd49b21b211 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -513,17 +513,21 @@ static inline void bstats_update(struct gnet_stats_basic_packed *bstats,
>  	bstats->packets += skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 1;
>  }
>  
> -static inline void qdisc_bstats_update_cpu(struct Qdisc *sch,
> -					   const struct sk_buff *skb)
> +static inline void bstats_cpu_update(struct gnet_stats_basic_cpu *bstats,
> +				     const struct sk_buff *skb)
>  {
> -	struct gnet_stats_basic_cpu *bstats =
> -				this_cpu_ptr(sch->cpu_bstats);
> -
>  	u64_stats_update_begin(&bstats->syncp);
>  	bstats_update(&bstats->bstats, skb);
>  	u64_stats_update_end(&bstats->syncp);
>  }
>  
> +static inline void qdisc_bstats_cpu_update(struct Qdisc *sch,
> +					   const struct sk_buff *skb)
> +{
> +	bstats_cpu_update(this_cpu_ptr(sch->cpu_bstats), skb);
> +

spurious new line.

> +}
> +
