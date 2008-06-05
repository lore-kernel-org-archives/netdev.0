From: Richard Kennedy <richard@rsk.demon.co.uk>
Subject: [PATCH] Net: reorder udp_iter_state to remove padding on 64bit
	builds
Date: Thu, 05 Jun 2008 11:33:39 +0100
Message-ID: <1212662019.3039.14.camel@castor.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756853AbYFEKeC@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

reorder udp_iter_state to remove padding on 64bit builds

shrinks from 24 to 16 bytes, moving to a smaller slab when CONFIG_NET_NS
is undefined & seq_net_private = {}

Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>

---
static analysis found this padding in udp_iter_state.

I've boot tested 2.6.26-rc4 + patch on desktop AMD64, and successfully
run a simple UDP test case.

Richard



diff --git a/include/net/udp.h b/include/net/udp.h
index ccce837..7a86848 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -196,8 +196,8 @@ struct udp_seq_afinfo {
 struct udp_iter_state {
 	struct seq_net_private  p;
 	sa_family_t		family;
-	struct hlist_head	*hashtable;
 	int			bucket;
+	struct hlist_head	*hashtable;
 };
 
 #ifdef CONFIG_PROC_FS
