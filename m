From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 05/33] sfc: Correct interpretation of second param to ethtool phys_id()
Date: Fri, 12 Dec 2008 12:49:50 +0000
Message-ID: <20081212124950.GE10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:52795 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756823AbYLLMtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:49:53 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A value of 0 means indefinite repetition (until interrupted).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index cd92c4d..9c533e0 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -182,12 +182,16 @@ static struct efx_ethtool_stat efx_ethtool_stats[] = {
  */
 
 /* Identify device by flashing LEDs */
-static int efx_ethtool_phys_id(struct net_device *net_dev, u32 seconds)
+static int efx_ethtool_phys_id(struct net_device *net_dev, u32 count)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
 	efx->board_info.blink(efx, 1);
-	schedule_timeout_interruptible(seconds * HZ);
+	set_current_state(TASK_INTERRUPTIBLE);
+	if (count)
+		schedule_timeout(count * HZ);
+	else
+		schedule();
 	efx->board_info.blink(efx, 0);
 	return 0;
 }
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
