From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 00/12] DSA Mavell drivers refactoring and cleanup
Date: Thu,  2 Apr 2015 03:21:47 +0200
Message-ID: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35730 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107AbbDBB0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 21:26:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a collection of patches again net-next from today containing
refactoring and consolidate of code, cleanups and using #define's to
replace register numbers.

Patch #1 Swaps the 6131 driver to use the consolidated setup code.

Patch #2 Moves the Switch IDs used during probe into a central
         location.  We need these later so that we can differentiate
         the different features the devices have.

Patch #3 Makes the 6131 driver set the number of ports in the private
         state structure. It then uses this, rather than hard coded
         maximum number of ports.

Patch #4 Similar to Patch #3, but for the 6123_61_65 driver.

Patch #5 Similar to Patch #3, and #4, but for all the remaining
         drivers.  This greatly increases the similarity of the code
         between drivers, allow further patches to consolidate the
         duplicated code.

Patch #6 Consolidate the switch reset code, which has two minor
         variants. Removes around 35 lines per driver.

Patch #7 Moves phy page access functions out of the 6352 driver into
         the shared code. Currently only the 6352 driver uses this,
         but it is likely other devices will come along wanting this
         functionality.

Patch #8 Consolidates the code used to access phy registers. Removes
         around 40 lines of code per driver.

Patch #9 Fixes missing mutex locking in the EEE code, and refactors
         the code a bit to make it more understandable with respect to
         locks.

Patch #10 Consolidates reading statistics. This is very similar code
          for all devices, but the number of available statistics
          differ, which can be determined from the product ID. Removes
	  around 65 lines per driver.

Patch #11 Add #defines for registers, and bits within the
          registers. For the moment, this is limited to the shared
          code. The individual drivers will be converted once the
          remaining duplicated code is consolidated

Patch #12 Fix broken statistic counters on the 6172. The 6352 family
          requires the port number is poked into a different set of
          bits in the register compared to other devices.

Many thanks to Guenter Roeck for repeatedly reviewing the patches and
testing them on his hardware.

	Andrew

Andrew Lunn (8):
  net: dsa: Consistently set and use ps->num_ports
  net: dsa: Centralize Marvell switch reset
  net: dsa: Move phy page access functions into shared code
  net: dsa: Consolidate phy read and write functions
  net: dsa: mv88e6xxx: Add missing mutex's in EEE operations.
  net: dsa: Consolidate getting the statistics
  net: dsa: Use mnemonics rather than register numbers
  net: dsa: mv88e6xxx: Fix stats counters for 6352 family

Guenter Roeck (4):
  net: dsa: mv88e6131: Use common initialization functions
  net: dsa: mv88e6xxx: Move switch product IDs into common include file
  net: dsa: mv88e6131: Determine and use number of switch ports
  net: dsa: mv88e6123_61_65: Determine and use number of switch ports

 drivers/net/dsa/mv88e6123_61_65.c | 170 +++---------
 drivers/net/dsa/mv88e6131.c       | 182 ++++---------
 drivers/net/dsa/mv88e6171.c       | 166 ++----------
 drivers/net/dsa/mv88e6352.c       | 205 ++-------------
 drivers/net/dsa/mv88e6xxx.c       | 531 +++++++++++++++++++++++++++++---------
 drivers/net/dsa/mv88e6xxx.h       | 238 ++++++++++++++---
 6 files changed, 728 insertions(+), 764 deletions(-)

-- 
2.1.4
