From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/4] net: check for reference outside of skb
Date: Mon, 2 Aug 2010 16:21:58 -0700
Message-ID: <20100802162158.0b0c6e70@nehalam>
References: <20100802220030.991706005@vyatta.com>
	<20100802220113.557212477@vyatta.com>
	<AANLkTi=8+xRJn_26740uKuWdgA=XvyB7-hgGT9dxjOXr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47282 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751547Ab0HBXWB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 19:22:01 -0400
In-Reply-To: <AANLkTi=8+xRJn_26740uKuWdgA=XvyB7-hgGT9dxjOXr@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Aug 2010 07:11:14 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> On Tue, Aug 3, 2010 at 6:00 AM, Stephen Hemminger <shemminger@vyatta.=
com> wrote:
> > It is legitimate for callers of skb_header_pointer to pass a negati=
ve
> > offset, but the resulting pointer should not go outside the valid
> > range of data in the skb.
> >
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> > --- a/include/linux/skbuff.h =A0 =A02010-08-01 09:23:01.635121262 -=
0700
> > +++ b/include/linux/skbuff.h =A0 =A02010-08-01 09:25:27.453901530 -=
0700
> > @@ -1853,6 +1853,9 @@ static inline void *skb_header_pointer(c
> > =A0{
> > =A0 =A0 =A0 =A0int hlen =3D skb_headlen(skb);
> >
> > + =A0 =A0 =A0 if (hlen + offset < 0)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> > +
>=20
> It seems wrong. do you mean
>=20
>       if (skb_headroom(hlen) + offset < 0)
>=20
> Nevertheless it is also wrong. skb_header_pointer doesn't know if the
> headroom is filled with valid data or not.
>

It should be headroom. It is okay if the request is looking at PAD
area, that is the callers problem. Just don't want wander off into
into unallocated space.

Anyway, I'll fix it in cls_u32.
