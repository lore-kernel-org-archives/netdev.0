From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] bnx2 + vlan + TSO : doesnt work
Date: Tue, 18 Jan 2011 07:38:52 +0100
Message-ID: <1295332732.3362.541.camel@edumazet-laptop>
References: <1295308844.3362.135.camel@edumazet-laptop>
	 <1295309365.6264.23.camel@bwh-desktop>
	 <AANLkTincFt4fKLvtity=MgQ2+cuvNFrBHqu3+bMLsypc@mail.gmail.com>
	 <20110117.220927.189715926.davem@davemloft.net>
	 <1295331690.3362.522.camel@edumazet-laptop>
	 <AANLkTi=zvsmnemO+9OggD01i==3mZnb_-09CjAcRS94w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59891 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab1ARGi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 01:38:58 -0500
Received: by wyb28 with SMTP id 28so5786569wyb.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 22:38:57 -0800 (PST)
In-Reply-To: <AANLkTi=zvsmnemO+9OggD01i==3mZnb_-09CjAcRS94w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 janvier 2011 =C3=A0 01:32 -0500, Jesse Gross a =C3=A9crit :
> On Tue, Jan 18, 2011 at 1:21 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le lundi 17 janvier 2011 =C3=A0 22:09 -0800, David Miller a =C3=A9c=
rit :
> >> From: Jesse Gross <jesse@nicira.com>
> >> Date: Mon, 17 Jan 2011 16:13:18 -0800
> >>
> >> > I think it is better for netif_skb_features() to actually return=
 the
> >> > correct features rather than bypass it here.  NETIF_F_HW_VLAN_TX
> >> > doesn't depend on any other offloads, so we can always include i=
t if
> >> > it is in dev->features.
> >> >
> >> > Separately, this means there is a problem with bnx2 because it a=
llows
> >> > vlan insertion to be turned off, which would have the same effec=
t.
> >> > Maybe it is looking directly at skb->protocol or similar for TSO=
=2E
> >>
> >> Please, someone cons up an acceptable fix fast.
> >>
> >
> > I just woke up, and honestly dont understand why only bnx2 is affec=
ted
> > by this problem of masking NETIF_F_HW_VLAN_TX
>=20
> If NETIF_F_HW_VLAN_TX is masked then the tag will be inserted in
> software, which is generally OK.  The problem is that some drivers
> assume that if they can do vlan tagging in hardware it will always be
> used and therefore don't expect vlan tags when setting up TSO, etc.
>=20

OK, but then this driver gave us the hint core network was actually
always doing software vlan, tagging ;)

> >
> > And I dont understand all this netif_skb_features() stuff : if we w=
ant
> > to actually test dev->features & NETIF_F_HW_VLAN_TX, and this flag
> > doesnt depend on other offloads, why are we doing features &
> > vlan_features.
>=20
> The idea is to put all of the logic in one place rather than having
> pieces that are really interdependent scattered around in the
> different offloads.  So we could test dev->features directly for vlan=
s
> but I would rather just have netif_skb_features() return the right
> values to start off with.
>=20
> >
> > Jesse, I dont understand why you say "bnx2 allows vlan insertion to=
 be
> > turned off". Really.
>=20
> You can disable it using Ethtool, which will turn off
> NETIF_F_HW_VLAN_TX the same as this bug.
>=20
> I'm running a quick test on a patch to always allow NETIF_F_HW_VLAN_T=
X
> to be returned from netif_skb_features().

Thanks



