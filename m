From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 7/9 net-next] sunrpc: replace if/BUG by BUG_ON
Date: Tue, 31 Mar 2015 22:13:51 +0200 (CEST)
Message-ID: <530301968.220700.1427832831521.open-xchange@webmail.nmp.proximus.be>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be> <1427749998-28464-7-git-send-email-fabf@skynet.be> <20150330212520.GF6901@fieldses.org> <256862218.214616.1427828441666.open-xchange@webmail.nmp.proximus.be> <alpine.DEB.2.02.1503312110240.2115@localhost6.localdomain6>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"David S. Miller" <davem@davemloft.net>,
	Anna Schumaker <anna.schumaker@netapp.com>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1503312110240.2115@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 31 March 2015 at 21:11 Julia Lawall <julia.lawall@lip6.fr> wrote:
>
>
>
>
> On Tue, 31 Mar 2015, Fabian Frederick wrote:
>
> >
> >
> > > On 30 March 2015 at 23:25 "J. Bruce Fields" <bfields@fieldses.org=
> wrote:
> > >
> > >
> > > Huh, I thought this wasn't recommended:
> > >
> > >=C2=A0 =C2=A0 =C2=A0 =C2=A0http://lkml.kernel.org/r/20040828125816=
=2E206ef7fa.akpm@osdl.org
> > >
> > >=C2=A0 =C2=A0 =C2=A0 =C2=A0"I'd prefer that we not move code which=
 has side-effects into
> > >=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ONs"
> >
> > Thanks for the link, I wasn't aware of that problem. Maybe we shoul=
d add
> > some
> > documentation and fix coccinelle detection then ?
>
> Maybe the comment in the Coccinelle rule could just be made more clea=
r?=C2=A0

=46air enough. Current "WARNING: Use BUG_ON" looks misleading.
Maybe some BUG_ON(function()) detection script would be interesting as =
well ?
There are nearly 5000 BUG_ON() in drivers branch only ...=C2=A0

Regards,
=46abian
> The only practical choices are to ignore all function calls and to al=
low
> all fuction calls, since Coccinelle doesn't know which ones have side
> effects.
>
> julia
>
> > Regards,
> > Fabian
> >
> > >
> > > --b.
> > >
> > > On Mon, Mar 30, 2015 at 11:13:15PM +0200, Fabian Frederick wrote:
> > > > Signed-off-by: Fabian Frederick <fabf@skynet.be>
> > > > ---
> > > >=C2=A0 net/sunrpc/auth_gss/svcauth_gss.c | 9 +++------
> > > >=C2=A0 net/sunrpc/svc_xprt.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0| 3 +--
> > > >=C2=A0 2 files changed, 4 insertions(+), 8 deletions(-)
> > > >
> > > > diff --git a/net/sunrpc/auth_gss/svcauth_gss.c
> > > > b/net/sunrpc/auth_gss/svcauth_gss.c
> > > > index 1095be9..09f8a1c6 100644
> > > > --- a/net/sunrpc/auth_gss/svcauth_gss.c
> > > > +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> > > > @@ -840,11 +840,9 @@ unwrap_integ_data(struct svc_rqst *rqstp, =
struct
> > > > xdr_buf *buf, u32 seq, struct g
> > > >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return stat;
> > > >=C2=A0 =C2=A0 =C2=A0if (integ_len > buf->len)
> > > >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return stat;
> > > > -=C2=A0 =C2=A0if (xdr_buf_subsegment(buf, &integ_buf, 0, integ_=
len))
> > > > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG();
> > > > +=C2=A0 =C2=A0BUG_ON(xdr_buf_subsegment(buf, &integ_buf, 0, int=
eg_len));
> > > >=C2=A0 =C2=A0 =C2=A0/* copy out mic... */
> > > > -=C2=A0 =C2=A0if (read_u32_from_xdr_buf(buf, integ_len, &mic.le=
n))
> > > > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG();
> > > > +=C2=A0 =C2=A0BUG_ON(read_u32_from_xdr_buf(buf, integ_len, &mic=
=2Elen));
> > > >=C2=A0 =C2=A0 =C2=A0if (mic.len > RPC_MAX_AUTH_SIZE)
> > > >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return stat;
> > > >=C2=A0 =C2=A0 =C2=A0mic.data =3D kmalloc(mic.len, GFP_KERNEL);
> > > > @@ -1595,8 +1593,7 @@ svcauth_gss_wrap_resp_integ(struct svc_rq=
st
> > > > *rqstp)
> > > >=C2=A0 =C2=A0 =C2=A0BUG_ON(integ_len % 4);
> > > >=C2=A0 =C2=A0 =C2=A0*p++ =3D htonl(integ_len);
> > > >=C2=A0 =C2=A0 =C2=A0*p++ =3D htonl(gc->gc_seq);
> > > > -=C2=A0 =C2=A0if (xdr_buf_subsegment(resbuf, &integ_buf, integ_=
offset, integ_len))
> > > > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG();
> > > > +=C2=A0 =C2=A0BUG_ON(xdr_buf_subsegment(resbuf, &integ_buf, int=
eg_offset,
> > > > integ_len));
> > > >=C2=A0 =C2=A0 =C2=A0if (resbuf->tail[0].iov_base =3D=3D NULL) {
> > > >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (resbuf->head=
[0].iov_len + RPC_MAX_AUTH_SIZE > PAGE_SIZE)
> > > >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto out_err;
> > > > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > > > index 163ac45..2f82e8b 100644
> > > > --- a/net/sunrpc/svc_xprt.c
> > > > +++ b/net/sunrpc/svc_xprt.c
> > > > @@ -960,8 +960,7 @@ static void svc_delete_xprt(struct svc_xprt=
 *xprt)
> > > >=C2=A0 =C2=A0 =C2=A0struct svc_deferred_req *dr;
> > > >=C2=A0
> > > >=C2=A0 =C2=A0 =C2=A0/* Only do this once */
> > > > -=C2=A0 =C2=A0if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags))
> > > > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG();
> > > > +=C2=A0 =C2=A0BUG_ON(test_and_set_bit(XPT_DEAD, &xprt->xpt_flag=
s));
> > > >=C2=A0
> > > >=C2=A0 =C2=A0 =C2=A0dprintk("svc: svc_delete_xprt(%p)\n", xprt);
> > > >=C2=A0 =C2=A0 =C2=A0xprt->xpt_ops->xpo_detach(xprt);
> > > > --
> > > > 1.9.1
> >
