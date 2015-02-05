From: Miroslav Urbanek <mu@miroslavurbanek.com>
Subject: [PATCH] flowcache: Fix kernel panic in flow_cache_flush_task
Date: Thu, 5 Feb 2015 16:36:50 +0100
Message-ID: <20150205153649.GA3278@miroslavurbanek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	=?utf-8?B?VG9tw6HFoSBDaGFydsOhdA==?= <tc@excello.cz>,
	Jan Hejl <jh@excello.cz>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

flow_cache_flush_task references a structure member flow_cache_gc_work
where it should reference flow_cache_flush_task instead.

Kernel panic occurs on kernels using IPsec during XFRM garbage
collection. The garbage collection interval can be shortened using the
following sysctl settings:

net.ipv4.xfrm4_gc_thresh=3D4
net.ipv6.xfrm6_gc_thresh=3D4

With the default settings, our productions servers crash approximately
once a week. With the settings above, they crash immediately.

=46ixes: ca925cf1534e ("flowcache: Make flow cache name space aware")
Reported-by: Tom=C3=A1=C5=A1 Charv=C3=A1t <tc@excello.cz>
Tested-by: Jan Hejl <jh@excello.cz>
Signed-off-by: Miroslav Urbanek <mu@miroslavurbanek.com>
---
 net/core/flow.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index a0348fd..1033725 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -379,7 +379,7 @@ done:
 static void flow_cache_flush_task(struct work_struct *work)
 {
 	struct netns_xfrm *xfrm =3D container_of(work, struct netns_xfrm,
-						flow_cache_gc_work);
+						flow_cache_flush_work);
 	struct net *net =3D container_of(xfrm, struct net, xfrm);
=20
 	flow_cache_flush(net);
--=20
2.0.4
