From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH 11/12] sfc: Only count bad packets in rx_errors
Date: Tue, 8 Jun 2010 02:20:06 -0700
Message-ID: <2DFD360E328B3941911E6D28B085D990107C9DA893@SJEXCHCCR01.corp.ad.broadcom.com>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
 <1275427265.2114.35.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Ben Hutchings" <bhutchings@solarflare.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1706 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752012Ab0FHJUU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 05:20:20 -0400
In-Reply-To: <1275427265.2114.35.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Different drivers include different errors in stats->rx_errors:

  bxn2	  bnx2x	  ixgbx	  sfc		  dnet	  atlx
----------------------------------------------------------------------
rx_length	rx_length	rx_length	rx_length	rx_length	rx_length
rx_over	rx_over							rx_over
rx_frame	rx_frame			rx_frame	rx_frame	rx_frame
rx_crc	rx_crc	rx_crc	rx_crc			rx_crc
		rx_fifo							rx_fifo
		rx_missed							rx_missed
						rx_symbol
								unsup_opcd
----------------------------------------------------------------------
Is there any documentation which defines what should this statistic include?

Thanks
Dmitry


-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Ben Hutchings
Sent: Wednesday, June 02, 2010 12:21 AM
To: David Miller
Cc: netdev@vger.kernel.org; linux-net-drivers@solarflare.com
Subject: [PATCH 11/12] sfc: Only count bad packets in rx_errors

rx_errors is defined as 'bad packets received', but we are currently
including various overflow errors as well.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index aae3347..26b0cc2 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1518,11 +1518,8 @@ static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
 	stats->tx_window_errors = mac_stats->tx_late_collision;
 
 	stats->rx_errors = (stats->rx_length_errors +
-			    stats->rx_over_errors +
 			    stats->rx_crc_errors +
 			    stats->rx_frame_errors +
-			    stats->rx_fifo_errors +
-			    stats->rx_missed_errors +
 			    mac_stats->rx_symbol_error);
 	stats->tx_errors = (stats->tx_window_errors +
 			    mac_stats->tx_bad);
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


