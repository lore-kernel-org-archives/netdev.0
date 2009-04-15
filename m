From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH -next] sfc: Use correct macro to set event bitfield
Date: Wed, 15 Apr 2009 02:29:52 +0100
Message-ID: <1239758992.3203.13.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:41634 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752300AbZDOB36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 21:29:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

falcon_sim_phy_event() used EFX_OWORD_FIELD, which operates on
bitfields in 128-bit values, on an event, which is a 64-bit value.
This should be harmless - these macros always use little-endian
ordering, so it would read and write back the following 8 bytes
unchanged - but it is obviously wrong.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index d4629ab..466a8ab 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1176,9 +1176,9 @@ void falcon_sim_phy_event(struct efx_nic *efx)
 
 	EFX_POPULATE_QWORD_1(phy_event, EV_CODE, GLOBAL_EV_DECODE);
 	if (EFX_IS10G(efx))
-		EFX_SET_OWORD_FIELD(phy_event, XG_PHY_INTR, 1);
+		EFX_SET_QWORD_FIELD(phy_event, XG_PHY_INTR, 1);
 	else
-		EFX_SET_OWORD_FIELD(phy_event, G_PHY0_INTR, 1);
+		EFX_SET_QWORD_FIELD(phy_event, G_PHY0_INTR, 1);
 
 	falcon_generate_event(&efx->channel[0], &phy_event);
 }

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

