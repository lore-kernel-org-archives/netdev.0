From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC net-next 1/4] bfin_mac: only advertise hardware time stamped when enabled.
Date: Fri, 28 Sep 2012 19:20:25 +0200
Message-ID: <59a97b0f3e259fccdffef8377ae110c73590b319.1348851539.git.richardcochran@gmail.com>
References: <cover.1348851539.git.richardcochran@gmail.com>
Cc: <device-drivers-devel@blackfin.uclinux.org>,
	<uclinux-dist-devel@blackfin.uclinux.org>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Patrick Ohly <patrick.ohly@intel.com>,
	Sonic Zhang <sonic.zhang@analog.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:39275 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757648Ab2I1RUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 13:20:48 -0400
Received: by weyt9 with SMTP id t9so1566344wey.19
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2012 10:20:46 -0700 (PDT)
In-Reply-To: <cover.1348851539.git.richardcochran@gmail.com>
In-Reply-To: <cover.1348851539.git.richardcochran@gmail.com>
References: <cover.1348851539.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware time stamping code is a compile time option for the blackfin.
When it is not enabled, the driver should fall back to the standard
ethtool reply to the get_ts_info query.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index f816426..2349abb 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -548,6 +548,7 @@ static int bfin_mac_ethtool_setwol(struct net_device *dev,
 	return 0;
 }
 
+#ifdef CONFIG_BFIN_MAC_USE_HWSTAMP
 static int bfin_mac_ethtool_get_ts_info(struct net_device *dev,
 	struct ethtool_ts_info *info)
 {
@@ -566,6 +567,7 @@ static int bfin_mac_ethtool_get_ts_info(struct net_device *dev,
 		(1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT);
 	return 0;
 }
+#endif
 
 static const struct ethtool_ops bfin_mac_ethtool_ops = {
 	.get_settings = bfin_mac_ethtool_getsettings,
@@ -574,7 +576,9 @@ static const struct ethtool_ops bfin_mac_ethtool_ops = {
 	.get_drvinfo = bfin_mac_ethtool_getdrvinfo,
 	.get_wol = bfin_mac_ethtool_getwol,
 	.set_wol = bfin_mac_ethtool_setwol,
+#ifdef CONFIG_BFIN_MAC_USE_HWSTAMP
 	.get_ts_info = bfin_mac_ethtool_get_ts_info,
+#endif
 };
 
 /**************************************************************************/
-- 
1.7.2.5
