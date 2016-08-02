From: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1137/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:37 +0800
Message-ID: <20160802121937.25917-1-baolex.ni@intel.com>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, smayhew-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
	chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org
To: bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org,
	trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
	m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
	k.kozlowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 net/sunrpc/auth_gss/auth_gss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index e64ae93..a581a9d 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -2081,13 +2081,13 @@ MODULE_ALIAS("rpc-auth-6");
 MODULE_LICENSE("GPL");
 module_param_named(expired_cred_retry_delay,
 		   gss_expired_cred_retry_delay,
-		   uint, 0644);
+		   uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(expired_cred_retry_delay, "Timeout (in seconds) until "
 		"the RPC engine retries an expired credential");
 
 module_param_named(key_expire_timeo,
 		   gss_key_expire_timeo,
-		   uint, 0644);
+		   uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(key_expire_timeo, "Time (in seconds) at the end of a "
 		"credential keys lifetime where the NFS layer cleans up "
 		"prior to key expiration");
-- 
2.9.2

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
