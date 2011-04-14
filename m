From: Michael Riesch <michael@riesch.at>
Subject: RE: SMSC 8720a/MDIO/PHY help.
Date: Thu, 14 Apr 2011 23:39:21 +0200
Message-ID: <1302817161.2742.42.camel@malcolm>
References: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E632@EXV1.corp.adtran.com>
	 <1302729564.2742.28.camel@malcolm>
	 <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E8D4@EXV1.corp.adtran.com>
	 <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E8FD@EXV1.corp.adtran.com>
Reply-To: michael@riesch.at
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ANDY KENNEDY <ANDY.KENNEDY@adtran.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay01.ispgateway.de ([80.67.31.24]:44573 "EHLO
	smtprelay01.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753720Ab1DNVjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 17:39:25 -0400
In-Reply-To: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8E8FD@EXV1.corp.adtran.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>=20
> Along this line of though:  phy_connect requires struct net_device, w=
hich has a struct net_device_ops within it.  When I do a phy_connect am=
 I supposed to provide the minimal functions for netdev_ops (correct th=
is list if I am mistaken):
> ndo_open
> ndo_stop
> ndo_start_xmit
> ndo_get_stats
> ndo_set_multicast_list
> As well as populate the dev->dev_addr within the struct net_device.
>=20
> The part that confuses me is that the smsc.c ??driver?? under drivers=
/net/phy/smsc.c doesn=E2=80=99t do any of this.  This is a phy supporte=
d by this file, so should I have to do all this to get the device up?

The smsc.c is a PHY driver, so it is probed when the specified PHY
appears on the MDIO bus. It is responsible for the proper PHY settings
like auto-negotiation etc.

If I understood you correctly, you are writing a MDIO bus driver, the
opposite part. It provides access to the MDIO bus, the net_device
structure with its ops (and, of course, implements them as well).

With a call of PHY_connect you can stick the both of them together. And
the nice trick: Maybe your PHY is supported by the generic PHY driver
and you just need your MDIO bus driver, which provides the net_device
ops, registers the MDIO bus and calls phy_connect. (and maybe
phy_start(), I am not sure about that one).

HTH

