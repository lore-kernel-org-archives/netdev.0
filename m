From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/6] SUNPRC: cleanup RPC PipeFS pipes upcall interface
Date: Sun, 25 Dec 2011 14:17:57 +0100
Message-ID: <1324819077.5195.5.camel@lade.trondhjem.org>
References: <20111122134514.479.9848.stgit@localhost6.localdomain6>
	 <20111122144159.479.68045.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111122144159.479.68045.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-11-22 at 18:41 +0300, Stanislav Kinsbursky wrote: 
> RPC pipe upcall doesn't requires only private pipe data. Thus RPC inode
> references in this code can be removed.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> 
> ---
>  fs/nfs/blocklayout/blocklayoutdev.c |    2 +-
>  fs/nfs/blocklayout/blocklayoutdm.c  |    2 +-
>  fs/nfs/idmap.c                      |    4 ++--
>  include/linux/sunrpc/rpc_pipe_fs.h  |    2 +-
>  net/sunrpc/auth_gss/auth_gss.c      |    3 +--
>  net/sunrpc/rpc_pipe.c               |    3 +--
>  6 files changed, 7 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
> index a83b393..44dc348 100644
> --- a/fs/nfs/blocklayout/blocklayoutdev.c
> +++ b/fs/nfs/blocklayout/blocklayoutdev.c
> @@ -168,7 +168,7 @@ nfs4_blk_decode_device(struct nfs_server *server,
>  
>  	dprintk("%s CALLING USERSPACE DAEMON\n", __func__);
>  	add_wait_queue(&bl_wq, &wq);
> -	if (rpc_queue_upcall(bl_device_pipe->d_inode, &msg) < 0) {
> +	if (rpc_queue_upcall(RPC_I(bl_device_pipe->d_inode)->pipe, &msg) < 0) {

Needs a rebase: the above doesn't apply...

> 		remove_wait_queue(&bl_wq, &wq);
>  		goto out;
>  	}


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
