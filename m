From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH net] net: netcp: fix check of requested timestamping filter
Date: Mon, 15 May 2017 16:04:36 +0200
Message-ID: <20170515140436.12175-1-mlichvar@redhat.com>
Cc: WingMan Kwok <w-kwok2@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49852 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932677AbdEOOEu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 10:04:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver doesn't support timestamping of all received packets and
should return error when trying to enable the HWTSTAMP_FILTER_ALL
filter.

Cc: WingMan Kwok <w-kwok2@ti.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 drivers/net/ethernet/ti/netcp_ethss.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 897176f..dd92950 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -2651,7 +2651,6 @@ static int gbe_hwtstamp_set(struct gbe_intf *gbe_intf, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_NONE:
 		cpts_rx_enable(cpts, 0);
 		break;
-	case HWTSTAMP_FILTER_ALL:
 	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
-- 
2.9.3
