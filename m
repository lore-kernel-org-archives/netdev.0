From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RFC 2/3] net_sched: Add accessor function for packet length
 for qdiscs
Date: Thu, 17 Jul 2008 12:11:30 +0200
Message-ID: <487F1AD2.10208@trash.net>
References: <20080717100921.3327.3324.stgit@fate.lan> <20080717100933.3327.20158.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51317 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755046AbYGQKLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 06:11:34 -0400
In-Reply-To: <20080717100933.3327.20158.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> ---
> 
>  include/net/sch_generic.h |   17 +++++++++++------
>  net/sched/sch_atm.c       |    4 ++--
>  net/sched/sch_cbq.c       |   14 ++++++--------
>  net/sched/sch_dsmark.c    |    2 +-
>  net/sched/sch_fifo.c      |    2 +-
>  net/sched/sch_gred.c      |   12 ++++++------
>  net/sched/sch_hfsc.c      |   14 ++++++--------
>  net/sched/sch_htb.c       |    9 +++++----
>  net/sched/sch_netem.c     |    6 +++---
>  net/sched/sch_prio.c      |    2 +-
>  net/sched/sch_red.c       |    2 +-
>  net/sched/sch_sfq.c       |   16 ++++++++--------
>  net/sched/sch_tbf.c       |    9 ++++++---
>  net/sched/sch_teql.c      |    6 +++---
>  14 files changed, 60 insertions(+), 55 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index e3b0d71..1f1de3b 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -258,6 +258,11 @@ static inline bool qdisc_tx_is_noop(const struct net_device *dev)
>  	return (txq->qdisc == &noop_qdisc);
>  }
>  
> +static inline unsigned int qdisc_tx_len(struct sk_buff *skb)
> +{
> +	return skb->len;
> +}


Just one question - should this also be useable for ingress? If so
a different name would make sense.
