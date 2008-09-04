From: Josh Boyer <jwboyer@gmail.com>
Subject: [PATCH 1/3] ibm_newemac: Allow the "no flow control" EMAC feature
	to work
Date: Thu, 4 Sep 2008 11:01:50 -0400
Message-ID: <20080904150150.GB2479@yoda.jdub.homelinux.org>
References: <cover.1220540078.git.jwboyer@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.248]:61129 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbYIDPCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 11:02:36 -0400
Received: by hs-out-0708.google.com with SMTP id 4so398984hsl.5
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2008 08:02:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1220540078.git.jwboyer@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some PowerPC 40x chips have errata that force us not to use the integrated
flow control.  We have the feature defined, but it currently can't be used
because it is never added to EMAC_FTRS_POSSIBLE.

This adds a Kconfig option for affected platforms to select and puts the
feature in the EMAC_FTRS_POSSIBLE list.  This is set for PowerPC 405EZ
platforms as well.

Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
---
 drivers/net/ibm_newemac/Kconfig |    4 ++++
 drivers/net/ibm_newemac/core.c  |    2 ++
 drivers/net/ibm_newemac/core.h  |    3 +++
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ibm_newemac/Kconfig b/drivers/net/ibm_newemac/Kconfig
index 70a3272..dfb6547 100644
--- a/drivers/net/ibm_newemac/Kconfig
+++ b/drivers/net/ibm_newemac/Kconfig
@@ -62,3 +62,7 @@ config IBM_NEW_EMAC_TAH
 config IBM_NEW_EMAC_EMAC4
 	bool
 	default n
+
+config IBM_NEW_EMAC_NO_FLOW_CTRL
+	bool
+	default n
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 2e720f2..2442361 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2567,6 +2567,8 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 		if (of_device_is_compatible(np, "ibm,emac-440ep") ||
 		    of_device_is_compatible(np, "ibm,emac-440gr"))
 			dev->features |= EMAC_FTR_440EP_PHY_CLK_FIX;
+		if (of_device_is_compatible(np, "ibm,emac-405ez"))
+			dev->features |= EMAC_FTR_NO_FLOW_CONTROL_40x;
 	}
 
 	/* Fixup some feature bits based on the device tree */
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ibm_newemac/core.h
index 6545e69..59e5a5d 100644
--- a/drivers/net/ibm_newemac/core.h
+++ b/drivers/net/ibm_newemac/core.h
@@ -341,6 +341,9 @@ enum {
 #ifdef CONFIG_IBM_NEW_EMAC_RGMII
 	    EMAC_FTR_HAS_RGMII	|
 #endif
+#ifdef CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL
+	    EMAC_FTR_NO_FLOW_CONTROL_40x |
+#endif
 	EMAC_FTR_440EP_PHY_CLK_FIX,
 };
 
-- 
1.5.5.1

