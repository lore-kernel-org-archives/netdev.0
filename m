From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 06/24] net, diet: Use small UDP hash tables on small kernels
Date: Mon,  5 May 2014 15:25:55 -0700
Message-ID: <1399328773-6531-7-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

UDP has two hash tables, for UDP and UDP lite. Default
them to 16 entries each on small kernels. This can be
still overriden on the command line.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 net/ipv4/udp.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4468e1a..90f967b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2415,7 +2415,12 @@ void udp4_proc_exit(void)
 }
 #endif /* CONFIG_PROC_FS */
 
+#ifdef CONFIG_BASE_SMALL
+static __initdata unsigned long uhash_entries = 16;
+#else
 static __initdata unsigned long uhash_entries;
+#endif
+
 static int __init set_uhash_entries(char *str)
 {
 	ssize_t ret;
-- 
1.9.0
