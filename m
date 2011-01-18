From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] bnx2 + vlan + TSO : doesnt work
Date: Tue, 18 Jan 2011 07:21:30 +0100
Message-ID: <1295331690.3362.522.camel@edumazet-laptop>
References: <1295308844.3362.135.camel@edumazet-laptop>
	 <1295309365.6264.23.camel@bwh-desktop>
	 <AANLkTincFt4fKLvtity=MgQ2+cuvNFrBHqu3+bMLsypc@mail.gmail.com>
	 <20110117.220927.189715926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse@nicira.com, bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57666 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab1ARGVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 01:21:36 -0500
Received: by wyb28 with SMTP id 28so5776993wyb.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 22:21:35 -0800 (PST)
In-Reply-To: <20110117.220927.189715926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 janvier 2011 =C3=A0 22:09 -0800, David Miller a =C3=A9crit =
:
> From: Jesse Gross <jesse@nicira.com>
> Date: Mon, 17 Jan 2011 16:13:18 -0800
>=20
> > I think it is better for netif_skb_features() to actually return th=
e
> > correct features rather than bypass it here.  NETIF_F_HW_VLAN_TX
> > doesn't depend on any other offloads, so we can always include it i=
f
> > it is in dev->features.
> >=20
> > Separately, this means there is a problem with bnx2 because it allo=
ws
> > vlan insertion to be turned off, which would have the same effect.
> > Maybe it is looking directly at skb->protocol or similar for TSO.
>=20
> Please, someone cons up an acceptable fix fast.
>=20

I just woke up, and honestly dont understand why only bnx2 is affected
by this problem of masking NETIF_F_HW_VLAN_TX

And I dont understand all this netif_skb_features() stuff : if we want
to actually test dev->features & NETIF_F_HW_VLAN_TX, and this flag
doesnt depend on other offloads, why are we doing features &
vlan_features.

Jesse, I dont understand why you say "bnx2 allows vlan insertion to be
turned off". Really.



