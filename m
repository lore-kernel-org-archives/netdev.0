From: Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
Subject: Re: [PATCH 7/9 net-next] sunrpc: replace if/BUG by BUG_ON
Date: Tue, 31 Mar 2015 21:11:31 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1503312110240.2115@localhost6.localdomain6>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be> <1427749998-28464-7-git-send-email-fabf@skynet.be> <20150330212520.GF6901@fieldses.org> <256862218.214616.1427828441666.open-xchange@webmail.nmp.proximus.be>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-2138293838-1427829092=:2115"
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Julia Lawall <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
To: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <256862218.214616.1427828441666.open-xchange-2RFepEojUI2qqBEoxdIGPtE3N/6ypZDY@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-2138293838-1427829092=:2115
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT



On Tue, 31 Mar 2015, Fabian Frederick wrote:

> 
> 
> > On 30 March 2015 at 23:25 "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> wrote:
> >
> >
> > Huh, I thought this wasn't recommended:
> >
> >       http://lkml.kernel.org/r/20040828125816.206ef7fa.akpm-3NddpPZAyC0@public.gmane.org
> >
> >       "I'd prefer that we not move code which has side-effects into
> >       BUG_ONs"
> 
> Thanks for the link, I wasn't aware of that problem. Maybe we should add some
> documentation and fix coccinelle detection then ?

Maybe the comment in the Coccinelle rule could just be made more clear?  
The only practical choices are to ignore all function calls and to allow 
all fuction calls, since Coccinelle doesn't know which ones have side 
effects.

julia

> Regards,
> Fabian
> 
> >
> > --b.
> >
> > On Mon, Mar 30, 2015 at 11:13:15PM +0200, Fabian Frederick wrote:
> > > Signed-off-by: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
> > > ---
> > >  net/sunrpc/auth_gss/svcauth_gss.c | 9 +++------
> > >  net/sunrpc/svc_xprt.c             | 3 +--
> > >  2 files changed, 4 insertions(+), 8 deletions(-)
> > >
> > > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c
> > > b/net/sunrpc/auth_gss/svcauth_gss.c
> > > index 1095be9..09f8a1c6 100644
> > > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > > @@ -840,11 +840,9 @@ unwrap_integ_data(struct svc_rqst *rqstp, struct
> > > xdr_buf *buf, u32 seq, struct g
> > >             return stat;
> > >     if (integ_len > buf->len)
> > >             return stat;
> > > -   if (xdr_buf_subsegment(buf, &integ_buf, 0, integ_len))
> > > -           BUG();
> > > +   BUG_ON(xdr_buf_subsegment(buf, &integ_buf, 0, integ_len));
> > >     /* copy out mic... */
> > > -   if (read_u32_from_xdr_buf(buf, integ_len, &mic.len))
> > > -           BUG();
> > > +   BUG_ON(read_u32_from_xdr_buf(buf, integ_len, &mic.len));
> > >     if (mic.len > RPC_MAX_AUTH_SIZE)
> > >             return stat;
> > >     mic.data = kmalloc(mic.len, GFP_KERNEL);
> > > @@ -1595,8 +1593,7 @@ svcauth_gss_wrap_resp_integ(struct svc_rqst *rqstp)
> > >     BUG_ON(integ_len % 4);
> > >     *p++ = htonl(integ_len);
> > >     *p++ = htonl(gc->gc_seq);
> > > -   if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len))
> > > -           BUG();
> > > +   BUG_ON(xdr_buf_subsegment(resbuf, &integ_buf, integ_offset, integ_len));
> > >     if (resbuf->tail[0].iov_base == NULL) {
> > >             if (resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE > PAGE_SIZE)
> > >                     goto out_err;
> > > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > > index 163ac45..2f82e8b 100644
> > > --- a/net/sunrpc/svc_xprt.c
> > > +++ b/net/sunrpc/svc_xprt.c
> > > @@ -960,8 +960,7 @@ static void svc_delete_xprt(struct svc_xprt *xprt)
> > >     struct svc_deferred_req *dr;
> > > 
> > >     /* Only do this once */
> > > -   if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags))
> > > -           BUG();
> > > +   BUG_ON(test_and_set_bit(XPT_DEAD, &xprt->xpt_flags));
> > > 
> > >     dprintk("svc: svc_delete_xprt(%p)\n", xprt);
> > >     xprt->xpt_ops->xpo_detach(xprt);
> > > --
> > > 1.9.1
> 
--8323328-2138293838-1427829092=:2115--
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
