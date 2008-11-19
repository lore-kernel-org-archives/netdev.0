From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH] ipv6: use seq_release_private for ip6mr.c /proc entries
Date: Wed, 19 Nov 2008 21:41:38 +0100
Message-ID: <20081119204141.938837793@theryb.frec.bull.fr>
References: <20081119204128.826163131@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:52814 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbYKSUoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 15:44:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ip6mr.c, /proc entries /proc/net/ip6_mr_cache and /proc/net/ip6_mr_vif
are opened with seq_open_private(), thus seq_release_private() should be 
used to release them.
Should fix a small memory leak.

Benjamin

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/ip6mr.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: net-2.6/net/ipv6/ip6mr.c
===================================================================
--- net-2.6.orig/net/ipv6/ip6mr.c
+++ net-2.6/net/ipv6/ip6mr.c
@@ -224,7 +224,7 @@ static struct file_operations ip6mr_vif_
 	.open    = ip6mr_vif_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };
 
 static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
@@ -338,7 +338,7 @@ static struct file_operations ip6mr_mfc_
 	.open    = ipmr_mfc_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };
 #endif
 

-- 
