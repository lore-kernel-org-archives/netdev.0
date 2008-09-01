From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 26/52] sfc: Make efx_for_each_channel_rx_queue() more efficient
Date: Mon, 1 Sep 2008 12:47:57 +0100
Message-ID: <20080901114756.GT7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:38629 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759624AbYIALr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:47:59 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently each channel can have at most one RX queue, so go straight to
that one.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index b5649b1..74e934c 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -853,9 +853,9 @@ struct efx_nic_type {
 
 /* Iterate over all RX queues belonging to a channel */
 #define efx_for_each_channel_rx_queue(_rx_queue, _channel)		\
-	for (_rx_queue = &_channel->efx->rx_queue[0];			\
-	     _rx_queue < &_channel->efx->rx_queue[EFX_MAX_RX_QUEUES];	\
-	     _rx_queue++)						\
+	for (_rx_queue = &_channel->efx->rx_queue[_channel->channel];	\
+	     _rx_queue;							\
+	     _rx_queue = NULL)						\
 		if (_rx_queue->channel != _channel)			\
 			continue;					\
 		else
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

