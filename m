From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 3/8] net: use IS_ENABLED() instead of checking for built-in or module
Date: Fri,  9 Sep 2016 08:43:15 -0400
Message-ID: <1473425000-9782-4-git-send-email-javier@osg.samsung.com>
References: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Tom Herbert <tom@herbertland.com>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 net/core/dev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c7d7db49826d..9e76d4df6ca0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3904,8 +3904,7 @@ static __latent_entropy void net_tx_action(struct softirq_action *h)
 	}
 }
 
-#if (defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)) && \
-    (defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE))
+#if IS_ENABLED(CONFIG_BRIDGE) && IS_ENABLED(CONFIG_ATM_LANE)
 /* This hook is defined here for ATM LANE */
 int (*br_fdb_test_addr_hook)(struct net_device *dev,
 			     unsigned char *addr) __read_mostly;
-- 
2.7.4
