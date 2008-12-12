From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 27/33] sfc: Specify a meaningful component for loopback RX-side and PHY tests
Date: Fri, 12 Dec 2008 12:57:34 +0000
Message-ID: <20081212125733.GA10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:59024 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757936AbYLLM5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:57:36 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our ethtool self-test result names each begin with a component name.  For
some results this is "port0", which is not very meaningful.  Change that
to "rx" or "phy" as appropriate.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index aad0d1b..eab3e5c 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -274,8 +274,11 @@ static void efx_fill_test(unsigned int test_index,
 
 	/* Fill string, if applicable */
 	if (strings) {
-		snprintf(unit_str.name, sizeof(unit_str.name),
-			 unit_format, unit_id);
+		if (strchr(unit_format, '%'))
+			snprintf(unit_str.name, sizeof(unit_str.name),
+				 unit_format, unit_id);
+		else
+			strcpy(unit_str.name, unit_format);
 		snprintf(test_str.name, sizeof(test_str.name),
 			 test_format, test_id);
 		snprintf(strings[test_index].name,
@@ -284,7 +287,6 @@ static void efx_fill_test(unsigned int test_index,
 	}
 }
 
-#define EFX_PORT_NAME "port%d", 0
 #define EFX_CHANNEL_NAME(_channel) "chan%d", _channel->channel
 #define EFX_TX_QUEUE_NAME(_tx_queue) "txq%d", _tx_queue->queue
 #define EFX_RX_QUEUE_NAME(_rx_queue) "rxq%d", _rx_queue->queue
@@ -320,11 +322,11 @@ static int efx_fill_loopback_test(struct efx_nic *efx,
 	}
 	efx_fill_test(test_index++, strings, data,
 		      &lb_tests->rx_good,
-		      EFX_PORT_NAME,
+		      "rx", 0,
 		      EFX_LOOPBACK_NAME(mode, "rx_good"));
 	efx_fill_test(test_index++, strings, data,
 		      &lb_tests->rx_bad,
-		      EFX_PORT_NAME,
+		      "rx", 0,
 		      EFX_LOOPBACK_NAME(mode, "rx_bad"));
 
 	return test_index;
@@ -372,7 +374,7 @@ static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 	efx_fill_test(n++, strings, data, &tests->registers,
 		      "core", 0, "registers", NULL);
 	efx_fill_test(n++, strings, data, &tests->phy,
-		      EFX_PORT_NAME, "phy", NULL);
+		      "phy", 0, "bist", NULL);
 
 	/* Loopback tests */
 	for (mode = LOOPBACK_NONE; mode <= LOOPBACK_TEST_MAX; mode++) {
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
