From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] net: fix build warnings because of net_get_random_once merge
Date: Sun, 20 Oct 2013 06:26:02 +0200
Message-ID: <20131020042602.GC27787@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45891 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725Ab3JTE0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 00:26:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following warning:

   In file included from include/linux/skbuff.h:27:0,
                    from include/linux/netfilter.h:5,
                    from include/net/netns/netfilter.h:5,
                    from include/net/net_namespace.h:20,
                    from include/linux/init_task.h:14,
                    from init/init_task.c:1:
include/linux/net.h:243:14: warning: 'struct static_key' declared inside parameter list [enabled by default]
          struct static_key *done_key);

on x86_64 allnoconfig, um defconfig and ia64 allmodconfig and maybe others as well.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/net.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/net.h b/include/linux/net.h
index a489705..aca446b 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -24,6 +24,7 @@
 #include <linux/fcntl.h>	/* For O_CLOEXEC and O_NONBLOCK */
 #include <linux/kmemcheck.h>
 #include <linux/rcupdate.h>
+#include <linux/jump_label.h>
 #include <uapi/linux/net.h>
 
 struct poll_table_struct;
-- 
1.8.3.1
