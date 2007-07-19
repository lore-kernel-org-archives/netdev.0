From: Paul Clements <paul.clements@steeleye.com>
Subject: Re: [PATCH 1/2] nbd: use list_for_each_entry_safe to make it more
 consolidated and readable
Date: Thu, 19 Jul 2007 11:12:24 -0400
Message-ID: <469F7F58.4080709@steeleye.com>
References: <11848376711601-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pavel Machek <pavel@ucw.cz>,
	Steven Whitehouse <steve@chygwyn.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Denis Cheng <crquan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hancock.steeleye.com ([71.30.118.248]:39619 "EHLO
	hancock.sc.steeleye.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S938895AbXGSPMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 11:12:25 -0400
In-Reply-To: <11848376711601-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Cheng wrote:
> Thus the traverse of the loop may delete nodes, use the safe version.
> 
> Signed-off-by: Denis Cheng <crquan@gmail.com>
> ---
>  drivers/block/nbd.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
> index c129510..86639c0 100644
> --- a/drivers/block/nbd.c
> +++ b/drivers/block/nbd.c
> @@ -237,8 +237,7 @@ error_out:
>  
>  static struct request *nbd_find_request(struct nbd_device *lo, char *handle)
>  {
> -	struct request *req;
> -	struct list_head *tmp;
> +	struct request *req, *n;
>  	struct request *xreq;
>  	int err;
>  
> @@ -249,8 +248,7 @@ static struct request *nbd_find_request(struct nbd_device *lo, char *handle)
>  		goto out;
>  
>  	spin_lock(&lo->queue_lock);
> -	list_for_each(tmp, &lo->queue_head) {
> -		req = list_entry(tmp, struct request, queuelist);
> +	list_for_each_entry_safe(req, n, &lo->queue_head, queuelist) {
>  		if (req != xreq)
>  			continue;
>  		list_del_init(&req->queuelist);

Could you name "n" as "tmp" (as in the previous code) so that it's clear 
that's only a temporary variable. Other than that, this looks good.

Thanks,
Paul
