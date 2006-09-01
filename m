From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] change netfilter tunables to __read_mostly
Date: Fri, 01 Sep 2006 18:37:40 +0200
Message-ID: <44F861D4.9050208@trash.net>
References: <44F85276.1020804@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34762 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750823AbWIAQkN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 12:40:13 -0400
To: Brian Haley <brian.haley@hp.com>
In-Reply-To: <44F85276.1020804@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian Haley wrote:
> Change some netfilter tunables to __read_mostly.  Also fixed some
> incorrect file reference comments while I was in there.

Please send these kind of patches for netfilter to me so I can
make sure they don't clash with other pending patches.

> (this will be my last __read_mostly patch unless someone points out
> something else that needs it)

This seems to be a bit random, there are quite a few more candidates for
__read_mostly right next to the ones you marked.

> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 8f22619..3b64dbe 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -77,12 +77,12 @@ LIST_HEAD(nf_conntrack_expect_list);
>  struct nf_conntrack_protocol **nf_ct_protos[PF_MAX];

Like this one

>  struct nf_conntrack_l3proto *nf_ct_l3protos[PF_MAX];

and this one

>  static LIST_HEAD(helpers);

and this one

> -unsigned int nf_conntrack_htable_size = 0;
> -int nf_conntrack_max;
> +unsigned int nf_conntrack_htable_size __read_mostly = 0;
> +int nf_conntrack_max __read_mostly;
>  struct list_head *nf_conntrack_hash;

and this one

>  static kmem_cache_t *nf_conntrack_expect_cachep;

and this one

>  struct nf_conn nf_conntrack_untracked;
> -unsigned int nf_ct_log_invalid;
> +unsigned int nf_ct_log_invalid __read_mostly;
>  static LIST_HEAD(unconfirmed);
>
>  static int nf_conntrack_vmalloc;

and this one

Same ones in ip_conntrack.

>  /* Log invalid packets of a given protocol */
> diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
> index 276a964..80060cb 100644
> --- a/net/ipv4/netfilter/ip_queue.c
> +++ b/net/ipv4/netfilter/ip_queue.c
> @@ -53,7 +53,7 @@ struct ipq_queue_entry {
>  typedef int (*ipq_cmpfn)(struct ipq_queue_entry *, unsigned long);
>  
>  static unsigned char copy_mode = IPQ_COPY_NONE;
> -static unsigned int queue_maxlen = IPQ_QMAX_DEFAULT;
> +static unsigned int queue_maxlen __read_mostly = IPQ_QMAX_DEFAULT;
>  static DEFINE_RWLOCK(queue_lock);
>  static int peer_pid;
>  static unsigned int copy_range;

Basically all these variables besides the lock are candidates.

