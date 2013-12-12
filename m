From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/16] sfc: Demote "MC Scheduler error" messages
Date: Thu, 12 Dec 2013 22:59:15 +0000
Message-ID: <1386889155.1516.338.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43674 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562Ab3LLW7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 17:59:18 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Stonehouse <rstonehouse@solarflare.com>

The MC firmware is cooperatively multitasking and its scheduler will
send an event when a task yields after running for more than the
expected maximum time.  This can be useful for firmware development
but does not usually indicate a serious error and does not help to
detect a lockup (there is a hardware watchdog that does that).
Change the message and reduce log level accordingly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 4b0bd8a1514d..25f91c0ca6a6 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -867,8 +867,8 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 		efx_mcdi_sensor_event(efx, event);
 		break;
 	case MCDI_EVENT_CODE_SCHEDERR:
-		netif_info(efx, hw, efx->net_dev,
-			   "MC Scheduler error address=0x%x\n", data);
+		netif_dbg(efx, hw, efx->net_dev,
+			  "MC Scheduler alert (0x%x)\n", data);
 		break;
 	case MCDI_EVENT_CODE_REBOOT:
 	case MCDI_EVENT_CODE_MC_REBOOT:


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
