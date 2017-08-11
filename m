From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/2] net: fix compilation when busy poll is not enabled
Date: Fri, 11 Aug 2017 18:31:24 +0200
Message-ID: <410483fee7129aec06f5f6f3135020666f74cb26.1502468639.git.daniel@iogearbox.net>
References: <cover.1502468639.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41702 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753673AbdHKQbc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 12:31:32 -0400
In-Reply-To: <cover.1502468639.git.daniel@iogearbox.net>
In-Reply-To: <cover.1502468639.git.daniel@iogearbox.net>
References: <cover.1502468639.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MIN_NAPI_ID is used in various places outside of
CONFIG_NET_RX_BUSY_POLL wrapping, so when it's not set
we run into build errors such as:

  net/core/dev.c: In function 'dev_get_by_napi_id':
  net/core/dev.c:886:16: error: ‘MIN_NAPI_ID’ undeclared (first use in this function)
    if (napi_id < MIN_NAPI_ID)
                  ^~~~~~~~~~~

Thus, have MIN_NAPI_ID always defined to fix these errors.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/busy_poll.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index 8ffd434..71c72a9 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -29,18 +29,18 @@
 #include <linux/sched/signal.h>
 #include <net/ip.h>
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-
-struct napi_struct;
-extern unsigned int sysctl_net_busy_read __read_mostly;
-extern unsigned int sysctl_net_busy_poll __read_mostly;
-
 /*		0 - Reserved to indicate value not set
  *     1..NR_CPUS - Reserved for sender_cpu
  *  NR_CPUS+1..~0 - Region available for NAPI IDs
  */
 #define MIN_NAPI_ID ((unsigned int)(NR_CPUS + 1))
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+
+struct napi_struct;
+extern unsigned int sysctl_net_busy_read __read_mostly;
+extern unsigned int sysctl_net_busy_poll __read_mostly;
+
 static inline bool net_busy_loop_on(void)
 {
 	return sysctl_net_busy_poll;
-- 
1.9.3
