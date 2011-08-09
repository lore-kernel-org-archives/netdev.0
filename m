From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Tue, 09 Aug 2011 20:24:17 +0200
Message-ID: <1312914257.2547.10.camel@edumazet-laptop>
References: <1312907945-1982-1-git-send-email-wangshaoyan.pt@taobao.com>
	 <1312908784.2371.53.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1312912326.11924.12.camel@Joe-Laptop>
	 <1312912774.2547.1.camel@edumazet-laptop>
	 <1312913545.11924.16.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, stufever@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Wang Shaoyan <wangshaoyan.pt@taobao.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312913545.11924.16.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 09 ao=C3=BBt 2011 =C3=A0 11:12 -0700, Joe Perches a =C3=A9crit=
 :
> On Tue, 2011-08-09 at 19:59 +0200, Eric Dumazet wrote:
> > Le mardi 09 ao=C3=BBt 2011 =C3=A0 10:52 -0700, Joe Perches a =C3=A9=
crit :
> > > On Tue, 2011-08-09 at 18:53 +0200, Eric Dumazet wrote:
> > > > Le mercredi 10 ao=C3=BBt 2011 =C3=A0 00:39 +0800, stufever@gmai=
l.com a =C3=A9crit :
> > > []
> > > > > +	if (!local_rqfpr || !local_rqfcr) {
> > > > > +		pr_err("Out of memory\n");
> > > > 	Please remove this pr_err(), kmalloc() will complain already.
> > > Always?
> > > I know there's a trace option, but is it always on?
> > Yes, unless caller added ___GFP_NOWARN in gfp :
> > ptr =3D kmalloc(size, GFP_KERNEL | ___GFP_NOWARN);
>=20
> Isn't that true only for slub?
>=20

nope, this is page allocation, so common to slab/slub/...

> Do you know where this get emitted?
> I looked cursorily but I don't see it.
>=20

This is a bit beyond this thread

Look at mm/page_alloc.c

void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
