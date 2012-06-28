From: Vinson Lee <vlee@twitter.com>
Subject: [PATCH] net: Downgrade CAP_SYS_MODULE deprecated message from error to warning.
Date: Wed, 27 Jun 2012 17:32:07 -0700
Message-ID: <1340843527-9962-1-git-send-email-vlee@twitter.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vinson Lee <vlee@twitter.com>,
	David Mackey <tdmackey@twitter.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, <mirq-linux@rere.qmqm.pl>,
	Jiri Pirko <jpirko@redhat.com>,
	Tom Herbert <therbert@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make logging level consistent with other deprecation messages in net
subsystem.

Signed-off-by: Vinson Lee <vlee@twitter.com>
Cc: David Mackey <tdmackey@twitter.com>
---
 net/core/dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index cd09819..b19a361 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1136,8 +1136,8 @@ void dev_load(struct net *net, const char *name)
 		no_module = request_module("netdev-%s", name);
 	if (no_module && capable(CAP_SYS_MODULE)) {
 		if (!request_module("%s", name))
-			pr_err("Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s instead.\n",
-			       name);
+			pr_warn("Loading kernel module for a network device with CAP_SYS_MODULE (deprecated).  Use CAP_NET_ADMIN and alias netdev-%s instead.\n",
+				name);
 	}
 }
 EXPORT_SYMBOL(dev_load);
-- 
1.7.9.5
