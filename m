From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2/3] tcp: Remove unrequired operations in tcp_push()
Date: Thu, 10 Dec 2009 14:36:46 +0530
Message-ID: <OFDF2F06F9.1F8246ED-ON65257688.0030E506-65257688.00310B14@in.ibm.com>
References: <20091209082613.19055.58864.sendpatchset@localhost.localdomain> <20091209082619.19055.10563.sendpatchset@localhost.localdomain> <alpine.DEB.2.00.0912101008010.23376@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:60999 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbZLJIzq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 03:55:46 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBA8tpse027123
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 14:25:51 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBA8tpqD3694682
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 14:25:51 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBA8tpJM015547
	for <netdev@vger.kernel.org>; Thu, 10 Dec 2009 19:55:51 +1100
In-Reply-To: <alpine.DEB.2.00.0912101008010.23376@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote on 12/10/2009 01:40=
:51
PM:

> Re: [PATCH 2/3] tcp: Remove unrequired operations in tcp_push()
>
>
> >  static inline void tcp_push(struct sock *sk, int flags, int mss_no=
w,
> >               int nonagle)
> >  {
> > -   struct tcp_sock *tp =3D tcp_sk(sk);
> > -
> >     if (tcp_send_head(sk)) {
> > -      struct sk_buff *skb =3D tcp_write_queue_tail(sk);
> > -      if (!(flags & MSG_MORE) || forced_push(tp))
> > +      struct tcp_sock *tp =3D tcp_sk(sk);
> > +
> > +      if (!(flags & MSG_MORE) || forced_push(tp)) {
> > +         struct sk_buff *skb =3D tcp_write_queue_tail(sk);
> > +
> >           tcp_mark_push(tp, skb);
>
> I suppose one could kill the temporary variable completely then?

I did consider that, but kept it this way for readability reasons.
Should I change it?

Thanks,

- KK

