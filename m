From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: allow skb->head to be a page fragment
Date: Wed, 07 Nov 2012 03:04:24 -0800
Message-ID: <1352286264.3140.3575.camel@edumazet-glaptop>
References: <1335522818.2775.227.camel@edumazet-glaptop>
	 <509A19E6.4040707@gmail.com>  <509A1D49.4080306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:50064 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754221Ab2KGLE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 06:04:27 -0500
Received: by mail-ia0-f174.google.com with SMTP id y32so997795iag.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 03:04:27 -0800 (PST)
In-Reply-To: <509A1D49.4080306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-07 at 16:35 +0800, Li Yu wrote:
> =E4=BA=8E 2012=E5=B9=B411=E6=9C=8807=E6=97=A5 16:20, Li Yu =E5=86=99=E9=
=81=93:
> > =E4=BA=8E 2012=E5=B9=B404=E6=9C=8827=E6=97=A5 18:33, Eric Dumazet =E5=
=86=99=E9=81=93:
> >> From: Eric Dumazet <edumazet@google.com>
> >>
> >> skb->head is currently allocated from kmalloc(). This is convenien=
t but
> >> has the drawback the data cannot be converted to a page fragment i=
f
> >> needed.
> >>
> >
> > Hi, Eric,
> >
> > I have a question about this patch, why data are allocated from
> > kmalloc() can not be converted to page fragment ? We have its kerne=
l
> > mapped address and length, so we can get its page and offset in the
> > page. If the skb is not cloned (shared with others), such page and =
its
> > offset should be can use safely, in my words.
> >
> > I suspected that I may lost important something in slab internals, =
is
> > right?
> >
> > Thanks
> >
> > Yu
> >
>=20
> Or since slab allocated object may be across multiple pages?
> I saw __netdev_alloc_skb() only use build_skb() with non-zero
> fragsz if it is less than PAGE_SIZE.
>=20

SLAB allocators have their own way to handle a page, we cant interfere
with it.

So no, a kmalloced() object cannot be converted to a page fragment.
