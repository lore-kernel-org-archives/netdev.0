From: Haicheng Li <haicheng.li@linux.intel.com>
Subject: [PATCH 1/2] Fix build error caused by broken PCH_PTP module dependency.
Date: Tue, 25 Sep 2012 08:23:27 +0800
Message-ID: <5060F97F.3040809@linux.intel.com>
References: <506009A4.8000202@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Takahiroi Shimizu <tshimizu818@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	haicheng.lee@gmail.com
To: Haicheng Li <haicheng.li@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4865 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171Ab2IYAXa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 20:23:30 -0400
In-Reply-To: <506009A4.8000202@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From 898e3214b3406c620571cedf704719784b0df049 Mon Sep 17 00:00:00 2001
From: Haicheng Li <haicheng.li@linux.intel.com>
Date: Mon, 24 Sep 2012 15:52:30 +0800
Subject: [PATCH 1/2] Fix build error caused by broken PCH_PTP module dependency.

The .config is:
         CONFIG_PCH_GBE=y
         CONFIG_PCH_PTP=y
         CONFIG_PTP_1588_CLOCK=m

The build error:

drivers/built-in.o: In function `pch_tx_timestamp':
.../pch_gbe_main.c:215: undefined reference to `pch_ch_event_read'
.../pch_gbe_main.c:225: undefined reference to `pch_tx_snap_read'
.../pch_gbe_main.c:231: undefined reference to `pch_ch_event_write'

.../pch_gbe_main.c:170: undefined reference to `pch_ch_event_read'
.../pch_gbe_main.c:175: undefined reference to `pch_src_uuid_lo_read'
.../pch_gbe_main.c:176: undefined reference to `pch_src_uuid_hi_read'
.../pch_gbe_main.c:190: undefined reference to `pch_ch_event_write'
.../pch_gbe_main.c:184: undefined reference to `pch_rx_snap_read'

.../pch_gbe_main.c:267: undefined reference to `pch_ch_control_write'
.../pch_gbe_main.c:271: undefined reference to `pch_ch_control_write'
.../pch_gbe_main.c:275: undefined reference to `pch_ch_control_write'
.../pch_gbe_main.c:281: undefined reference to `pch_ch_control_write'
.../pch_gbe_main.c:283: undefined reference to `pch_set_station_address'
.../pch_gbe_main.c:290: undefined reference to `pch_ch_event_write'

Signed-off-by: Haicheng Li <haicheng.lee@gmail.com>
---
  drivers/net/ethernet/oki-semi/pch_gbe/Kconfig |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig 
b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index bce0164..6c8aed4 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -26,7 +26,7 @@ if PCH_GBE
  config PCH_PTP
  	bool "PCH PTP clock support"
  	default n
-	depends on PTP_1588_CLOCK_PCH
+	depends on PTP_1588_CLOCK_PCH = PCH_GBE
  	---help---
  	  Say Y here if you want to use Precision Time Protocol (PTP) in the
  	  driver. PTP is a method to precisely synchronize distributed clocks
-- 
1.7.1
