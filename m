From: "rae l" <crquan@gmail.com>
Subject: [PATCH] merge dst_discard in & out into one, this decrements the vmlinux image by 21 bytes under i386 arch.
Date: Mon, 28 May 2007 10:41:20 +0800
Message-ID: <91b13c310705271941n48e266b9vc202b862ad4fabba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Networking Team" <netdev@vger.kernel.org>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	"Adrian Bunk" <trivial@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:65492 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbXE1ClV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2007 22:41:21 -0400
Received: by ug-out-1314.google.com with SMTP id j3so1531146ugf
        for <netdev@vger.kernel.org>; Sun, 27 May 2007 19:41:20 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Cheng

thus the definition of dst_discard_in and dst_discard_out is the same,
we can define a dst_discard function and map the _in and _out to it,
this can reduce space in vmlinux.

Signed-off-by: Denis Cheng <crquan@gmail.com>
---

diff --git a/net/core/dst.c b/net/core/dst.c
index 764bccb..daa0439 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -111,17 +111,14 @@ out:
        spin_unlock(&dst_lock);
 }

-static int dst_discard_in(struct sk_buff *skb)
+static int dst_discard(struct sk_buff *skb)
 {
        kfree_skb(skb);
        return 0;
 }

-static int dst_discard_out(struct sk_buff *skb)
-{
-       kfree_skb(skb);
-       return 0;
-}
+#define dst_discard_in dst_discard
+#define dst_discard_out        dst_discard

 void * dst_alloc(struct dst_ops * ops)
 {


-- 
Denis Cheng
Linux Application Developer
