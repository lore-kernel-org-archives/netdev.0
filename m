From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [patch] xen-netback: double free on unload
Date: Fri, 21 Jun 2013 10:51:01 +0100
Message-ID: <20130621095101.GA14648@zion.uk.xensource.com>
References: <20130621062008.GA10873@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <ian.campbell@citrix.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>, <wei.liu2@citrix.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:9858 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750730Ab3FUJvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jun 2013 05:51:04 -0400
Content-Disposition: inline
In-Reply-To: <20130621062008.GA10873@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 21, 2013 at 09:20:08AM +0300, Dan Carpenter wrote:
> There is a typo here, "i" vs "j", so we would crash on module_exit().
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index a0b50ad..130bcb2 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1968,8 +1968,8 @@ static void __exit netback_fini(void)
>  		del_timer_sync(&netbk->net_timer);
>  		kthread_stop(netbk->task);
>  		for (j = 0; j < MAX_PENDING_REQS; j++) {
> -			if (netbk->mmap_pages[i])
> -				__free_page(netbk->mmap_pages[i]);
> +			if (netbk->mmap_pages[j])
> +				__free_page(netbk->mmap_pages[j]);

Nice catch, thanks.


Wei.
