From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 2/3] net: introduce ptp one step time stamp mode for sync packets
Date: Tue, 20 Sep 2011 13:43:15 +0200
Message-ID: <281263db8afa67874df99fd7819715c6acd0851a.1316518333.git.richard.cochran@omicron.at>
References: <cover.1316518332.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55213 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755366Ab1ITLnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 07:43:06 -0400
Received: by mail-ey0-f174.google.com with SMTP id 28so124723eya.19
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2011 04:43:05 -0700 (PDT)
In-Reply-To: <cover.1316518332.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1316518332.git.richard.cochran@omicron.at>
References: <cover.1316518332.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IEEE 1588 standard (PTP) has a provision for a "one step" mode, where
time stamps on outgoing event packets are inserted into the packet by the
hardware on the fly. This patch adds a new flag for the SIOCSHWTSTAMP
ioctl that lets user space programs request this mode.

Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 include/linux/net_tstamp.h |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/include/linux/net_tstamp.h b/include/linux/net_tstamp.h
index a3b8546..3df0984 100644
--- a/include/linux/net_tstamp.h
+++ b/include/linux/net_tstamp.h
@@ -60,6 +60,15 @@ enum {
 	 * before sending the packet.
 	 */
 	HWTSTAMP_TX_ON,
+
+	/*
+	 * Enables time stamping for outgoing packets just as
+	 * HWTSTAMP_TX_ON does, but also enables time stamp insertion
+	 * directly into Sync packets. In this case, transmitted Sync
+	 * packets will not received a time stamp via the socket error
+	 * queue.
+	 */
+	HWTSTAMP_TX_ONESTEP_SYNC,
 };
 
 /* possible values for hwtstamp_config->rx_filter */
-- 
1.7.2.5
