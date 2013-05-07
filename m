From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen-netback: remove dead code
Date: Tue, 7 May 2013 11:00:48 +0100
Message-ID: <1367920848.26321.66.camel@zakaz.uk.xensource.com>
References: <1367854820-4129-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:10494 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354Ab3EGKAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 06:00:52 -0400
In-Reply-To: <1367854820-4129-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-05-06 at 16:40 +0100, Wei Liu wrote:
> The array mmap_pages is never touched in the initialization function. This is
> remnant of mapping mechanism, which does exist upstream.
                                         ^not

Can you add a quick note about to the changelog about where this array
is now initialised and freed please, with that:

> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>

Please resubmit when Dave opens net-next for new development.

Ian.

> ---
>  drivers/net/xen-netback/netback.c |    4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 37984e6..295a9c2 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1939,10 +1939,6 @@ static int __init netback_init(void)
>  failed_init:
>  	while (--group >= 0) {
>  		struct xen_netbk *netbk = &xen_netbk[group];
> -		for (i = 0; i < MAX_PENDING_REQS; i++) {
> -			if (netbk->mmap_pages[i])
> -				__free_page(netbk->mmap_pages[i]);
> -		}
>  		del_timer(&netbk->net_timer);
>  		kthread_stop(netbk->task);
>  	}
