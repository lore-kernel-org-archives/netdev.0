From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Fri, 13 Aug 2010 16:35:15 +0200
Message-ID: <1281710115.3760.27.camel@jlt3.sipsolutions.net>
References: <1279699529.3707.5.camel@jlt3.sipsolutions.net>
	 <1279700420.2452.15.camel@edumazet-laptop>
	 <1279701835.2452.17.camel@edumazet-laptop>
	 <20100725.215548.112589000.davem@davemloft.net>
	 <1281708024.3760.12.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:50436 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754468Ab0HMOfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 10:35:17 -0400
In-Reply-To: <1281708024.3760.12.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-08-13 at 16:00 +0200, Johannes Berg wrote:
> On Sun, 2010-07-25 at 21:55 -0700, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 21 Jul 2010 10:43:55 +0200
> > 
> > > [PATCH net-next-2.6 v3] netlink: netlink_recvmsg() fix
> > > 
> > > commit 1dacc76d0014 
> > > (net/compat/wext: send different messages to compat tasks)
> > > introduced a race condition on netlink, in case MSG_PEEK is used.
> > > 
> > > An skb given by skb_recv_datagram() might be shared, we must copy it
> > > before any modification, or risk fatal corruption.
> > > 
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > 
> > Applied, thanks Eric.
> 
> I keep getting errors like below in 2.6.35+wireless-testing. Not saying
> that it's this patch's fault, but it is the only thing I remember
> touching that area.

In fact, I think something's wrong with this patch, since my comment
(that right now unfortunately I no longer fully understand) says:

                 * If this skb has a frag_list, then here that means that
                 * we will have to use the frag_list skb for compat tasks
                 * and the regular skb for non-compat tasks.
                 *
                 * The skb might (and likely will) be cloned, so we can't
                 * just reset frag_list and go on with things -- we need to
                 * keep that. For the compat case that's easy -- simply get
                 * a reference to the compat skb and free the regular one
                 * including the frag. For the non-compat case, we need to
                 * avoid sending the frag to the user -- so assign NULL but
                 * restore it below before freeing the skb.

and that's no longer true, afaict.

johannes


