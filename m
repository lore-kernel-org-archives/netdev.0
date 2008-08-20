From: adobriyan@gmail.com
Subject: [PATCH] nf_conntrack_gre: nf_ct_gre_keymap_flush() fixlet
Date: Thu, 21 Aug 2008 00:56:46 +0400
Message-ID: <20080820205646.GB16405@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It does "kfree(list_head)" which looks wrong because entity that was
allocated is definitely not list_head.

However, this all works because list_head is first item in
struct nf_ct_gre_keymap.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_proto_gre.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

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

