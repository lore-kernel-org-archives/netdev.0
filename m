From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] SUNRPC/cache: add module_put() on error path in
 cache_open()
Date: Wed, 3 Apr 2013 15:32:53 -0400
Message-ID: <20130403193253.GK6044@fieldses.org>
References: <1363984604-17739-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org
To: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1363984604-17739-1-git-send-email-khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks, applying.--b.

On Sat, Mar 23, 2013 at 12:36:44AM +0400, Alexey Khoroshilov wrote:
> If kmalloc() fails in cache_open(), module cd->owner left locked.
> The patch adds module_put(cd->owner) on this path.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
> ---
>  net/sunrpc/cache.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 25d58e76..1d3c514 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -986,8 +986,10 @@ static int cache_open(struct inode *inode, struct file *filp,
>  	nonseekable_open(inode, filp);
>  	if (filp->f_mode & FMODE_READ) {
>  		rp = kmalloc(sizeof(*rp), GFP_KERNEL);
> -		if (!rp)
> +		if (!rp) {
> +			module_put(cd->owner);
>  			return -ENOMEM;
> +		}
>  		rp->offset = 0;
>  		rp->q.reader = 1;
>  		atomic_inc(&cd->readers);
> -- 
> 1.7.9.5
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
