From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 04/18] ipw2200: add module_param support for antenna selection
Date: Thu, 13 Apr 2006 17:19:36 +0800
Message-ID: <20060413091936.GA28727@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:26573 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S964844AbWDMJ0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:26:40 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

cfcb7bc915320b44d0d2825a8554211249c7bbcd
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 536af9f..6b8c47b 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -61,6 +61,7 @@ static int roaming = 1;
 static const char ipw_modes[] = {
 	'a', 'b', 'g', '?'
 };
+static int antenna = CFG_SYS_ANTENNA_BOTH;
 
 #ifdef CONFIG_IPW_QOS
 static int qos_enable = 0;
@@ -9630,7 +9631,9 @@ static  void init_sys_config(struct ipw_
 	sys_config->disable_unicast_decryption = 1;
 	sys_config->exclude_multicast_unencrypted = 0;
 	sys_config->disable_multicast_decryption = 1;
-	sys_config->antenna_diversity = CFG_SYS_ANTENNA_SLOW_DIV;
+	if (antenna < CFG_SYS_ANTENNA_BOTH || antenna > CFG_SYS_ANTENNA_B)
+		antenna = CFG_SYS_ANTENNA_BOTH;
+	sys_config->antenna_diversity = antenna;
 	sys_config->pass_crc_to_host = 0;	/* TODO: See if 1 gives us FCS */
 	sys_config->dot11g_auto_detection = 0;
 	sys_config->enable_cts_to_self = 0;
@@ -11261,5 +11264,8 @@ MODULE_PARM_DESC(cmdlog,
 module_param(roaming, int, 0444);
 MODULE_PARM_DESC(roaming, "enable roaming support (default on)");
 
+module_param(antenna, int, 0444);
+MODULE_PARM_DESC(antenna, "select antenna 1=Main, 3=Aux, default 0 [both], 2=slow_diversity (choose the one with lower background noise)");
+
 module_exit(ipw_exit);
 module_init(ipw_init);
-- 
1.2.6

