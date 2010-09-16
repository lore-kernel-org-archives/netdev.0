From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [E1000-devel] [PATCH] net: enable GRO by default for vlan
 devices
Date: Thu, 16 Sep 2010 08:42:56 +0200
Message-ID: <1284619376.2462.95.camel@edumazet-laptop>
References: <20100915181616.578fcd37@nehalam>
	 <20100915.225146.35823170.davem@davemloft.net>
	 <20100915232125.4430a421@nehalam>
	 <20100915.233851.85414928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, bphilips@suse.de,
	e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34360 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150Ab0IPGnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 02:43:03 -0400
Received: by wyf22 with SMTP id 22so1038828wyf.19
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 23:43:02 -0700 (PDT)
In-Reply-To: <20100915.233851.85414928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 septembre 2010 =C3=A0 23:38 -0700, David Miller a =C3=A9=
crit :
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 15 Sep 2010 23:21:25 -0700
>=20
> > I think it is more complex than that. GRO is tied to NAPI,
> > and bridge/bond don't use NAPI directly. They use netif_rx() for re=
ceiving
> > because layered drivers can't directly up call because of possible
> > issues with stack depth.=20
> >=20
> > To get GRO working for netif_rx case,
> > the logic in process_backlog would have to change.
> > But this queue is processing packets from multiple devices so
> > it is not clear if GRO could be used.
>=20
> Bonding's un-layering on RX is done in the normal netif_receive_skb()
> control flow.
>=20
> And bridging only uses netif_rx for multicast replication.

Yes, bonding case should be easy, I'll take a look today.


