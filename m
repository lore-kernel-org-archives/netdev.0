From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/10] net: remove NETIF_F_ALL_TX_OFFLOADS
Date: Thu, 14 Jul 2011 14:43:14 -0700 (PDT)
Message-ID: <20110714.144314.1353889855984029341.davem@davemloft.net>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	<7750f18707f8ebc674a830555b0227c49cbfd608.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320Ab1GNVpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2011 17:45:36 -0400
In-Reply-To: <7750f18707f8ebc674a830555b0227c49cbfd608.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)

> There is no software fallback implemented for SCTP or FCoE checksummi=
ng,
> and so it should not be passed on by software devices like bridge or =
bonding.
>=20
> For VLAN devices, this is different. First, the driver for underlying=
 device
> should be prepared to get offloaded packets even when the feature is =
disabled
> (especially if it advertises it in vlan_features). Second, devices un=
der
> VLANs do not get replaced without tearing down the VLAN first.
>=20
> This fixes a mess I accidentally introduced while converting bonding =
to
> ndo_fix_features.
>=20
> NETIF_F_SOFT_FEATURES are removed from BOND_VLAN_FEATURES because the=
y
> are unused as of commit 712ae51afd.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

This is not the answer.

We have to implement software fallbacks for the checksum offloads.

That is easier than having this ever growing set of exceptions for
feature bit propagation, which at best will end up being a steaming
pile of unmaintainable poo.
