From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/5] netdev_printk/netif_printk: Remove a superfluous logging colon
Date: Sun, 26 Aug 2012 04:25:28 -0700
Message-ID: <a925f82bf967fa87397b674fd6aa252e9b12f504.1345978012.git.joe@perches.com>
References: <cover.1345978012.git.joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Jason Baron <jbaron@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1345978012.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev_printk originally called dev_printk with %pV.

This style emitted the complete dev_printk header with
a colon followed by the netdev_name prefix followed
by a colon.

Now that netdev_printk does not call dev_printk, the
extra colon is superfluous.  Remove it.

Example:
old: sky2 0000:02:00.0: eth0: Link is up at 100 Mbps, full duplex, flow control both
new: sky2 0000:02:00.0 eth0: Link is up at 100 Mbps, full duplex, flow control both

Signed-off-by: Joe Perches <joe@perches.com>
---
 lib/dynamic_debug.c |    2 +-
 net/core/dev.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/dynamic_debug.c b/lib/dynamic_debug.c
index 2a29f4e..6b3ebab 100644
--- a/lib/dynamic_debug.c
+++ b/lib/dynamic_debug.c
@@ -634,7 +634,7 @@ int __dynamic_netdev_dbg(struct _ddebug *descriptor,
 					       dict, sizeof(dict));
 
 		res = printk_emit(0, 7, dictlen ? dict : NULL, dictlen,
-				  "%s%s %s: %s: %pV",
+				  "%s%s %s %s: %pV",
 				  dynamic_emit_prefix(descriptor, buf),
 				  dev_driver_string(dev->dev.parent),
 				  dev_name(dev->dev.parent),
diff --git a/net/core/dev.c b/net/core/dev.c
index a588145..1ec186a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6434,7 +6434,7 @@ static int __netdev_printk(const char *level, const struct net_device *dev,
 
 		r = printk_emit(0, level[1] - '0',
 				dictlen ? dict : NULL, dictlen,
-				"%s %s: %s: %pV",
+				"%s %s %s: %pV",
 				dev_driver_string(dev->dev.parent),
 				dev_name(dev->dev.parent),
 				netdev_name(dev), vaf);
-- 
1.7.8.111.gad25c.dirty
