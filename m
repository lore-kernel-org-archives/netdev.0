From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 07/15] i825xx: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:38 -0400
Message-ID: <1473689026-6983-8-git-send-email-javier@osg.samsung.com>
References: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Felipe Balbi <felipe.balbi@linux.intel.com>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Antonio Quartulli <a@unstable.cc>,
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

 drivers/net/ethernet/i825xx/82596.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/i825xx/82596.c b/drivers/net/ethernet/i825xx/82596.c
index befb4ac3e2b0..ce235b776793 100644
--- a/drivers/net/ethernet/i825xx/82596.c
+++ b/drivers/net/ethernet/i825xx/82596.c
@@ -89,10 +89,10 @@ static char version[] __initdata =
 #define DEB(x,y)	if (i596_debug & (x)) y
 
 
-#if defined(CONFIG_MVME16x_NET) || defined(CONFIG_MVME16x_NET_MODULE)
+#if IS_ENABLED(CONFIG_MVME16x_NET)
 #define ENABLE_MVME16x_NET
 #endif
-#if defined(CONFIG_BVME6000_NET) || defined(CONFIG_BVME6000_NET_MODULE)
+#if IS_ENABLED(CONFIG_BVME6000_NET)
 #define ENABLE_BVME6000_NET
 #endif
 
-- 
2.7.4
