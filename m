From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [PATCH] mlx4_en: Select PTP_1588_CLOCK
Date: Tue,  7 Jan 2014 12:49:17 -0600
Message-ID: <1389120557-6773-1-git-send-email-shawn.bohrer@gmail.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, tomk@rgmadvisors.com,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:47967 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaAGStf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 13:49:35 -0500
Received: by mail-oa0-f49.google.com with SMTP id n16so599973oag.36
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 10:49:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>

Now that mlx4_en includes a PHC driver it must select PTP_1588_CLOCK.

   drivers/built-in.o: In function `mlx4_en_get_ts_info':
>> en_ethtool.c:(.text+0x391a11): undefined reference to `ptp_clock_index'
   drivers/built-in.o: In function `mlx4_en_remove_timestamp':
>> (.text+0x397913): undefined reference to `ptp_clock_unregister'
   drivers/built-in.o: In function `mlx4_en_init_timestamp':
>> (.text+0x397b20): undefined reference to `ptp_clock_register'

Fixes: ad7d4eaed995d ("mlx4_en: Add PTP hardware clock")
Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
---
 drivers/net/ethernet/mellanox/mlx4/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
index eb520ab..563495d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -6,6 +6,7 @@ config MLX4_EN
 	tristate "Mellanox Technologies 10Gbit Ethernet support"
 	depends on PCI
 	select MLX4_CORE
+	select PTP_1588_CLOCK
 	---help---
 	  This driver supports Mellanox Technologies ConnectX Ethernet
 	  devices.
-- 
1.7.7.6
