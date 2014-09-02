From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH 0/3] qdisc bulk dequeuing and utilizing delayed
 tailptr updates
Date: Tue, 2 Sep 2014 11:04:06 -0700
Message-ID: <CA+mtBx8JVqb0TXEOLimAv0hh_g5pfTRg08uNp2idcy=nWhk0_A@mail.gmail.com>
References: <20140902143254.1918.8419.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:40554 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbaIBSEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 14:04:07 -0400
Received: by mail-ie0-f175.google.com with SMTP id y20so8221891ier.34
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 11:04:06 -0700 (PDT)
In-Reply-To: <20140902143254.1918.8419.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 2, 2014 at 7:35 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> This patchset uses DaveM's recent API changes to dev_hard_start_xmit(),
> from the qdisc layer, to implement dequeue bulking.
>
> Open questions:
>
> - For now set bulk limit to 8 packets, don't want to stress the driver
>   avail ring_buffer space.
>
Please get limit from BQL also, see:
[PATCH net-next] net: Functions to report space available in device TX queues

> - We are not doing proper accounting for weight_p/quota in __qdisc_run(). Do we care?
>
> - Is the (!skb->next) check in dequeue necessary?
>
> - Do we need some checks in dev_requeue_skb() as we could be requeuing a SKB list?
>
>  - Should we rename dequeue_skb() to dequeue_skb_list() ?
>
>
> Based on top of:
>  commit 364a9e93243d ("sock: deduplicate errqueue dequeue")
>
> ---
>
> Jesper Dangaard Brouer (3):
>       qdisc: sysctl to adjust bulk dequeue limit
>       qdisc: bulk dequeue support for qdiscs with TCQ_F_ONETXQUEUE
>       qdisc: adjustments for API allowing skb list xmits
>
>
>  include/net/sch_generic.h  |    2 ++
>  net/core/sysctl_net_core.c |    9 +++++++++
>  net/sched/sch_generic.c    |   33 ++++++++++++++++++++++++++++-----
>  3 files changed, 39 insertions(+), 5 deletions(-)
>
> --
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
