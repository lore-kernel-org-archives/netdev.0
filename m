From: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH 12/13] net/sunrpc/rpc_pipe.c: Remove unnecessary casts
 of private_data
Date: Thu, 23 Sep 2010 13:40:47 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1009231340301.26813@pobox.suse.cz>
References: <cover.1283650107.git.joe@perches.com> <dda96f0e94bd038179ae11dab4d73a7ab704276b.1283650107.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <dda96f0e94bd038179ae11dab4d73a7ab704276b.1283650107.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 4 Sep 2010, Joe Perches wrote:

> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> ---
>  net/sunrpc/rpc_pipe.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
> index 95ccbcf..1f7fc50 100644
> --- a/net/sunrpc/rpc_pipe.c
> +++ b/net/sunrpc/rpc_pipe.c
> @@ -204,7 +204,7 @@ rpc_pipe_release(struct inode *inode, struct file *filp)
>  	mutex_lock(&inode->i_mutex);
>  	if (rpci->ops == NULL)
>  		goto out;
> -	msg = (struct rpc_pipe_msg *)filp->private_data;
> +	msg = filp->private_data;
>  	if (msg != NULL) {
>  		spin_lock(&inode->i_lock);
>  		msg->errno = -EAGAIN;
> @@ -322,7 +322,7 @@ rpc_pipe_ioctl_unlocked(struct file *filp, unsigned int cmd, unsigned long arg)
>  		len = rpci->pipelen;
>  		if (filp->private_data) {
>  			struct rpc_pipe_msg *msg;
> -			msg = (struct rpc_pipe_msg *)filp->private_data;
> +			msg = filp->private_data;
>  			len += msg->len - msg->copied;
>  		}
>  		return put_user(len, (int __user *)arg);

Not present in linux-next as of today. Applying to trivial queue.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
