From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 07/13] bluetooth: Convert compare_ether_addr to ether_addr_equal
Date: Tue,  8 May 2012 21:56:51 -0700
Message-ID: <81fc602aa661c0919a9864a40c950ce8a3b72275.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1336538937.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use the new bool function ether_addr_equal to add
some clarity and reduce the likelihood for misuse
of compare_ether_addr for sorting.

Done via cocci script:

$ cat compare_ether_addr.cocci
@@
expression a,b;
@@
-	!compare_ether_addr(a, b)
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	compare_ether_addr(a, b)
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) == 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal(a, b) != 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) == 0
+	!ether_addr_equal(a, b)

@@
expression a,b;
@@
-	ether_addr_equal(a, b) != 0
+	ether_addr_equal(a, b)

@@
expression a,b;
@@
-	!!ether_addr_equal(a, b)
+	ether_addr_equal(a, b)

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 net/bluetooth/bnep/core.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index a779ec7..88884d1 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -69,7 +69,7 @@ static struct bnep_session *__bnep_get_session(u8 *dst)
 	BT_DBG("");
 
 	list_for_each_entry(s, &bnep_session_list, list)
-		if (!compare_ether_addr(dst, s->eh.h_source))
+		if (ether_addr_equal(dst, s->eh.h_source))
 			return s;
 
 	return NULL;
@@ -422,10 +422,10 @@ static inline int bnep_tx_frame(struct bnep_session *s, struct sk_buff *skb)
 	iv[il++] = (struct kvec) { &type, 1 };
 	len++;
 
-	if (compress_src && !compare_ether_addr(eh->h_dest, s->eh.h_source))
+	if (compress_src && ether_addr_equal(eh->h_dest, s->eh.h_source))
 		type |= 0x01;
 
-	if (compress_dst && !compare_ether_addr(eh->h_source, s->eh.h_dest))
+	if (compress_dst && ether_addr_equal(eh->h_source, s->eh.h_dest))
 		type |= 0x02;
 
 	if (type)
-- 
1.7.8.111.gad25c.dirty
