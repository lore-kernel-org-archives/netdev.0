From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 10/13] net: ethtool: Add macro to clear a link
 mode setting
Date: Fri, 18 Aug 2017 09:03:44 -0500
Message-ID: <20170818140344.14804.21251.stgit@tlendack-t1.amdoffice.net>
References: <20170818140209.14804.94997.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0040.outbound.protection.outlook.com ([104.47.34.40]:53824
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753580AbdHRODv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 10:03:51 -0400
In-Reply-To: <20170818140209.14804.94997.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are currently macros to set and test an ETHTOOL_LINK_MODE_ setting,
but not to clear one. Add a macro to clear an ETHTOOL_LINK_MODE_ setting.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 include/linux/ethtool.h |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index afdbb70..4587a4c 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -137,6 +137,17 @@ struct ethtool_link_ksettings {
 	__set_bit(ETHTOOL_LINK_MODE_ ## mode ## _BIT, (ptr)->link_modes.name)
 
 /**
+ * ethtool_link_ksettings_del_link_mode - clear bit in link_ksettings
+ * link mode mask
+ *   @ptr : pointer to struct ethtool_link_ksettings
+ *   @name : one of supported/advertising/lp_advertising
+ *   @mode : one of the ETHTOOL_LINK_MODE_*_BIT
+ * (not atomic, no bound checking)
+ */
+#define ethtool_link_ksettings_del_link_mode(ptr, name, mode)		\
+	__clear_bit(ETHTOOL_LINK_MODE_ ## mode ## _BIT, (ptr)->link_modes.name)
+
+/**
  * ethtool_link_ksettings_test_link_mode - test bit in ksettings link mode mask
  *   @ptr : pointer to struct ethtool_link_ksettings
  *   @name : one of supported/advertising/lp_advertising
