From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net] pasemi_mac: Fix building as module
Date: Tue, 06 Dec 2011 05:44:22 +0000
Message-ID: <1323150262.7454.247.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Olof Johansson <olof@lixom.net>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46157 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751014Ab1LFFoe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 00:44:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ded19addf9c937d83b9bfb4d73a836732569041b ('pasemic_mac*: Move
the PA Semi driver') inadvertently split pasemi_mac into two separate
modules with unresolved symbols.  Change it back into a single module.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
The build failure can currently be seen at
<https://buildd.debian.org/status/package.php?p=linux-2.6&suite=experimental>.

Ben.

 drivers/net/ethernet/pasemi/Makefile |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/pasemi/Makefile b/drivers/net/ethernet/pasemi/Makefile
index 05db543..90497ff 100644
--- a/drivers/net/ethernet/pasemi/Makefile
+++ b/drivers/net/ethernet/pasemi/Makefile
@@ -2,4 +2,5 @@
 # Makefile for the A Semi network device drivers.
 #
 
-obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o pasemi_mac_ethtool.o
+obj-$(CONFIG_PASEMI_MAC) += pasemi_mac_driver.o
+pasemi_mac_driver-objs := pasemi_mac.o pasemi_mac_ethtool.o
-- 
1.7.7.3
