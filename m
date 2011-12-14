From: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 09/11] SUNRPC: remove xs_tcp_fin_timeout variable
Date: Wed, 14 Dec 2011 14:45:54 +0300
Message-ID: <20111214104554.3991.56903.stgit@localhost6.localdomain6>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111214103602.3991.20990.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a cleanup patch. Static xs_tcp_fin_timeout is not needed anymore.

Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>

---
 net/sunrpc/xprtsock.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 49219d2..610a74a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -61,7 +61,6 @@ unsigned int xprt_min_resvport = RPC_DEF_MIN_RESVPORT;
 unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
 
 #define XS_TCP_LINGER_TO	(15U * HZ)
-static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
 
 /*
  * We can register our own files under /proc/sys/sunrpc by
@@ -129,7 +128,7 @@ static ctl_table xs_tunables_table[] = {
 	},
 	{
 		.procname	= "tcp_fin_timeout",
-		.maxlen		= sizeof(xs_tcp_fin_timeout),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
@@ -2930,7 +2929,7 @@ int socket_sysctl_init(struct net *net)
 	sn->xprt_max_tcp_slot_table_entries = xprt_max_tcp_slot_table_entries;
 	sn->xprt_min_resvport = xprt_min_resvport;
 	sn->xprt_max_resvport = xprt_max_resvport;
-	sn->xs_tcp_fin_timeout = xs_tcp_fin_timeout;
+	sn->xs_tcp_fin_timeout = XS_TCP_LINGER_TO;
 #ifdef RPC_DEBUG
 	return create_xs_tunables_table(net);
 #else

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
