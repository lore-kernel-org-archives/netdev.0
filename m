From: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Subject: Re: [patch] sunrpc: add missing return statement
Date: Tue, 4 May 2010 22:03:05 +0900
Message-ID: <201005042203.DAJ09881.tFQOJFHSOLVOMF@I-love.SAKURA.ne.jp>
References: <20100504115759.266396633@emlix.com>
	<1272976042.7559.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, batsakis-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org, jw-QdrG9jWwCLEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1272976042.7559.24.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Trond Myklebust wrote:
> On Tue, 2010-05-04 at 13:59 +0200, Johannes Weiner wrote: 
> > f300bab "nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel"
> > introduced an error case branch that lacks an actual `return' keyword
> > before the return value.  Add it.
> > 
> > Signed-off-by: Johannes Weiner <jw-QdrG9jWwCLEAvxtiuMwx3w@public.gmane.org>
> > Cc: Alexandros Batsakis <batsakis-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> > ---
> >  net/sunrpc/xprtsock.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -2444,7 +2444,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(
> >  	struct svc_sock *bc_sock;
> >  
> >  	if (!args->bc_xprt)
> > -		ERR_PTR(-EINVAL);
> > +		return ERR_PTR(-EINVAL);
> >  
> >  	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
> >  	if (IS_ERR(xprt))
> 
> No. It should either be a BUG_ON(), or else be removed entirely.
> Returning an error value for something that is clearly a programming bug
> is not a particularly useful exercise...
> 
Removing NULL check is wrong because it will NULL pointer dereference later.

Tetsuo Handa wrote:
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
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
