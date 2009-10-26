From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/5] e1000e: increase swflag acquisition timeout for
	ICHx/PCH
Date: Mon, 26 Oct 2009 14:23:06 -0700
Message-ID: <20091026212306.9682.73519.stgit@localhost.localdomain>
References: <20091026212242.9682.25442.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:38012 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753015AbZJZV0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 17:26:42 -0400
In-Reply-To: <20091026212242.9682.25442.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

In some conditions (e.g. when AMT is enabled on the system), it is possible
to take an extended period of time to for the driver to acquire the sw/fw/hw
hardware semaphore used to protect against concurrent access of a shared
resource (e.g. PHY registers).  This could cause PHY registers to not get
configured properly resulting in link issues.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index ead6651..fb2222d 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -122,6 +122,8 @@
 
 #define HV_LED_CONFIG		PHY_REG(768, 30) /* LED Configuration */
 
+#define SW_FLAG_TIMEOUT    1000 /* SW Semaphore flag timeout in milliseconds */
+
 /* ICH GbE Flash Hardware Sequencing Flash Status Register bit breakdown */
 /* Offset 04h HSFSTS */
 union ich8_hws_flash_status {
@@ -599,7 +601,7 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 		goto out;
 	}
 
-	timeout = PHY_CFG_TIMEOUT * 2;
+	timeout = SW_FLAG_TIMEOUT;
 
 	extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
 	ew32(EXTCNF_CTRL, extcnf_ctrl);

