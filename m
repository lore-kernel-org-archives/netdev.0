From: "Felix Marti" <felix@chelsio.com>
Subject: RE: drivers/net/chelsio/my3126.c: inconsequent NULL checking
Date: Thu, 7 Dec 2006 07:56:43 -0800
Message-ID: <8A71B368A89016469F72CD08050AD334E7216B@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:25151 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032334AbWLGP5r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 10:57:47 -0500
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>, <jesper.juhl@gmail.com>, <bunk@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Jesper Juhl <jesper.juhl@gmail.com> wrote:
> On 07/12/06, Adrian Bunk <bunk@stusta.de> wrote:
> > The Coverity checker spotted the following inconsequent NULL
checking
> > introduced by commit f1d3d38af75789f1b82969b83b69cab540609789:
> >
> > <--  snip  -->
> >
> > ...
> > static struct cphy *my3126_phy_create(adapter_t *adapter,
> >                         int phy_addr, struct mdio_ops *mdio_ops)
> > {
> >         struct cphy *cphy = kzalloc(sizeof (*cphy), GFP_KERNEL);
> >
> >         if (cphy)
> >                 cphy_init(cphy, adapter, phy_addr, &my3126_ops,
mdio_ops);
> >
> >         INIT_WORK(&cphy->phy_update, my3216_poll, cphy);
> >         cphy->bmsr = 0;
> >
> >         return (cphy);
> > }
> > ...
> >
> > <--  snip  -->
> >
> > It doesn't make sense to first check whether "cphy" is NULL and
> > dereference it unconditionally later.
> >
> 
> How about simply changing
>          if (cphy)
>                  cphy_init(cphy, adapter, phy_addr, &my3126_ops,
mdio_ops);
> into
>          if (!cphy)
>                  return NULL;
> 
> callers need to be able to handle that ofcourse, but I haven't checked
that
> yet.

[Felix Marti] Yes, returning NULL on allocation failure is the way to
go. The caller does handle it.

> 
> --
> Jesper Juhl <jesper.juhl@gmail.com>
> Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
> Plain text mails only, please      http://www.expita.com/nomime.html
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
