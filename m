From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] page allocator: Always wake kswapd when restarting
 an allocation attempt after direct reclaim failed
Date: Mon, 26 Oct 2009 00:10:25 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.0910260005500.15361@chino.kir.corp.google.com>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-2-git-send-email-mel@csn.ul.ie> <20091026100019.2F4A.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Mel Gorman <mel@csn.ul.ie>, Frans Pop <elendil@planet.nl>,
        Jiri Kosina <jkosina@suse.cz>,
        Sven Geggus <lists@fuchsschwanzdomain.de>,
        Karol Lewandowski <karol.k.lewandowski@gmail.com>,
        Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        David Miller <davem@davemloft.net>,
        Reinette Chatre <reinette.chatre@intel.com>,
        Kalle Valo <kalle.valo@iki.fi>,
        Mohamed Abbas <mohamed.abbas@intel.com>,
        Jens Axboe <jens.axboe@oracle.com>,
        "John W. Linville" <linville@tuxdriver.com>,
        Pekka Enberg <penberg@cs.helsinki.fi>,
        Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
        Greg Kroah-Hartman <gregkh@suse.de>,
        Stephan von Krawczynski <skraw@ithnet.com>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20091026100019.2F4A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Oct 2009, KOSAKI Motohiro wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bf72055..5a27896 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1899,6 +1899,12 @@ rebalance:
>  	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
>  		/* Wait for some write requests to complete then retry */
>  		congestion_wait(BLK_RW_ASYNC, HZ/50);
> +
> +		/*
> +		 * While we wait congestion wait, Amount of free memory can
> +		 * be changed dramatically. Thus, we kick kswapd again.
> +		 */
> +		wake_all_kswapd(order, zonelist, high_zoneidx);
>  		goto rebalance;
>  	}
>  

We're blocking to finish writeback of the directly reclaimed memory, why 
do we need to wake kswapd afterwards?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
