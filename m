From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 1/5] page allocator: Always wake kswapd when restarting an
	allocation attempt after direct reclaim failed
Date: Thu, 22 Oct 2009 17:41:53 +0300
Message-ID: <84144f020910220741o51c7e3dajcfd7b78d6dbbc4eb@mail.gmail.com>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
	 <1256221356-26049-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>,
	Sven Geggus <lists@fuchsschwanzdomain.de>,
	Karol Lewandowski <karol.k.lewandowski@gmail.com>,
	Tobias Oetiker <tobi@oetiker.ch>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	David Miller <davem@davemloft.net>,
	Reinette Chatre <reinette.chatre@intel.com>,
	Kalle Valo <kalle.valo@iki.fi>,
	David Rientjes <rientjes@google.com>,
	KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
	Mohamed Abbas <mohamed.abbas@intel.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Stephan von Krawczynski <skraw@ithnet.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"linux-mm@kvack.org\"" <linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756442AbZJVOlv@vger.kernel.org>
In-Reply-To: <1256221356-26049-2-git-send-email-mel@csn.ul.ie>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2009 at 5:22 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> If a direct reclaim makes no forward progress, it considers whether i=
t
> should go OOM or not. Whether OOM is triggered or not, it may retry t=
he
> application afterwards. In times past, this would always wake kswapd =
as well
> but currently, kswapd is not woken up after direct reclaim fails. For=
 order-0
> allocations, this makes little difference but if there is a heavy mix=
 of
> higher-order allocations that direct reclaim is failing for, it might=
 mean
> that kswapd is not rewoken for higher orders as much as it did previo=
usly.
>
> This patch wakes up kswapd when an allocation is being retried after =
a direct
> reclaim failure. It would be expected that kswapd is already awake, b=
ut
> this has the effect of telling kswapd to reclaim at the higher order =
as well.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

You seem to have dropped the Reviewed-by tags from me and Christoph
for this patch.

> =A0mm/page_alloc.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index bf72055..dfa4362 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1817,9 +1817,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned=
 int order,
> =A0 =A0 =A0 =A0if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) =3D=3D GFP=
_THISNODE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto nopage;
>
> +restart:
> =A0 =A0 =A0 =A0wake_all_kswapd(order, zonelist, high_zoneidx);
>
> -restart:
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * OK, we're below the kswapd watermark and have kicke=
d background
> =A0 =A0 =A0 =A0 * reclaim. Now things get more complex, so set up all=
oc_flags according
> --
> 1.6.3.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
