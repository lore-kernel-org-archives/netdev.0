From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 18:00:30 +0200
Message-ID: <1278604830.2651.32.camel@edumazet-laptop>
References: <1278522874.5906.9.camel@edumazet-laptop>
	 <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
	 <1278571587.2543.9.camel@edumazet-laptop>
	 <1278581971.2651.10.camel@edumazet-laptop>
	 <1278603804.16013.24.camel@achroite.uk.solarflarecom.com>
	 <1278604198.16013.35.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65156 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757870Ab0GHQAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 12:00:35 -0400
Received: by wyf23 with SMTP id 23so681434wyf.19
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 09:00:34 -0700 (PDT)
In-Reply-To: <1278604198.16013.35.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 juillet 2010 =C3=A0 16:49 +0100, Ben Hutchings a =C3=A9crit=
 :
> On Thu, 2010-07-08 at 16:43 +0100, Ben Hutchings wrote:
> > On Thu, 2010-07-08 at 11:39 +0200, Eric Dumazet wrote:
> > > When we need to shape traffic with low speeds, we need to disable=
 tso on
> > > network interface :
> > >=20
> > > ethtool -K eth0.2240 tso off
> > >=20
> > > It seems vlan interfaces miss the set_tso() ethtool method.
> > > Propagating tso changes from lower device is not always wanted, s=
ome
> > > vlans want TSO on, others want TSO off.
> [...]
> > I think the vlan driver should also have a netdev notifier to handl=
e
> > feature changes on the underlying device.
>=20
> To clarify, I think offload features should be disabled on a vlan dev=
ice
> if they are later disabled on the underlying device.  Propagating
> changes to enable features, as you say, might not be wanted.

OK, but isnt it already done ?

Check vlan_transfer_features() in net/8021q/vlan.c


# ethtool -k eth3|grep tcp-segmentation
tcp-segmentation-offload: on
# ethtool -k eth3.103|grep tcp-segmentation
tcp-segmentation-offload: on

# ethtool -K eth3 tso off

# ethtool -k eth3|grep tcp-segmentation
tcp-segmentation-offload: off
# ethtool -k eth3.103|grep tcp-segmentation
tcp-segmentation-offload: off

# ethtool -K eth3 tso on
# ethtool -k eth3.103|grep tcp-segmentation
tcp-segmentation-offload: on


We should not change it to avoid ORing TSO, it might break some setups.



