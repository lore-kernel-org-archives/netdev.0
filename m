From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 05/24] net, diet: Default to small TCP hash tables on small kernels
Date: Mon,  5 May 2014 15:25:54 -0700
Message-ID: <1399328773-6531-6-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 net/ipv4/tcp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4bd6d52..3fd48421 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3127,7 +3127,11 @@ EXPORT_SYMBOL_GPL(tcp_done);
 
 extern struct tcp_congestion_ops tcp_reno;
 
+#ifdef CONFIG_BASE_SMALL
+static __initdata unsigned long thash_entries = 16;
+#else
 static __initdata unsigned long thash_entries;
+#endif
 static int __init set_thash_entries(char *str)
 {
 	ssize_t ret;
-- 
1.9.0
