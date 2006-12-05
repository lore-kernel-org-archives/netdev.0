From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] Add Broadcom PHY support
Date: Tue, 05 Dec 2006 17:03:01 +1100
Message-ID: <1165298581.29784.58.camel@localhost.localdomain>
References: <E1GrTGu-0005QS-OH@lucciola>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:46862 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968296AbWLEGDN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 01:03:13 -0500
To: Amy Fong <amy.fong@windriver.com>
In-Reply-To: <E1GrTGu-0005QS-OH@lucciola>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I believe that this fiber enabling can be done by defining config_init in the phy_driver struct.
> 
> struct phy_driver {
> <snip>
>         /* Called to initialize the PHY,
> 	 * including after a reset */
> 	int (*config_init)(struct phy_device *phydev);
> <snip>
> };

Well... I don't know for sure... thing is, enabling the fiber mode is a
rather platform specific thing. So it's the MAC driver that knows wether
it wants it on a PHY and should call into the driver.

It's difficult to abstract all possible PHY config options tho... some
MACs might want to enable low power, some don't because they have issues
with it, that sort of thing, though.

Not sure what the best solution is at this point... Maybe an ascii
string to pass the PHY driver is the most flexible, though a bit yucky,
or we try to have a list of all the possible configuration options in
phy.h and people just add new ones that they need as they add support
for them...

Sounds grossly like an in-kernel ioctl tho...

Ben.


