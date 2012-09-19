From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool] ethtool: --set-eee sends ETHTOOL_SEEE ioctl even if nothing changed
Date: Tue, 18 Sep 2012 20:20:19 -0700
Message-ID: <1348024819-29876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50317 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808Ab2ISDUX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2012 23:20:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When setting EEE parameters with the --set-eee command line option,
ethtool will send the ETHTOOL_SEEE ioctl down to the driver even if
none of the provided parameters are a change from current settings.
Simply ignore it when that happens as done with other ethtool commands.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ethtool.c b/ethtool.c
index 25ba51f..f3649e2 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3645,7 +3645,7 @@ static int do_geee(struct cmd_context *ctx)
 static int do_seee(struct cmd_context *ctx)
 {
 	int adv_c = -1, lpi_c = -1, lpi_time_c = -1, eee_c = -1;
-	int change = -1, change2 = -1;
+	int change = -1, change2 = 0;
 	struct ethtool_eee eeecmd;
 	struct cmdline_info cmdline_eee[] = {
 		{ "advertise",    CMDL_U32,  &adv_c,       &eeecmd.advertised },
-- 
1.7.11.4
