From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Fixed PHY Device Tree usage?
Date: Tue, 9 Jul 2013 18:33:12 +0200
Message-ID: <20130709183312.6c4d052d@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:36670 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab3GIQdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 12:33:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We have a case of an hardware platform that uses the mvneta network
driver, but instead of the SoC being connected to a PHY, it's connected
directly to a switch, so my understanding is that there's no MDIO bus,
and we should have a kind of a "fake PHY" to make the mvneta driver
believe that the link is up, at a given speed.

Looking at this problem, I stumbled across the "fixed PHY" driver in
drivers/net/phy/fixed.c, which registers a fake "Fixed MDIO bus", and
then provides a fixed_phy_add() API to add one "fake" PHY. This seems
to fit my need, except that my ARM platform is obviously Device Tree
based, so I'm wondering what I should do. One option is to implement a
Device Tree binding for the fixed PHY driver (the exact DT binding
would have to be discussed), but I'm wondering whether describing a
fixed PHY in the DT is actually correct, because describing a fixed PHy
is not really describing the hardware, the hardware is actually a
switch.

Do you have some thoughts about this situation? Maybe there's already
some solutions that I'm not aware of?

Thanks,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
