From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH 10/13] net: add paged frag destructor to
 skb_fill_page_desc()
Date: Fri, 22 Jul 2011 22:07:52 +0100
Message-ID: <1311368872.4027.76.camel@dagon.hellion.org.uk>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
	 <1311340653-19336-10-git-send-email-ian.campbell@citrix.com>
	 <CAHXqBFLQFKqK=ORpDQx6s2ud8mWkx=YC_AT60GVS+4XK0H61pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"devel@open-fcoe.org" <devel@open-fcoe.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <CAHXqBFLQFKqK=ORpDQx6s2ud8mWkx=YC_AT60GVS+4XK0H61pw@mail.gmail.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-07-22 at 20:58 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/7/22 Ian Campbell <ian.campbell@citrix.com>:
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 9818fe2..faee8d3 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -1134,12 +1134,14 @@ static inline int skb_pagelen(const struct =
sk_buff *skb)
> >  * Does not take any additional reference on the fragment.
> >  */
> >  static inline void __skb_fill_page_desc(struct sk_buff *skb, int i=
,
> > -                                       struct page *page, int off,=
 int size)
> > +                                       struct page *page,
> > +                                       struct skb_frag_destructor =
*destroy,
> > +                                       int off, int size)
> >  {
> >        skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
> >
> >        frag->page.p              =3D page;
> > -       frag->page.destructor     =3D NULL;
> > +       frag->page.destructor     =3D destroy;
> >        frag->page_offset         =3D off;
> >        frag->size                =3D size;
> >  }
>=20
> You could just rename this function to e.g.
> __skb_fill_fragile_page_desc() (or whatever name) add an inline
> wrapper calling it with destroy =3D=3D NULL. This will avoid touching=
 all
> those drivers which won't ever need this functionality.

I could call this variant __skb_frag_init (which I think better fits
into the pattern of the new functions) and leave the existing
__skb_fill_page_desc as a compat wrapper if that's preferred but I was
trying to avoid duplicating up constructors just for different sets of
defaults.
=20
Ian.

--
To unsubscribe from this list: send the line "unsubscribe linux-scsi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
