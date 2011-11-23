From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 0/6] SUNRPC: make RPC clients use
 network-namespace-aware PipeFS routines
Date: Wed, 23 Nov 2011 11:27:11 -0500
Message-ID: <20111123162711.GA30672@fieldses.org>
References: <20111123104945.11077.10270.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111123104945.11077.10270.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2011 at 02:51:10PM +0300, Stanislav Kinsbursky wrote:
> This patch set was created in context of clone of git
> branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
> tag: v3.1
> 
> This patch set depends on previous patch sets titled:
> 1) "SUNRPC: initial part of making pipefs work in net ns"
> 2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"

Do you have a git tree set up with all of these applied?

(If I want to take a quick look it would personally be easier for me to
fetch your git tree than to get those patches out of old email.)

--b.

> 
> This patch set is a first part of reworking SUNPRC PipeFS users.
> It makes SUNRPC clients using PipeFS nofitications for directory and GSS pipes
> dentries creation. With this patch set RPC clients and GSS auth creations
> routines doesn't force SUNRPC PipeFS mount point creation which actually means,
> that they now can work without PipeFS dentries.
> 
> The following series consists of:
> 
> ---
> 
> Stanislav Kinsbursky (6):
>       SUNRPC: handle RPC client pipefs dentries by network namespace aware routines
>       SUNRPC: handle GSS AUTH pipes by network namespace aware routines
>       SUNRPC: subscribe RPC clients to pipefs notifications
>       SUNRPC: remove RPC client pipefs dentries after unregister
>       SUNRPC: remove RPC pipefs mount point manipulations from RPC clients code
>       SUNRPC: remove RPC PipeFS mount point reference from RPC client
> 
> 
>  fs/nfs/idmap.c                 |    4 +
>  fs/nfsd/nfs4callback.c         |    2 -
>  include/linux/nfs.h            |    2 -
>  include/linux/sunrpc/auth.h    |    2 +
>  include/linux/sunrpc/clnt.h    |    2 -
>  net/sunrpc/auth_gss/auth_gss.c |  101 +++++++++++++++++++++------
>  net/sunrpc/clnt.c              |  151 +++++++++++++++++++++++++++++++---------
>  net/sunrpc/rpc_pipe.c          |   19 +++--
>  net/sunrpc/sunrpc.h            |    2 +
>  9 files changed, 218 insertions(+), 67 deletions(-)
> 
> -- 
> Signature
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
