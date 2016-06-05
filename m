From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] net: wireless: marvell: libertas: Remove create_workqueue
Date: Sun, 5 Jun 2016 06:22:38 -0400
Message-ID: <20160605102238.GA31708@htj.duckdns.org>
References: <20160604135901.GA29897@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Andreas Kemnade <andreas-cLv4Z9ELZ06ZuzBka8ofvg@public.gmane.org>,
	Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"Andrew F. Davis" <afd-l0cyMroinI0@public.gmane.org>,
	Jonathan Cameron <jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160604135901.GA29897@Karyakshetra>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2016 at 07:29:01PM +0530, Bhaktipriya Shridhar wrote:
> alloc_workqueue replaces deprecated create_workqueue().
> 
> In if_sdio.c, the workqueue card->workqueue has workitem
> &card->packet_worker, which is mapped to if_sdio_host_to_card_worker.
> The workitem is involved in sending packets to firmware.
> Forward progress under memory pressure is a requirement here.
> 
> In if_spi.c, the workqueue card->workqueue has workitem
> &card->packet_worker, which is mapped to if_spi_host_to_card_worker.
> The workitem is involved in sending command packets from the host.
> Forward progress under memory pressure is a requirement here.
> 
> Dedicated workqueues have been used in both cases since the workitems
> on the workqueues are involved in normal device operation with
> WQ_MEM_RECLAIM set to gurantee forward progress under memory pressure.
> Since there are only a fixed number of work items, explicit concurrency
> limit is unnecessary.
> 
> flush_workqueue is unnecessary since destroy_workqueue() itself calls
> drain_workqueue() which flushes repeatedly till the workqueue
> becomes empty. Hence the calls to flush_workqueue() before
> destroy_workqueue() have been dropped.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Thanks.

-- 
tejun
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
