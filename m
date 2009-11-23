From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 2/5] be2net: Fix rx_drops_no_fragments stat
 being incorrectly indexed
Date: Mon, 23 Nov 2009 13:31:31 +0530
Message-ID: <20091123080131.GA7754@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:44114 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752576AbZKWIBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 03:01:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 919fd82..d309f67 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -170,7 +170,8 @@ void netdev_stats_update(struct be_adapter *adapter)
 		port_stats->rx_udp_checksum_errs;
 
 	/*  no space in linux buffers: best possible approximation */
-	dev_stats->rx_dropped = erx_stats->rx_drops_no_fragments[0];
+	dev_stats->rx_dropped =
+		erx_stats->rx_drops_no_fragments[adapter->rx_obj.q.id];
 
 	/* detailed rx errors */
 	dev_stats->rx_length_errors = port_stats->rx_in_range_errors +
-- 
1.6.5.2

