From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 1/5] sfc: Minimal support for 40G link speed
Date: Tue, 17 Sep 2013 01:11:47 +0100
Message-ID: <1379376707.1945.12.camel@bwh-desktop.uk.level5networks.com>
References: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21844 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab3IQALu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 20:11:50 -0400
In-Reply-To: <1379376611.1945.11.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Accept and handle 40G link events.

Accept ethtool link settings of speed == 40000 && duplex, and set the
appropriate MCDI PHY capability.

This does not include reporting of 40G media types, as those have not
yet been assigned numbers in the MCDI protocol.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/Kconfig     | 2 +-
 drivers/net/ethernet/sfc/mcdi_port.c | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index 8b71525..0889212 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -7,7 +7,7 @@ config SFC
 	select I2C_ALGOBIT
 	select PTP_1588_CLOCK
 	---help---
-	  This driver supports 10-gigabit Ethernet cards based on
+	  This driver supports 10/40-gigabit Ethernet cards based on
 	  the Solarflare SFC4000, SFC9000-family and SFC9100-family
 	  controllers.
 
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 8d33da6..7b6be61 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -556,6 +556,7 @@ static int efx_mcdi_phy_set_settings(struct efx_nic *efx, struct ethtool_cmd *ec
 		case 100:   caps = 1 << MC_CMD_PHY_CAP_100FDX_LBN;   break;
 		case 1000:  caps = 1 << MC_CMD_PHY_CAP_1000FDX_LBN;  break;
 		case 10000: caps = 1 << MC_CMD_PHY_CAP_10000FDX_LBN; break;
+		case 40000: caps = 1 << MC_CMD_PHY_CAP_40000FDX_LBN; break;
 		default:    return -EINVAL;
 		}
 	} else {
@@ -841,6 +842,7 @@ static unsigned int efx_mcdi_event_link_speed[] = {
 	[MCDI_EVENT_LINKCHANGE_SPEED_100M] = 100,
 	[MCDI_EVENT_LINKCHANGE_SPEED_1G] = 1000,
 	[MCDI_EVENT_LINKCHANGE_SPEED_10G] = 10000,
+	[MCDI_EVENT_LINKCHANGE_SPEED_40G] = 40000,
 };
 
 void efx_mcdi_process_link_change(struct efx_nic *efx, efx_qword_t *ev)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
