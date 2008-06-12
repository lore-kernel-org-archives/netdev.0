From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [RESEND] [PATCH] atl1: relax eeprom mac address error check
Date: Thu, 12 Jun 2008 17:04:54 -0500
Message-ID: <20080612170454.3bc6f096@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: advantis@gmx.net, csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([207.115.11.54]:56631 "EHLO
	fmailhost04.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752623AbYFLWE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 18:04:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Radu Cristescu <advantis@gmx.net>

The atl1 driver tries to determine the MAC address thusly:

	- If an EEPROM exists, read the MAC address from EEPROM and
	  validate it.
	- If an EEPROM doesn't exist, try to read a MAC address from
	  SPI flash.
	- If that fails, try to read a MAC address directly from the
	  MAC Station Address register.
	- If that fails, assign a random MAC address provided by the
	  kernel.

We now have a report of a system fitted with an EEPROM containing all
zeros where we expect the MAC address to be, and we currently handle
this as an error condition.  Turns out, on this system the BIOS writes
a valid MAC address to the NIC's MAC Station Address register, but we
never try to read it because we return an error when we find the all-
zeros address in EEPROM.

This patch relaxes the error check and continues looking for a MAC
address even if it finds an illegal one in EEPROM.

Signed-off-by: Radu Cristescu <advantis@gmx.net>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 99e0b4c..3c798ae 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -471,7 +471,6 @@ static int atl1_get_permanent_address(struct
atl1_hw *hw) memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
 			return 0;
 		}
-		return 1;
 	}
 
 	/* see if SPI FLAGS exist ? */
-- 
1.5.5.1
