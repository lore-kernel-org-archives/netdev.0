From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2/3] tcp: Remove unrequired operations in tcp_push()
Date: Thu, 10 Dec 2009 17:29:39 +0530
Message-ID: <OFEBDDB464.6D48255E-ON65257688.004044DE-65257688.0040DF93@in.ibm.com>
References: <20091209082613.19055.58864.sendpatchset@localhost.localdomain> <20091209082619.19055.10563.sendpatchset@localhost.localdomain> <alpine.DEB.2.00.0912101008010.23376@melkinpaasi.cs.helsinki.fi> <OFDF2F06F9.1F8246ED-ON65257688.0030E506-65257688.00310B14@in.ibm.com> <alpine.DEB.2.00.0912101224270.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:35906 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934019AbZLJLsf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 06:48:35 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBABmeUY008572
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 17:18:40 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBABmefk2490388
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 17:18:40 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBABmdQJ022179
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 22:48:40 +1100
In-Reply-To: <alpine.DEB.2.00.0912101224270.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote on 12/10/2009 03:56=
:59
PM:

> Re: [PATCH 2/3] tcp: Remove unrequired operations in tcp_push()
>
> On Thu, 10 Dec 2009, Krishna Kumar2 wrote:
>
> > "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote on 12/10/2009
01:40:51
> > PM:
> >
> > > Re: [PATCH 2/3] tcp: Remove unrequired operations in tcp_push()
> > >
> > >
> > > >  static inline void tcp_push(struct sock *sk, int flags, int
mss_now,
> > > >               int nonagle)
> > > >  {
> > > > -   struct tcp_sock *tp =3D tcp_sk(sk);
> > > > -
> > > >     if (tcp_send_head(sk)) {
> > > > -      struct sk_buff *skb =3D tcp_write_queue_tail(sk);
> > > > -      if (!(flags & MSG_MORE) || forced_push(tp))
> > > > +      struct tcp_sock *tp =3D tcp_sk(sk);
> > > > +
> > > > +      if (!(flags & MSG_MORE) || forced_push(tp)) {
> > > > +         struct sk_buff *skb =3D tcp_write_queue_tail(sk);
> > > > +
> > > >           tcp_mark_push(tp, skb);
> > >
> > > I suppose one could kill the temporary variable completely then?
> >
> > I did consider that, but kept it this way for readability reasons.
> > Should I change it?
>
> Honestly that doesn't look that fuzzy code even if you'd stick it int=
o
the
> tcp_mark_push line (nor should be even close to 80 limit). ...I was e=
ven
> thinking of getting totally rid of that skb arg of tcp_mark_push as I
> think it's always tcp_write_queue_tail(sk) that is put there.

Yes, the skb is always the one at the tail. But in 4/5 cases, the
skb pointer is already available, so may be OK to pass the skb. I
will resubmit with the change you suggested (remove the temporary
variable).

Also, for the NETIF_F_SG patch, I will try to put a meaningful
explanation and resubmit.

Thanks for your review,

- KK

