From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/3] tcp: Remove unrequired operations in tcp_push()
Date: Thu, 10 Dec 2009 12:26:59 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912101224270.7024@wel-95.cs.helsinki.fi>
References: <20091209082613.19055.58864.sendpatchset@localhost.localdomain> <20091209082619.19055.10563.sendpatchset@localhost.localdomain> <alpine.DEB.2.00.0912101008010.23376@melkinpaasi.cs.helsinki.fi>
 <OFDF2F06F9.1F8246ED-ON65257688.0030E506-65257688.00310B14@in.ibm.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-128538840-1260440819=:7024"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43927 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932687AbZLJK07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 05:26:59 -0500
In-Reply-To: <OFDF2F06F9.1F8246ED-ON65257688.0030E506-65257688.00310B14@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-128538840-1260440819=:7024
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 10 Dec 2009, Krishna Kumar2 wrote:

> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote on 12/10/2009 01:40:51
> PM:
> 
> > Re: [PATCH 2/3] tcp: Remove unrequired operations in tcp_push()
> >
> >
> > >  static inline void tcp_push(struct sock *sk, int flags, int mss_now,
> > >               int nonagle)
> > >  {
> > > -   struct tcp_sock *tp = tcp_sk(sk);
> > > -
> > >     if (tcp_send_head(sk)) {
> > > -      struct sk_buff *skb = tcp_write_queue_tail(sk);
> > > -      if (!(flags & MSG_MORE) || forced_push(tp))
> > > +      struct tcp_sock *tp = tcp_sk(sk);
> > > +
> > > +      if (!(flags & MSG_MORE) || forced_push(tp)) {
> > > +         struct sk_buff *skb = tcp_write_queue_tail(sk);
> > > +
> > >           tcp_mark_push(tp, skb);
> >
> > I suppose one could kill the temporary variable completely then?
> 
> I did consider that, but kept it this way for readability reasons.
> Should I change it?

Honestly that doesn't look that fuzzy code even if you'd stick it into the 
tcp_mark_push line (nor should be even close to 80 limit). ...I was even 
thinking of getting totally rid of that skb arg of tcp_mark_push as I 
think it's always tcp_write_queue_tail(sk) that is put there.

-- 
 i.
--8323329-128538840-1260440819=:7024--
