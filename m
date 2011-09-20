From: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 0/8] SUNRPC: make rpcbind clients allocated and
 destroyed dynamically
Date: Tue, 20 Sep 2011 07:24:06 -0400
Message-ID: <20110920072406.378f5ebd@corrin.poochiereds.net>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110920101031.9861.18444.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Sep 2011 14:13:32 +0400
Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> v4:
> 1) creation and destruction on rpcbind clients now depends on service program
> versions "vs_hidden" flag.
> 
> This patch is required for further RPC layer virtualization, because rpcbind
> clients have to be per network namespace.
> To achive this, we have to untie network namespace from rpcbind clients sockets.
> The idea of this patch set is to make rpcbind clients non-static. I.e. rpcbind
> clients will be created during first RPC service creation, and destroyed when
> last RPC service is stopped.
> With this patch set rpcbind clients can be virtualized easely.
> 
> 
> The following series consists of:
> 
> ---
> 
> Stanislav Kinsbursky (8):
>       SUNRPC: introduce helpers for reference counted rpcbind clients
>       SUNRPC: use rpcbind reference counting helpers
>       SUNRPC: introduce svc helpers for prepairing rpcbind infrastructure
>       SUNRPC: setup rpcbind clients if service requires it
>       SUNRPC: cleanup service destruction
>       NFSd: call svc rpcbind cleanup explicitly
>       SUNRPC: remove rpcbind clients creation during service registering
>       SUNRPC: remove rpcbind clients destruction on module cleanup
> 
> 
>  fs/nfsd/nfssvc.c            |    2 +
>  include/linux/sunrpc/clnt.h |    2 +
>  include/linux/sunrpc/svc.h  |    1 +
>  net/sunrpc/rpcb_clnt.c      |   85 ++++++++++++++++++++++++++++---------------
>  net/sunrpc/sunrpc_syms.c    |    3 --
>  net/sunrpc/svc.c            |   48 +++++++++++++++++++++++-
>  6 files changed, 105 insertions(+), 36 deletions(-)
> 

Patchset looks good to me. The only remaining thing I think is to set
vs_hidden on nfs4_callback_version4, but that patch is orthogonal to
this set.

Reviewed-by: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
