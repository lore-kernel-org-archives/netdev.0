From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH 3/3] qdisc: catch misconfig of attaching qdisc
 to tx_queue_len zero device
Date: Fri, 4 Nov 2016 10:35:26 +0100
Message-ID: <20161104093526.GM5640@orbyte.nwl.cc>
References: <20161103135534.28737.37657.stgit@firesoul>
 <20161103135611.28737.39840.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53423 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752736AbcKDJf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 05:35:28 -0400
Content-Disposition: inline
In-Reply-To: <20161103135611.28737.39840.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Nov 03, 2016 at 02:56:11PM +0100, Jesper Dangaard Brouer wrote:
[...]
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 206dc24add3a..f337f1bdd1d4 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -960,6 +960,17 @@ static struct Qdisc *qdisc_create(struct net_device *dev,
>  
>  	sch->handle = handle;
>  
> +	/* This exist to keep backward compatible with a userspace
> +	 * loophole, what allowed userspace to get IFF_NO_QUEUE
> +	 * facility on older kernels by setting tx_queue_len=0 (prior
> +	 * to qdisc init), and then forgot to reinit tx_queue_len
> +	 * before again attaching a qdisc.
> +	 */
> +	if ((dev->priv_flags & IFF_NO_QUEUE) && (dev->tx_queue_len == 0)) {
> +		dev->tx_queue_len = DEFAULT_TX_QUEUE_LEN;
> +		netdev_info(dev, "Caught tx_queue_len zero misconfig\n");
> +	}

I wonder why this is limited to IFF_NO_QUEUE devices. Do you think there
is a valid use case for physical ones?

Also, if we sanitize here, couldn't we then just get rid of the
sanitization you're fixing in patch 2?

Apart from that, ACK to all the patches. Thanks for cleaning up my mess!
:)

Cheers, Phil
