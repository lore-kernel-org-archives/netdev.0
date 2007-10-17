From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: [PATCH] ip_gra_reasm() should set "err" incase of skb_clone()
	failure
Date: Wed, 17 Oct 2007 16:02:33 -0700
Message-ID: <1192662154.14504.7.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762282AbXJQW7q@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simple error handling fix (against 2.26.23-git12).

Thanks,
Badari

Need to initialize "err" in case of skb_clone() failure.

net/ipv4/ip_fragment.c: In function `ip_defrag':
net/ipv4/ip_fragment.c:540: warning: `err' might be used uninitialized in this function

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
---
 net/ipv4/ip_fragment.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6.23/net/ipv4/ip_fragment.c
===================================================================
--- linux-2.6.23.orig/net/ipv4/ip_fragment.c	2007-10-17 15:33:27.000000000 -0700
+++ linux-2.6.23/net/ipv4/ip_fragment.c	2007-10-17 15:50:51.000000000 -0700
@@ -544,6 +544,7 @@ static int ip_frag_reasm(struct ipq *qp,
 	/* Make the one we just received the head. */
 	if (prev) {
 		head = prev->next;
+		err = -ENOMEM;
 		fp = skb_clone(head, GFP_ATOMIC);
 
 		if (!fp)
