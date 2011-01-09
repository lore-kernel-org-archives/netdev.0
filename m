From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net_sched: factorize qdisc stats handling
Date: Sun, 9 Jan 2011 09:57:35 -0800
Message-ID: <20110109095735.5241e755@nehalam>
References: <20110106195614.20dbc402@nehalam>
	<AANLkTi=pqZ3CwLTAZnhd-cyQNj8OSeBHsP_bFiH3hJ-_@mail.gmail.com>
	<20110107200234.3f5e7ff8@nehalam>
	<1294478789.2709.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	netdev@vger.kernel.org, Luigi Rizzo <rizzo@iet.unipi.it>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42377 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895Ab1AIR5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jan 2011 12:57:37 -0500
In-Reply-To: <1294478789.2709.79.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 08 Jan 2011 10:26:29 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> +static inline void bstats_update(struct gnet_stats_basic_packed *bstats,
> +				 struct sk_buff *skb)
> +{
> +	bstats->bytes += qdisc_pkt_len(skb);
> +	bstats->packets += skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 1;
> +}
> +
> +static inline void qdisc_bstats_update(struct Qdisc *sch, struct sk_buff *skb)
>  {
> -	sch->bstats.bytes += len;
> -	sch->bstats.packets++;
> +	bstats_update(&sch->bstats, skb);
>  }

Minor nit. I prefer to show that skb is not modified.

static inline void bstats_update(struct gnet_stats_basic_packed *bstats,
				 const struct sk_buff *skb)

static inline void qdisc_bstats_update(struct Qdisc *sch, const struct sk_buff *skb)

-- 
