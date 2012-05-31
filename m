From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/3] bql: Avoid unneeded limit decrement.
Date: Thu, 31 May 2012 09:59:21 +0200
Message-ID: <1338451161.2760.1275.camel@edumazet-glaptop>
References: <20120531072519.16464513.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, therbert@google.com, denys@visp.net.lb,
	netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43346 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757764Ab2EaH7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 03:59:25 -0400
Received: by bkcji2 with SMTP id ji2so547476bkc.19
        for <netdev@vger.kernel.org>; Thu, 31 May 2012 00:59:24 -0700 (PDT)
In-Reply-To: <20120531072519.16464513.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-31 at 07:25 +0900, Hiroaki SHIMODA wrote:
...
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Denys Fedoryshchenko <denys@visp.net.lb>
> ---
>  lib/dynamic_queue_limits.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/dynamic_queue_limits.c b/lib/dynamic_queue_limits.c
> index c87eb76..0fafa77 100644
> --- a/lib/dynamic_queue_limits.c
> +++ b/lib/dynamic_queue_limits.c
> @@ -11,12 +11,14 @@
>  #include <linux/dynamic_queue_limits.h>
>  
>  #define POSDIFF(A, B) ((int)((A) - (B)) > 0 ? (A) - (B) : 0)
> +#define AFTER_EQ(A, B) ((int)((A) - (B)) >= 0)
>  
>  /* Records completed count and recalculates the queue limit */
>  void dql_completed(struct dql *dql, unsigned int count)
>  {
>  	unsigned int inprogress, prev_inprogress, limit;
> -	unsigned int ovlimit, all_prev_completed, completed;
> +	unsigned int ovlimit, completed;
> +	bool all_prev_completed;
>  
>  	/* Can't complete more than what's in queue */
>  	BUG_ON(count > dql->num_queued - dql->num_completed);
> @@ -26,7 +28,7 @@ void dql_completed(struct dql *dql, unsigned int count)
>  	ovlimit = POSDIFF(dql->num_queued - dql->num_completed, limit);
>  	inprogress = dql->num_queued - completed;
>  	prev_inprogress = dql->prev_num_queued - dql->num_completed;
> -	all_prev_completed = POSDIFF(completed, dql->prev_num_queued);
> +	all_prev_completed = AFTER_EQ(completed, dql->prev_num_queued);
>  
>  	if ((ovlimit && !inprogress) ||
>  	    (dql->prev_ovlimit && all_prev_completed)) {

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
