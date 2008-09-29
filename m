From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [RFC,PATCHv2 0/6] support for DSA hardware ethernet switch chips
Date: Mon, 29 Sep 2008 04:37:28 +0200
Message-ID: <20080929023728.GF21560@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Tim Ellis <tim.ellis@mac.com>,
	Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>, Nicolas Pitre <nico@cam.org>,
	Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48966 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbYI2Cha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2008 22:37:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds support for hardware ethernet switches that use
the DSA (Distributed Switch Architecture) protocol.  These chips are
typically used in access points and DSL routers and such, where they
sit between the CPU's ethernet port and the external ethernet ports
on the box (typically 4 LAN ports and 1 WAN port).

This patch set supports the Marvell 88E6060/6131/6123/6161/6165
switch chips.  But since most of these chips work in very similar
ways, support for other brands and models of switches should not be
hard to add.

This series goes on top of the "[RFC,PATCH 0/3] phylib: give mdio
buses a device tree presence" series just posted.

Differences between v1 and v2:
- Trim unnecessary includes.

- Get rid of tagging format masks -- each switch driver now supports
  one tag format only, and selects that format in Kconfig.

- Fix race window where received tagged packets could be treated as
  untagged packets between configuring the switch and setting up
  receive DSA state.

- Use round_jiffies() for link poll timer.  (Nicolas Pitre)

- Convert the DSA slave device handling to deal with dynamically
  allocated mii buses.

- Introduce REG_READ/REG_WRITE macros to avoid having to check the
  return values of reg_read/reg_write for every single access.
  (Nicolas Pitre)

- Split marvell.c into a common part (mv88e6xxx.c) and drivers for
  individual chip families (for now, 6123/6161/6165 and 6131).  This
  makes it easier to add support for new switch chip families.

- Make it optional for the switch driver to provide hardware
  statistics.  (E.g. the 6060 doesn't have hardware statistics
  counters.)

- Add support for the Marvell 88E6060 ethernet switch register set,
  and the tagging format it uses (Trailer).  Tested on a Thecus n1200
  (http://www.thecus.com/products_over.php?cid=12&pid=24
  http://thecus.nas-central.org/index.php/Category:N1200), where the
  switch chip is hooked up to a Freescale mpc8347 using the gianfar
  driver.  (I.e. it works with ethernet drivers other than mv643xx_eth.)
  (There _is_ an issue with the gianfar hooking up to the PHY for the
  first switch port, and refusing to send/receive data to ports 2-4 if
  port 1 isn't up.)
