From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [RFC,PATCH 0/3] phylib: give mdio buses a device tree presence
Date: Mon, 29 Sep 2008 04:13:10 +0200
Message-ID: <20080929021310.GB21560@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48072 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbYI2CNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2008 22:13:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series hooks up mdio buses (struct mii_bus) into the device
tree, so that they show up in sysfs and can be found by walking the
device tree.

The main intended user for this is the DSA switch driver, but there
might be other uses as well.

The bulk of the work is actually to convert all mii bus drivers over to
dynamic allocation of struct mii_bus (patch #2).  I'm not 100% sure that
I converted all users over correctly, I'll check this again tomorrow.
In any case, a number of users are buggy as-is (e.g. some of the bitbang
users do double-frees of their struct mii_bus on fail/deinit, etc).
