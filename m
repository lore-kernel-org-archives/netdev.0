From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 03/33] nf_conntrack_gre: nf_ct_gre_keymap_flush() fixlet
Date: Mon,  8 Sep 2008 07:02:40 +0400
Message-ID: <1220842990-30500-3-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.185]:64313 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbYIHDBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 23:01:31 -0400
Received: by gv-out-0910.google.com with SMTP id e6so91841gvc.37
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 20:01:31 -0700 (PDT)
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It does "kfree(list_head)" which looks wrong because entity that was
allocated is definitely not list_head.

However, this all works because list_head is first item in
struct nf_ct_gre_keymap .

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 2752b74..c5a7822 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -45,12 +45,12 @@ static LIST_HEAD(gre_keymap_list);
 
 void nf_ct_gre_keymap_flush(void)
 {
-	struct list_head *pos, *n;
+	struct nf_ct_gre_keymap *km, *tmp;
 
 	write_lock_bh(&nf_ct_gre_lock);
-	list_for_each_safe(pos, n, &gre_keymap_list) {
-		list_del(pos);
-		kfree(pos);
+	list_for_each_entry_safe(km, tmp, &gre_keymap_list, list) {
+		list_del(&km->list);
+		kfree(km);
 	}
 	write_unlock_bh(&nf_ct_gre_lock);
 }
