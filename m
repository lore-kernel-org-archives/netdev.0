From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC] Inconsistency in MDIO ioctl behaviour
Date: Thu, 03 Sep 2009 22:04:46 +0100
Message-ID: <1252011886.2781.45.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:60896 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932262AbZICVEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 17:04:45 -0400
Received: from [82.69.137.158] (helo=opal.uk.level5networks.com)
	by smarthost03.mail.zen.net.uk with esmtp (Exim 4.63)
	(envelope-from <bhutchings@solarflare.com>)
	id 1MjJU7-0007sD-3h
	for netdev@vger.kernel.org; Thu, 03 Sep 2009 21:04:47 +0000
Received: from [10.17.20.50] (achroite.uk.level5networks.com [10.17.20.50])
	by opal.uk.level5networks.com (8.12.8/8.12.8) with ESMTP id n83L4k6r001064
	for <netdev@vger.kernel.org>; Thu, 3 Sep 2009 22:04:46 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While comparing the various implementations of SIOC{G,S}MIIREG and
SIOCGMIIPHY, I found some differences in behaviour that could make some
applications unreliable across different drivers.

1. Implementations of SIOCGMIIPHY must set phy_id to the PHY's MDIO
address (PRTAD) or to a dummy address if there is no real MDIO bus.
Many implementations, including the generic ones (mii, phylib,
pci-skeleton and now mdio) then proceed as for SIOCGMIIPHY.  Others
return without accessing any registers.  Which behaviour is right?

2. Implementations of=EF=BB=BF SIOC{G,S}MIIREG that do not support acce=
ss to
arbitary MDIO addresses handle non-matching values of phy_id in at leas=
t
three different ways:
(a) ignore it and always use the expected PHY address
(b) ignore writes and return a dummy value for reads
(c) fail
I favour behaviour (c) but I'm not sure what the error code should be.
ENODEV, EINVAL or EIO?

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

