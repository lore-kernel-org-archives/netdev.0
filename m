From: Jingoo Han <jg1.han-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] net: sunrpc: replace strict_strtoul() with kstrtoul()
Date: Fri, 19 Jul 2013 16:27:11 +0900
Message-ID: <001c01ce8451$6209cd30$261d6790$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	'Trond Myklebust' <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jingoo Han <jg1.han-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-language: ko
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The usage of strict_strtoul() is not preferred, because
strict_strtoul() is obsolete. Thus, kstrtoul() should be
used.

Signed-off-by: Jingoo Han <jg1.han-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
---
 net/sunrpc/addr.c     |    8 ++++----
 net/sunrpc/auth.c     |    2 +-
 net/sunrpc/xprtsock.c |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index a622ad6..c0d3243 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -184,7 +184,7 @@ static int rpc_parse_scope_id(struct net *net, const char *buf,
 			scope_id = dev->ifindex;
 			dev_put(dev);
 		} else {
-			if (strict_strtoul(p, 10, &scope_id) == 0) {
+			if (kstrtoul(p, 10, &scope_id) == 0) {
 				kfree(p);
 				return 0;
 			}
@@ -304,7 +304,7 @@ char *rpc_sockaddr2uaddr(const struct sockaddr *sap, gfp_t gfp_flags)
  * @sap: buffer into which to plant socket address
  * @salen: size of buffer
  *
- * @uaddr does not have to be '\0'-terminated, but strict_strtoul() and
+ * @uaddr does not have to be '\0'-terminated, but kstrtoul() and
  * rpc_pton() require proper string termination to be successful.
  *
  * Returns the size of the socket address if successful; otherwise
@@ -327,7 +327,7 @@ size_t rpc_uaddr2sockaddr(struct net *net, const char *uaddr,
 	c = strrchr(buf, '.');
 	if (unlikely(c == NULL))
 		return 0;
-	if (unlikely(strict_strtoul(c + 1, 10, &portlo) != 0))
+	if (unlikely(kstrtoul(c + 1, 10, &portlo) != 0))
 		return 0;
 	if (unlikely(portlo > 255))
 		return 0;
@@ -336,7 +336,7 @@ size_t rpc_uaddr2sockaddr(struct net *net, const char *uaddr,
 	c = strrchr(buf, '.');
 	if (unlikely(c == NULL))
 		return 0;
-	if (unlikely(strict_strtoul(c + 1, 10, &porthi) != 0))
+	if (unlikely(kstrtoul(c + 1, 10, &porthi) != 0))
 		return 0;
 	if (unlikely(porthi > 255))
 		return 0;
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 495a224..682d140 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -48,7 +48,7 @@ static int param_set_hashtbl_sz(const char *val, const struct kernel_param *kp)
 
 	if (!val)
 		goto out_inval;
-	ret = strict_strtoul(val, 0, &num);
+	ret = kstrtoul(val, 0, &num);
 	if (ret == -EINVAL)
 		goto out_inval;
 	nbits = fls(num);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ddf0602..176cc69 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -3001,7 +3001,7 @@ static int param_set_uint_minmax(const char *val,
 
 	if (!val)
 		return -EINVAL;
-	ret = strict_strtoul(val, 0, &num);
+	ret = kstrtoul(val, 0, &num);
 	if (ret == -EINVAL || num < min || num > max)
 		return -EINVAL;
 	*((unsigned int *)kp->arg) = num;
-- 
1.7.10.4


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
