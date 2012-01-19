From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 3/5] SUNRPC: create GSS auth cache per network namespace
Date: Thu, 19 Jan 2012 11:31:49 -0500
Message-ID: <20120119163149.GD527@fieldses.org>
References: <20120119144517.9957.59143.stgit@localhost6.localdomain6>
 <20120119144922.9957.39352.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120119144922.9957.39352.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 19, 2012 at 06:49:23PM +0400, Stanislav Kinsbursky wrote:
> @@ -1000,6 +996,7 @@ static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
>  	struct xdr_netobj tmpobj;
>  	struct rsi *rsip, rsikey;
>  	int ret;
> +	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);

OK, so you're getting the network namespace out of the rqstp, and, then
passing it down, makes sense.  And:

> @@ -1079,6 +1076,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
>  	__be32		*rpcstart;
>  	__be32		*reject_stat = resv->iov_base + resv->iov_len;
>  	int		ret;
> +	struct sunrpc_net *sn = net_generic(rqstp->rq_xprt->xpt_net, sunrpc_net_id);

... same for the gss cache.  Looks good.

How do you plan to test this?

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
