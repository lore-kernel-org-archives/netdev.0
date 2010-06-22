From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] phylib: Add autoload support for the LXT973 phy.
Date: Tue, 22 Jun 2010 13:38:13 +0100
Message-ID: <1277210293.21798.11.camel@localhost>
References: <20100531130932.GA15845@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:32959 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158Ab0FVMiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 08:38:16 -0400
In-Reply-To: <20100531130932.GA15845@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e13647c1 (phylib: Add support for the LXT973 phy.) added a new ID
but neglected to also add it to the MODULE_DEVICE_TABLE.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
When I did this stuff, I did wonder if we should make this happen
automatically somehow. I pondered some dirty macro hack in
phy_driver_register() which would do it somehow, but couldn't come up
with anything that'd work.

Removing the phy_id and phy_id_mask from struct phy_driver and having a
pointer to a match table would suck, since each driver only really
matches one device/mask. (Even where a single C file has multiple
drivers, they often differ in some methods or flags.)

The best option I can come up with right now, is probably to remove
phy_id and phy_id_mask from phy_driver and put a pointer to the driver
into the ID table, and take the ID table as the argument to
phy_driver_register(). I'm not sure I like that very much though -- I'd
prefer that we just remember to update the table and don't need to be
forced :)

(Another cheap option is to pass the ID table as an extra argument to
the existing phy_device_register(), I suppose, and it can just print a
warning if it doesn't find the same phy_id and phy_id_mask in the table)

diff --git a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
index dbd0034..29c39ff 100644
--- a/drivers/net/phy/lxt.c
+++ b/drivers/net/phy/lxt.c
@@ -226,6 +226,7 @@ module_exit(lxt_exit);
 static struct mdio_device_id lxt_tbl[] = {
 	{ 0x78100000, 0xfffffff0 },
 	{ 0x001378e0, 0xfffffff0 },
+	{ 0x00137a10, 0xfffffff0 },
 	{ }
 };
 


