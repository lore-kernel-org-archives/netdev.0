From: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Subject: Re: [PATCH] SUNRPC: use jiffies_to_msecs for converting jiffies
Date: Thu, 12 Mar 2015 11:58:11 -0400
Message-ID: <1426175891.15787.2.camel@primarydata.com>
References: <1425374665-446-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425374665-446-1-git-send-email-hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-03-03 at 04:24 -0500, Nicholas Mc Guire wrote:
> Use jiffies_to_msecs for converting jiffies as it handles all of the corner
> cases reliably and also helps readability.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
> ---
> 
> This was only compile tested for x86_64_defconfig (implies CONFIG_SUNRPC=y)
> 
> Patch is against 4.0-rc1 (localversion-next is -next-20150303)
> 
>  net/sunrpc/sched.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index b91fd9c..c234e7f 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -90,7 +90,7 @@ __rpc_add_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
>  		return;
>  
>  	dprintk("RPC: %5u setting alarm for %lu ms\n",
> -			task->tk_pid, task->tk_timeout * 1000 / HZ);
> +			task->tk_pid, jiffies_to_msecs(task->tk_timeout));
>  
>  	task->u.tk_wait.expires = jiffies + task->tk_timeout;
>  	if (list_empty(&queue->timer_list.list) || time_before(task->u.tk_wait.expires, queue->timer_list.expires))

Thanks! Applied.
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org




--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
