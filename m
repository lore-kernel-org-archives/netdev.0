From: khalasa@piap.pl (Krzysztof =?utf-8?Q?Ha=C5=82asa?=)
Subject: Parent device of MDIO bus
Date: Wed, 13 Aug 2014 15:51:08 +0200
Message-ID: <m3egwkwl9v.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ni.piap.pl ([195.187.100.4]:46732 "EHLO ni.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145AbaHMN5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2014 09:57:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I noticed a recent change a71e3c37960ce5f9c6a519bc1215e3ba9fa83e75:
    net: phy: Set the driver when registering an MDIO bus device

    mdiobus_register() registers a device which is already bound to a driver.
    Hence, the driver pointer should be set properly in order to track down
    the driver associated to the MDIO bus.

    This will be used to allow ethernet driver to pin down a MDIO bus driver,
    preventing it from being unloaded while the PHY device is running.

Does this mean an MDIO driver must now be separate from its Ethernet
driver in order for the latter to be rmmod-able? Otherwise, the Ethernet
.probe (*_init_one()) calls mdiobus_register() and immediately bumps
refcount (for both drivers in a common module) forever.

The other option seems to be moving mdio_register() from Ethernet's
.probe() to dev->open(). This will make the driver un-rmmod-able when
the Ethernet device is open (not a big problem and we had it this way
some time ago). It will be rmmod-able again when all Ethernets are
closed.

Or am I missing something?
What do you think?
-- 
Krzysztof Halasa

Research Institute for Automation and Measurements PIAP
Al. Jerozolimskie 202, 02-486 Warsaw, Poland
