From: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH 1/1 net-next] sunrpc: use sg_init_one() in krb5_rc4_setup_enc/seq_key()
Date: Tue, 16 Jun 2015 21:57:52 +0200
Message-ID: <1434484672-5877-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Don't opencode sg_init_one()

Signed-off-by: Fabian Frederick <fabf-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
---
 net/sunrpc/auth_gss/gss_krb5_crypto.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index b5408e8..fee3c15 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -881,9 +881,7 @@ krb5_rc4_setup_seq_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
 	if (err)
 		goto out_err;
 
-	sg_init_table(sg, 1);
-	sg_set_buf(sg, &zeroconstant, 4);
-
+	sg_init_one(sg, &zeroconstant, 4);
 	err = crypto_hash_digest(&desc, sg, 4, Kseq);
 	if (err)
 		goto out_err;
@@ -951,9 +949,7 @@ krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
 	if (err)
 		goto out_err;
 
-	sg_init_table(sg, 1);
-	sg_set_buf(sg, zeroconstant, 4);
-
+	sg_init_one(sg, zeroconstant, 4);
 	err = crypto_hash_digest(&desc, sg, 4, Kcrypt);
 	if (err)
 		goto out_err;
-- 
2.4.2

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
