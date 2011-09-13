From: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 3/5] SUNRPC: make RPC service dependable on rpcbind
 clients creation
Date: Tue, 13 Sep 2011 09:52:04 -0400
Message-ID: <20110913095204.7904c051@corrin.poochiereds.net>
References: <20110909115146.13697.71682.stgit@localhost6.localdomain6>
	<20110909120844.13697.48102.stgit@localhost6.localdomain6>
	<20110909100745.7e2e8bf9@corrin.poochiereds.net>
	<4E6A41D4.6090001@parallels.com>
	<1315593874.17611.19.camel@lade.trondhjem.org>
	<20110909150104.5a83c60d@tlielax.poochiereds.net>
	<1315596308.17611.46.camel@lade.trondhjem.org>
	<20110913085139.00f112e2@corrin.poochiereds.net>
	<4E6F5D2F.4050100@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E6F5D2F.4050100-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Sep 2011 17:39:59 +0400
Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> 13.09.2011 16:51, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> > My assumption in reading this set (maybe wrong) was that this was a
> > preliminary set for now that just plops in function calls in the pl=
aces
> > that do this sort of thing now. I figured that eventually he'd conv=
ert
> > rpcb_create_local, et. al. to do the same thing but within the corr=
ect
> > namespace for the calling task.
> >
>=20
> You have a right assumption. This is exactly what I'm going to do nex=
t.
>=20
> >
> > I think the simplest solution would be to basically call these
> > functions closer to where the rpcbind calls happen today, and just
> > don't do them when the svc_program has vs_hidden set or if the xprt=
 is
> > being created with SVC_SOCK_ANONYMOUS set.
> >
>=20
> This solution is not the simplest one since we call svc_register() fo=
r every svc=20
> socket if it's not anonymous. But svc_unregister() is called only onc=
e for all=20
> inet families and protocols.
>=20

Ahh ok, good point.

> Also I've noticed, that we call svc_unregister in __svc_create(). I.e=
=2E we call=20
> it for nfs callbacks as well (in spite of that we don't need this). T=
hus, for=20
> now, nfs callbacks service creation depends on rpcbind clients presen=
ce.
>=20

Yeah, that's just to remove the any existing registration before we set
up the new one. In the case of a "hidden" service that can probably be
skipped if it makes things easier.

> So, for my pow, we need something like startup() callback, passed to=20
> svc_create(_pooled)() to clean up this mess.
> This callback will be defined only for lockd and nfsd and will create=
 rpcbind=20
> clients and remove any stale portmap registrations.
>=20

That sounds like a reasonable scheme. I'll wait to see the patches.

--=20
Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
