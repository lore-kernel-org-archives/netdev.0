From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 03/15] ethernet: amd: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:34 -0400
Message-ID: <1473689026-6983-4-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Antonio Quartulli <a@unstable.cc>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Mugunthan V N <mugunthanvnm@ti.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/ethernet/amd/7990.c     | 6 +++---
 drivers/net/ethernet/amd/amd8111e.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/7990.c b/drivers/net/ethernet/amd/7990.c
index dcf2a1f3643d..dc57f2759f44 100644
--- a/drivers/net/ethernet/amd/7990.c
+++ b/drivers/net/ethernet/amd/7990.c
@@ -45,14 +45,14 @@
 #define WRITERDP(lp, x)	out_be16(lp->base + LANCE_RDP, (x))
 #define READRDP(lp)	in_be16(lp->base + LANCE_RDP)
 
-#if defined(CONFIG_HPLANCE) || defined(CONFIG_HPLANCE_MODULE)
+#if IS_ENABLED(CONFIG_HPLANCE)
 #include "hplance.h"
 
 #undef WRITERAP
 #undef WRITERDP
 #undef READRDP
 
-#if defined(CONFIG_MVME147_NET) || defined(CONFIG_MVME147_NET_MODULE)
+#if IS_ENABLED(CONFIG_MVME147_NET)
 
 /* Lossage Factor Nine, Mr Sulu. */
 #define WRITERAP(lp, x)	(lp->writerap(lp, x))
@@ -86,7 +86,7 @@ static inline __u16 READRDP(struct lance_private *lp)
 }
 
 #endif
-#endif /* CONFIG_HPLANCE || CONFIG_HPLANCE_MODULE */
+#endif /* IS_ENABLED(CONFIG_HPLANCE) */
 
 /* debugging output macros, various flavours */
 /* #define TEST_HITS */
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 94960055fa1f..f92cc97151ec 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -89,7 +89,7 @@ Revision History:
 #include <asm/byteorder.h>
 #include <asm/uaccess.h>
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
 #define AMD8111E_VLAN_TAG_USED 1
 #else
 #define AMD8111E_VLAN_TAG_USED 0
-- 
2.7.4
