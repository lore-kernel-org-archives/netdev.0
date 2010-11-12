From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] NET: sunrpc, remove unneeded NULL tests
Date: Fri, 12 Nov 2010 14:14:33 -0500
Message-ID: <20101112191433.GC32745@fieldses.org>
References: <1288180325-20009-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <trond-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
To: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1288180325-20009-1-git-send-email-jslaby-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sorry for the slow response, this one's for Trond if it hasn't already
been handled.

--b.

On Wed, Oct 27, 2010 at 01:52:05PM +0200, Jiri Slaby wrote:
> Stanse found that req in xprt_reserve_xprt is dereferenced prior its
> test to NULL. If that's the case, the checks are unnecessary, so
> remove them.
> 
> The alternative is not to dereference it before the test. The patch
> is to point out the problem, you have to decide.
> 
> Signed-off-by: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
> Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> Cc: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
> Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  net/sunrpc/xprt.c |    8 +++-----
>  1 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 4c8f18a..5355c71 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -202,10 +202,8 @@ int xprt_reserve_xprt(struct rpc_task *task)
>  		goto out_sleep;
>  	}
>  	xprt->snd_task = task;
> -	if (req) {
> -		req->rq_bytes_sent = 0;
> -		req->rq_ntrans++;
> -	}
> +	req->rq_bytes_sent = 0;
> +	req->rq_ntrans++;
>  	return 1;
>  
>  out_sleep:
> @@ -213,7 +211,7 @@ out_sleep:
>  			task->tk_pid, xprt);
>  	task->tk_timeout = 0;
>  	task->tk_status = -EAGAIN;
> -	if (req && req->rq_ntrans)
> +	if (req->rq_ntrans)
>  		rpc_sleep_on(&xprt->resend, task, NULL);
>  	else
>  		rpc_sleep_on(&xprt->sending, task, NULL);
> -- 
> 1.7.3.1
> 
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
