From: Rashika Kheria <rashika.kheria-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: =?UTF-8?q?=5BPATCH=20v2=2013/13=5D=20net=3A=20Mark=20functions=20as=20static=20in=20net/sunrpc/svc=5Fxprt=2Ec?=
Date: Sun,  9 Feb 2014 22:33:03 +0530
Message-ID: <6683a8aafa491f99b0ae6e5a23614f1dbcac6ec2.1391955925.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391955924.git.rashika.kheria-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mark functions as static in net/sunrpc/svc_xprt.c because they are not
used outside this file.

This eliminates the following warning in net/sunrpc/svc_xprt.c:
net/sunrpc/svc_xprt.c:574:5: warning: no previous prototype for =E2=80=98=
svc_alloc_arg=E2=80=99 [-Wmissing-prototypes]
net/sunrpc/svc_xprt.c:615:18: warning: no previous prototype for =E2=80=
=98svc_get_next_xprt=E2=80=99 [-Wmissing-prototypes]
net/sunrpc/svc_xprt.c:694:6: warning: no previous prototype for =E2=80=98=
svc_add_new_temp_xprt=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>
---
 net/sunrpc/svc_xprt.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 80a6640..06c6ff0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -571,7 +571,7 @@ static void svc_check_conn_limits(struct svc_serv *=
serv)
 	}
 }
=20
-int svc_alloc_arg(struct svc_rqst *rqstp)
+static int svc_alloc_arg(struct svc_rqst *rqstp)
 {
 	struct svc_serv *serv =3D rqstp->rq_server;
 	struct xdr_buf *arg;
@@ -612,7 +612,7 @@ int svc_alloc_arg(struct svc_rqst *rqstp)
 	return 0;
 }
=20
-struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeou=
t)
+static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long=
 timeout)
 {
 	struct svc_xprt *xprt;
 	struct svc_pool		*pool =3D rqstp->rq_pool;
@@ -691,7 +691,7 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst =
*rqstp, long timeout)
 	return xprt;
 }
=20
-void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *new=
xpt)
+static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xp=
rt *newxpt)
 {
 	spin_lock_bh(&serv->sv_lock);
 	set_bit(XPT_TEMP, &newxpt->xpt_flags);
--=20
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
