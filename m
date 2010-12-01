From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: slightly simplify keeping IPv6 addresses on link down
Date: Wed, 1 Dec 2010 12:52:42 -0800
Message-ID: <AANLkTin5f+BZnFEzuc6iPLC8Hp++V0Jam8aAU2jMvxQq@mail.gmail.com>
References: <20101201.110157.246534994.davem@davemloft.net>
 <AAs7234jas72lda05laWgh1LziatUa+qSHd+6Jj+k_eO=@mail.gmail.com> <20101201122253.2a8be2e0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:3465 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756914Ab0LAUxH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 15:53:07 -0500
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id oB1Kr5tn022206
	for <netdev@vger.kernel.org>; Wed, 1 Dec 2010 12:53:05 -0800
Received: from iwn10 (iwn10.prod.google.com [10.241.68.74])
	by wpaz1.hot.corp.google.com with ESMTP id oB1KqqNp026381
	for <netdev@vger.kernel.org>; Wed, 1 Dec 2010 12:53:04 -0800
Received: by iwn10 with SMTP id 10so464101iwn.30
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 12:53:03 -0800 (PST)
In-Reply-To: <20101201122253.2a8be2e0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 1, 2010 at 12:22 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -2663,7 +2663,8 @@ static int addrconf_ifdown(struct net_device =
*dev, int how)
> > =A0{
> > =A0 =A0 =A0 struct net *net =3D dev_net(dev);
> > =A0 =A0 =A0 struct inet6_dev *idev;
> > - =A0 =A0 struct inet6_ifaddr *ifa, *ifn;
> > + =A0 =A0 struct inet6_ifaddr *ifa;
> > + =A0 =A0 LIST_HEAD(keep_list);
> > =A0 =A0 =A0 int state;
>
> Your patch is backwards? The existing code is:

Oops, yes. Wrong order of arguments. Another one coming up.

> Also, the addrconf_ifdown can race with other updates to idev->addr_l=
ist
> from addrconf timers etc. =A0Therefore even list_for_each_entry_safe =
is not safe.

No, wait... The loop is protected by idev->lock, and the code just
before it that clears the temporary address list is essentially
identical (except it looks over tempaddr_list instead). Wouldn't that
blow up as well?
