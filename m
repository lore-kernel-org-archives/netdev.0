From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: [PATCH 1/3] ibm_newemac: Allow the "no flow control" EMAC feature
	to work
Date: Thu, 4 Sep 2008 08:57:57 -0400
Message-ID: <62e3d970a3bcb8158308bb645f99c75a41d177ff.1220877899.git.jwboyer@linux.vnet.ibm.com>
References: <cover.1220877899.git.jwboyer@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
To: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:28221 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbYIHNEf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 09:04:35 -0400
Received: by py-out-1112.google.com with SMTP id p76so870772pyb.10
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 06:04:34 -0700 (PDT)
In-Reply-To: <cover.1220877899.git.jwboyer@linux.vnet.ibm.com>
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


