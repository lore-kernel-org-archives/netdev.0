From: "zhaoxiu.zeng" <zhaoxiu.zeng-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 12/31] sunrpc: auth_gss: use parity8
Date: Sun, 27 Mar 2016 14:51:36 +0800
Message-ID: <56F782F8.8000903@gmail.com>
References: <1458788612-4367-1-git-send-email-zhaoxiu.zeng@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1458788612-4367-1-git-send-email-zhaoxiu.zeng-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Zeng Zhaoxiu <zhaoxiu.zeng-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Signed-off-by: Zeng Zhaoxiu <zhaoxiu.zeng-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/sunrpc/auth_gss/gss_krb5_keys.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
index 8701331..c41b389 100644
--- a/net/sunrpc/auth_gss/gss_krb5_keys.c
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -243,16 +243,12 @@ err_return:
 	return ret;
 }
 
-#define smask(step) ((1<<step)-1)
-#define pstep(x, step) (((x)&smask(step))^(((x)>>step)&smask(step)))
-#define parity_char(x) pstep(pstep(pstep((x), 4), 2), 1)
-
 static void mit_des_fixup_key_parity(u8 key[8])
 {
 	int i;
 	for (i = 0; i < 8; i++) {
 		key[i] &= 0xfe;
-		key[i] |= 1^parity_char(key[i]);
+		key[i] |= !parity8(key[i]);
 	}
 }
 
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
