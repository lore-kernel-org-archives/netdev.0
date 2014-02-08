From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: Clear local_df only if crossing namespace.
Date: Sat, 8 Feb 2014 01:58:43 +0100
Message-ID: <20140208005843.GE16198@order.stressinduktion.org>
References: <1391811158-11433-1-git-send-email-pshelar@nicira.com> <20140207222840.GD16198@order.stressinduktion.org> <CALnjE+pbcbENWjQcE8T0QLa=d0iia3EBBVJz-sGVzAZbsQarLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	nicolas.dichtel@6wind.com
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38907 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaBHA6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 19:58:45 -0500
Content-Disposition: inline
In-Reply-To: <CALnjE+pbcbENWjQcE8T0QLa=d0iia3EBBVJz-sGVzAZbsQarLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Cc Nicolas]

On Fri, Feb 07, 2014 at 02:49:20PM -0800, Pravin Shelar wrote:
> On Fri, Feb 7, 2014 at 2:28 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > Hi!
> >
> > On Fri, Feb 07, 2014 at 02:12:38PM -0800, Pravin wrote:
> >> --- a/net/core/skbuff.c
> >> +++ b/net/core/skbuff.c
> >> @@ -3905,12 +3905,13 @@ EXPORT_SYMBOL(skb_try_coalesce);
> >>   */
> >>  void skb_scrub_packet(struct sk_buff *skb, bool xnet)
> >>  {
> >> -     if (xnet)
> >> +     if (xnet) {
> >>               skb_orphan(skb);
> >> +             skb->local_df = 0;
> >> +     }
> >>       skb->tstamp.tv64 = 0;
> >>       skb->pkt_type = PACKET_HOST;
> >>       skb->skb_iif = 0;
> >> -     skb->local_df = 0;
> >>       skb_dst_drop(skb);
> >>       skb->mark = 0;
> >>       secpath_reset(skb);
> >
> > I wonder if this should be the right behaviour for tunnels, which should just
> > do fragmentation based on IP_DF, even if the packet originated locally from a
> > socket which allowed local fragmentation (inet->pmtudisc < IP_PMTUDISC_DO).
> >
> This is not about tunneling, skb_scrub_packet() is generic function
> which should not reset local_df on all packets.
> 
> We can have separate discussion about use of local_df and tunneling in
> another thread.

This change only affects tunnel code as of current net branch, how do
you not expect a discussion about that in this thread, I really wonder?

May I know because of wich vport, vxlan or gre, you did this change?

I am feeling a bit uncomfortable handling remote and local packets that
differently on lower tunnel output (local_df is mostly set on locally
originating packets).

Thanks,

  Hannes
