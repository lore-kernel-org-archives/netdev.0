From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 17:14:30 +0100
Message-ID: <1298045670.6201.73.camel@edumazet-laptop>
References: <20110218132524.GC2939@psychotron.redhat.com>
	 <1298035791.6201.56.camel@edumazet-laptop>
	 <20110218141456.GD2939@psychotron.redhat.com>
	 <1298039252.6201.66.camel@edumazet-laptop> <4D5E8655.5070304@trash.net>
	 <20110218145850.GF2939@psychotron.redhat.com>  <4D5E953F.6010606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Patrick McHardy <kaber@trash.net>, Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45388 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755986Ab1BRQOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 11:14:36 -0500
Received: by bwz15 with SMTP id 15so865230bwz.19
        for <netdev@vger.kernel.org>; Fri, 18 Feb 2011 08:14:35 -0800 (PST)
In-Reply-To: <4D5E953F.6010606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 16:50 +0100, Patrick McHardy a =
=C3=A9crit :
> On 18.02.2011 15:58, Jiri Pirko wrote:
> > Fri, Feb 18, 2011 at 03:46:45PM CET, kaber@trash.net wrote:
> >> Am 18.02.2011 15:27, schrieb Eric Dumazet:
> >>> Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 15:14 +0100, Jiri Pirko a=
 =C3=A9crit :
> >>>
> >>>> Do not know how to do it better. As for percpu variable, not onl=
y
> >>>> origdev would have to be remembered but also probably skb pointe=
r to
> >>>> know if it's the first run on the skb or not. Can't really figur=
e out a
> >>>> better solution. Can you?
> >>>
> >>> I'll try and let you know.
> >>
> >> Why not simply do a lookup on skb->iif?
> >=20
> > Well I was trying to avoid iterating over list of devices for each
> > incoming frame.
> >=20
>=20
> Well, there are a couple of holes on 64 bit, perhaps you can rearrang=
e
> things and eliminate either iif or input_dev without increasing size
> since they appear to be redundant.

Jiri

I dont understand why netif_rx() is needed in your patch.

Can we stack 10 bond devices or so ???

If we avoid this stage and call the real thing (netif_receive_skb()),
then we dont need adding a field in each skb, since it can be carried b=
y
a global variable (per cpu of course)

bond_handle_frame() being called from __netif_receive_skb() I believe i=
t
can use netif_receive_skb() instead of netif_rx().

Same remark for vlan_on_bond_hook()



