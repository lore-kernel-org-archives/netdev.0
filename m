From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: [PATCH] sunrpc: Add missing kuids conversion for printing
Date: Thu, 12 Sep 2013 15:09:39 +0200
Message-ID: <1378991379-9106-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

m68k/allmodconfig:

net/sunrpc/auth_generic.c: In function =E2=80=98generic_key_timeout=E2=80=
=99:
net/sunrpc/auth_generic.c:241: warning: format =E2=80=98%d=E2=80=99 exp=
ects type =E2=80=98int=E2=80=99, but
argument 2 has type =E2=80=98kuid_t=E2=80=99

commit cdba321e291f0fbf5abda4d88340292b858e3d4d ("sunrpc: Convert kuids=
 and
kgids to uids and gids for printing") forgot to convert one instance.

Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
---
 net/sunrpc/auth_generic.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index f6d84be..ed04869 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -239,7 +239,7 @@ generic_key_timeout(struct rpc_auth *auth, struct r=
pc_cred *cred)
 		if (test_and_clear_bit(RPC_CRED_KEY_EXPIRE_SOON,
 					&acred->ac_flags))
 			dprintk("RPC:        UID %d Credential key reset\n",
-				tcred->cr_uid);
+				from_kuid(&init_user_ns, tcred->cr_uid));
 		/* set up fasttrack for the normal case */
 		set_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags);
 	}
--=20
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
