From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 4/6] sfc: Fix loopback self-test with
 separate_tx_channels=1
Date: Tue, 2 Oct 2012 02:28:05 +0100
Message-ID: <1349141285.2577.77.camel@bwh-desktop.uk.solarflarecom.com>
References: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17186 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752586Ab2JBB2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 21:28:08 -0400
In-Reply-To: <1349141144.2577.73.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The loopback self-test iterates over all the TX queues of channel 0,
which is not very interesting when that's an RX-only channel.

Signed-off-by: Ben Hutchings <bhutchings@solarflre.com>
---
 drivers/net/ethernet/sfc/ethtool.c  |    3 ++-
 drivers/net/ethernet/sfc/selftest.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 9df556c..cf77207 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -337,7 +337,8 @@ static int efx_fill_loopback_test(struct efx_nic *efx,
 				  unsigned int test_index,
 				  struct ethtool_string *strings, u64 *data)
 {
-	struct efx_channel *channel = efx_get_channel(efx, 0);
+	struct efx_channel *channel =
+		efx_get_channel(efx, efx->tx_channel_offset);
 	struct efx_tx_queue *tx_queue;
 
 	efx_for_each_channel_tx_queue(tx_queue, channel) {
diff --git a/drivers/net/ethernet/sfc/selftest.c b/drivers/net/ethernet/sfc/selftest.c
index 96068d1..ce72ae4 100644
--- a/drivers/net/ethernet/sfc/selftest.c
+++ b/drivers/net/ethernet/sfc/selftest.c
@@ -614,7 +614,8 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 {
 	enum efx_loopback_mode mode;
 	struct efx_loopback_state *state;
-	struct efx_channel *channel = efx_get_channel(efx, 0);
+	struct efx_channel *channel =
+		efx_get_channel(efx, efx->tx_channel_offset);
 	struct efx_tx_queue *tx_queue;
 	int rc = 0;
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
