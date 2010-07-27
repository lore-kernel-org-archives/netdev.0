From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000e: 82577/82578 PHY register access issues
Date: Tue, 27 Jul 2010 15:28:46 -0700
Message-ID: <20100727222808.25500.11033.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	stable@kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:47375 "EHLO
	qmta10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752489Ab0G0W3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 18:29:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The MAC-PHY interconnect on 82577/82578 uses a power management feature
(called K1) which must be disabled when in 1Gbps due to a hardware issue on
these parts.  The #define bit setting used to enable/disable K1 is
incorrect and can cause PHY register accesses to stop working altogether
until the next device reset.  This patch sets the register correctly.

This issue is present in kernels since 2.6.32.

CC: stable@kernel.org
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/hw.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 5d1220d..664ed58 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -308,7 +308,7 @@ enum e1e_registers {
 #define E1000_KMRNCTRLSTA_INBAND_PARAM	0x9    /* Kumeran InBand Parameters */
 #define E1000_KMRNCTRLSTA_DIAG_NELPBK	0x1000 /* Nearend Loopback mode */
 #define E1000_KMRNCTRLSTA_K1_CONFIG	0x7
-#define E1000_KMRNCTRLSTA_K1_ENABLE	0x140E
+#define E1000_KMRNCTRLSTA_K1_ENABLE	0x0002
 #define E1000_KMRNCTRLSTA_K1_DISABLE	0x1400
 
 #define IFE_PHY_EXTENDED_STATUS_CONTROL	0x10

