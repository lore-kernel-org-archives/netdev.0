From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] sunrpc: fix error path - actually return ERR_PTR() on
 error
Date: Fri, 12 Mar 2010 10:09:51 -0500
Message-ID: <1268406591.3156.18.camel@localhost.localdomain>
References: <1268401704-9034-1-git-send-email-ext-jani.1.nikula@nokia.com>
	 <201003122314.IAD17160.OtJLHVMFOOSFFQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: ext-jani.1.nikula-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, batsakis-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bhalevy-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201003122314.IAD17160.OtJLHVMFOOSFFQ-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-03-12 at 23:14 +0900, Tetsuo Handa wrote: 
> Jani Nikula wrote:
> > Signed-off-by: Jani Nikula <ext-jani.1.nikula-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
> > 
> > ---
> > 
> > NOTE: I'm afraid I'm unable to test this; please consider this more a
> > bug report than a complete patch.
> > ---
> Indeed, it has to be "return ERR_PTR(-EINVAL);".
> Otherwise, it will trigger NULL pointer dereference some lines later.
> 
>     bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
>     bc_sock->sk_bc_xprt = xprt;
> 
> This bug was introduced by f300baba5a1536070d6d77bf0c8c4ca999bb4f0f
> "nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel" and
> exists in 2.6.32 and later.

Or it should just be dropped. I don't see any reason why nfsd should be
trying to set up a callback channel if it doesn't already know that it
has a socket. Returning an error value in that case would just be
papering over a design bug.

   Trond
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
