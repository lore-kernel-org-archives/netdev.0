From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH net v2] ip_tunnels: Use skb-len to PMTU check.
Date: Mon, 1 Jul 2013 15:18:39 +0300
Message-ID: <20130701151839.1e7dd12d@vostro>
References: <1372660232-12174-1-git-send-email-pshelar@nicira.com>
	<20130701094132.3019afb4@vostro>
	<CALnjE+qW2P031bwOaTkC-kP2LOvOydBQ0YzBAhd71D66Wugfig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:40468 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695Ab3GAMS1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 08:18:27 -0400
Received: by mail-ea0-f177.google.com with SMTP id j14so2005247eak.8
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 05:18:26 -0700 (PDT)
In-Reply-To: <CALnjE+qW2P031bwOaTkC-kP2LOvOydBQ0YzBAhd71D66Wugfig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1 Jul 2013 00:06:22 -0700
Pravin Shelar <pshelar@nicira.com> wrote:

> On Sun, Jun 30, 2013 at 11:41 PM, Timo Teras <timo.teras@iki.fi>
> wrote:
> > On Sun, 30 Jun 2013 23:30:32 -0700
> > Pravin B Shelar <pshelar@nicira.com> wrote:
> >
> >> In path mtu check, ip header total length works for gre device
> >> but not for gre-tap device.  Use skb len which is consistent
> >> for all tunneling types.  This is old bug in gre.
> >> This also fixes mtu calculation bug introduced by
> >> commit c54419321455631079c7d (GRE: Refactor GRE tunneling code).
> >>
> >> Reported-by: Timo Teras <timo.teras@iki.fi>
> >> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> >> ---
> >> v1-v2:
> >>  - Fix pmtu set.
> >>  - This patch also restructures code which help couple of
> >>    improvements I have.
> >
> > Looks good to me. One additional comment below.
> >
> >> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> >> index 7fa8f08..ae5b78c 100644
> >> --- a/net/ipv4/ip_tunnel.c
> >> +++ b/net/ipv4/ip_tunnel.c
> >> @@ -486,6 +486,53 @@ drop:
> >>  }
> >>  EXPORT_SYMBOL_GPL(ip_tunnel_rcv);
> >>
> >> +static int tnl_update_pmtu(struct net_device *dev, struct sk_buff
> >> *skb,
> >> +                         struct rtable *rt, __be16 df)
> >> +{
> >> +     struct ip_tunnel *tunnel =3D netdev_priv(dev);
> >> +     int pkt_size =3D skb->len - tunnel->hlen;
> >> +     int mtu;
> >> +
> >> +     if (df)
> >> +             mtu =3D dst_mtu(&rt->dst) - dev->hard_header_len
> >> +                                     - sizeof(struct iphdr) -
> >> tunnel->hlen;
> >> +     else
> >> +             mtu =3D skb_dst(skb) ? dst_mtu(skb_dst(skb)) :
> >> dev->mtu; +
> >> +     if (skb_dst(skb))
> >> +             skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL,
> >> skb, mtu); +
> >
> > Since mtu can change for skb_dst() only if df is set, would it make
> > sense to move the whole update_pmtu call inside if (df) {} block?
> >
> I am not sure abt that. Other events can change mtu.
> anyways I think it would be better to have separate patch for that if
> required. This patch already fixes two (related) issues.

=46air enough.

Acked-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
