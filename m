From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 13/17] batman-adv: Consume skb in receive
	handlers
Date: Tue, 08 Nov 2016 09:43:01 -0800
Message-ID: <1478626981.17367.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161108164526.7518-1-sw@simonwunderlich.de>
 <20161108164526.7518-14-sw@simonwunderlich.de>
 <1478624389.17367.12.camel@edumazet-glaptop3.roam.corp.google.com>
 <2044854.g075mifYzn@bentobox>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <2044854.g075mifYzn@bentobox>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tue, 2016-11-08 at 18:28 +0100, Sven Eckelmann wrote:
> On Dienstag, 8. November 2016 08:59:49 CET Eric Dumazet wrote:
> [...]
> > > +free_skb:
> > >  	consume_skb(skb);
> > > -	return NET_RX_SUCCESS;
> > > +
> > > +	return ret;
> > >  }
> > 
> > 
> > Okay, but we do have kfree_skb() and consume_skb() and they should be
> > used appropriately.
> 
> Yes, this patch is one part of reaching this goal. Some other parts are also
> in this patchset. But other changes like the one you've mention here (change
> some consume_skb partially back to kfree_skb) have still to be done. But
> first we have to clean up the main portion of the mess :)

Sure, but your patch 13/17 should address this right away.

You must not call consume_skb() if you are dropping a packet.

Prior to this patch, kfree_skb() was properly called, and after this
patch, consume_skb() is called instead.


-       ret = (*batadv_rx_handler[idx])(skb, hard_iface);
-
-       if (ret == NET_RX_DROP)
-               kfree_skb(skb);
+       (*batadv_rx_handler[idx])(skb, hard_iface);
 
You can not claim working on these issues and at the same time add them
back.
