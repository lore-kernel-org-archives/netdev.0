From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/52] sfc: XMAC statistics fix-ups
Date: Mon, 1 Sep 2008 12:46:10 +0100
Message-ID: <20080901114609.GB7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:60677 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755279AbYIALqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:46:12 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Exclude assumed size of RX control frames from rx_bad_bytes.

Exclude assumed size of TX control frames from tx_good_bytes for
consistency with rx_good_bytes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_xmac.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 55c0d97..ab114b4 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -554,9 +554,11 @@ void falcon_update_stats_xmac(struct efx_nic *efx)
 
 	/* Update derived statistics */
 	mac_stats->tx_good_bytes =
-		(mac_stats->tx_bytes - mac_stats->tx_bad_bytes);
+		(mac_stats->tx_bytes - mac_stats->tx_bad_bytes -
+		 mac_stats->tx_control * 64);
 	mac_stats->rx_bad_bytes =
-		(mac_stats->rx_bytes - mac_stats->rx_good_bytes);
+		(mac_stats->rx_bytes - mac_stats->rx_good_bytes -
+		 mac_stats->rx_control * 64);
 }
 
 int falcon_check_xmac(struct efx_nic *efx)
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

