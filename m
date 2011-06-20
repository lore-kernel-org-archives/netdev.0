From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] Remove redundant linux/version.h includes from net/
Date: Tue, 21 Jun 2011 00:13:10 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106210009520.27735@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, coreteam@netfilter.org,
	netfilter@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Dmitry Kozlov <xeb@mail.ru>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was suggested by "make versioncheck" that the follwing includes of
linux/version.h are redundant:

  /home/jj/src/linux-2.6/net/caif/caif_dev.c: 14 linux/version.h not needed.
  /home/jj/src/linux-2.6/net/caif/chnl_net.c: 10 linux/version.h not needed.
  /home/jj/src/linux-2.6/net/ipv4/gre.c: 19 linux/version.h not needed.
  /home/jj/src/linux-2.6/net/netfilter/ipset/ip_set_core.c: 20 linux/version.h not needed.
  /home/jj/src/linux-2.6/net/netfilter/xt_set.c: 16 linux/version.h not needed.

and it seems that it is right.

Beyond manually inspecting the source files I also did a few build
tests with various configs to confirm that including the header in
those files is indeed not needed.

Here's a patch to remove the pointless includes.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/caif/caif_dev.c               |    1 -
 net/caif/chnl_net.c               |    1 -
 net/ipv4/gre.c                    |    1 -
 net/netfilter/ipset/ip_set_core.c |    1 -
 net/netfilter/xt_set.c            |    1 -
 5 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 682c0fe..7c2fa0a 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -11,7 +11,6 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
 
-#include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/if_arp.h>
 #include <linux/net.h>
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index adbb424..8237766 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -7,7 +7,6 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
 
-#include <linux/version.h>
 #include <linux/fs.h>
 #include <linux/init.h>
 #include <linux/module.h>
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index c6933f2..9dbe108 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -16,7 +16,6 @@
 #include <linux/skbuff.h>
 #include <linux/in.h>
 #include <linux/netdevice.h>
-#include <linux/version.h>
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 #include <net/gre.h>
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 42aa64b..40c9645 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -17,7 +17,6 @@
 #include <linux/spinlock.h>
 #include <linux/netlink.h>
 #include <linux/rculist.h>
-#include <linux/version.h>
 #include <net/netlink.h>
 
 #include <linux/netfilter.h>
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index b3babae..5c23c44 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -13,7 +13,6 @@
 
 #include <linux/module.h>
 #include <linux/skbuff.h>
-#include <linux/version.h>
 
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_set.h>

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
