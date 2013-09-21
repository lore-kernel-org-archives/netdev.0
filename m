From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 2/2] sfc: Increase MCDI status timeout to 250ms
Date: Sat, 21 Sep 2013 18:47:26 +0100
Message-ID: <1379785646.1681.23.camel@bwh-desktop.uk.level5networks.com>
References: <1379785504.1681.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19862 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979Ab3IURr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 13:47:29 -0400
In-Reply-To: <1379785504.1681.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The SFC9120 MC firmware often takes longer than 20ms to reboot and
update the warm boot count in BIU_MC_SFT_STATUS_REG.  A timeout of
250ms is very generous for an MC reboot.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 73143ec..c082562 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -27,10 +27,10 @@
 
 /* A reboot/assertion causes the MCDI status word to be set after the
  * command word is set or a REBOOT event is sent. If we notice a reboot
- * via these mechanisms then wait 20ms for the status word to be set.
+ * via these mechanisms then wait 250ms for the status word to be set.
  */
 #define MCDI_STATUS_DELAY_US		100
-#define MCDI_STATUS_DELAY_COUNT		200
+#define MCDI_STATUS_DELAY_COUNT		2500
 #define MCDI_STATUS_SLEEP_MS						\
 	(MCDI_STATUS_DELAY_US * MCDI_STATUS_DELAY_COUNT / 1000)
 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
