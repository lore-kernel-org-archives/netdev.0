From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/7] netfilter: nf_conntrack: use RCU safe kfree for conntrack extensions
Date: Wed, 18 Sep 2013 00:07:28 +0200
Message-ID: <1379455654-3905-2-git-send-email-pablo@netfilter.org>
References: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Michal Kube=C4=8Dek <mkubecek@suse.cz>

Commit 68b80f11 (netfilter: nf_nat: fix RCU races) introduced
RCU protection for freeing extension data when reallocation
moves them to a new location. We need the same protection when
freeing them in nf_ct_ext_free() in order to prevent a
use-after-free by other threads referencing a NAT extension data
via bysource list.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_extend.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/=
netfilter/nf_conntrack_extend.h
index ff95434..88a1d40 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -86,7 +86,7 @@ static inline void nf_ct_ext_destroy(struct nf_conn *=
ct)
 static inline void nf_ct_ext_free(struct nf_conn *ct)
 {
 	if (ct->ext)
-		kfree(ct->ext);
+		kfree_rcu(ct->ext, rcu);
 }
=20
 /* Add this type, returns pointer to data or NULL. */
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
