From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch] net: fix an array index overflow
Date: Tue, 1 Dec 2009 03:26:02 -0500
Message-ID: <20091201082901.4678.16688.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Amerigo Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753774AbZLAI0A@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Don't use the address of an out-of-boundary element.

Maybe this is not harmful at runtime, but it is still
good to improve it.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: David S. Miller <davem@davemloft.net>

---
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 57737b8..2669361 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1586,7 +1586,7 @@ static int __init inet_init(void)
 #endif
 
 	/* Register the socket-side information for inet_create. */
-	for (r = &inetsw[0]; r < &inetsw[SOCK_MAX]; ++r)
+	for (r = &inetsw[0]; r <= &inetsw[SOCK_MAX-1]; ++r)
 		INIT_LIST_HEAD(r);
 
 	for (q = inetsw_array; q < &inetsw_array[INETSW_ARRAY_LEN]; ++q)
