From: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 4/8] SUNRPC: setup rpcbind clients if service
 requires it
Date: Tue, 20 Sep 2011 07:22:06 -0400
Message-ID: <20110920072206.117db4ce@corrin.poochiereds.net>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
	<20110920101404.9861.83097.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110920101404.9861.83097.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Sep 2011 14:14:04 +0400
Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> New function ("svc_uses_rpcbind") will be used to detect, that new service will
> send portmapper register calls. For such services we will create rpcbind
> clients and remove all stale portmap registrations.
> Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for such services
> in case of this field wasn't initialized earlier. This will allow to destroy
> rpcbind clients when no other users of them left.
> 
> Note: Currently, any creating service will be detected as portmap user.
> Probably, this is wrong. But now it depends on program versions "vs_hidden"
> flag.
> 

Yes, I think that nfs4_callback_version4 should also have vs_hidden
set. Currently, it's trying to unregister the service from the
portmapper on shutdown even though it's not registering it. Basically,
any service that sets up its sockets with SVC_SOCK_ANONYMOUS should
also have vs_hidden set on all versions.

-- 
Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
