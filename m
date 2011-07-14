From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 06/10] net: remove NETIF_F_ALL_TX_OFFLOADS
Date: Thu, 14 Jul 2011 23:54:01 +0200
Message-ID: <20110714215401.GA17618@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
 <7750f18707f8ebc674a830555b0227c49cbfd608.1310601401.git.mirq-linux@rere.qmqm.pl>
 <20110714.144314.1353889855984029341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:55321 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754938Ab1GNVyD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 17:54:03 -0400
Content-Disposition: inline
In-Reply-To: <20110714.144314.1353889855984029341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2011 at 02:43:14PM -0700, David Miller wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)
>=20
> > There is no software fallback implemented for SCTP or FCoE checksum=
ming,
> > and so it should not be passed on by software devices like bridge o=
r bonding.
> >=20
> > For VLAN devices, this is different. First, the driver for underlyi=
ng device
> > should be prepared to get offloaded packets even when the feature i=
s disabled
> > (especially if it advertises it in vlan_features). Second, devices =
under
> > VLANs do not get replaced without tearing down the VLAN first.
> >=20
> > This fixes a mess I accidentally introduced while converting bondin=
g to
> > ndo_fix_features.
> >=20
> > NETIF_F_SOFT_FEATURES are removed from BOND_VLAN_FEATURES because t=
hey
> > are unused as of commit 712ae51afd.
> >=20
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
>=20
> This is not the answer.
>=20
> We have to implement software fallbacks for the checksum offloads.
>=20
> That is easier than having this ever growing set of exceptions for
> feature bit propagation, which at best will end up being a steaming
> pile of unmaintainable poo.

I agree about the fallbacks, but this patch is about fixing a regressio=
n
that's going to hit 3.0. Now all bonding devices always advertise e.g.
SCTP_CSUM. Sorry if I was unclear about this.

Best Regards,
Micha=B3 Miros=B3aw
