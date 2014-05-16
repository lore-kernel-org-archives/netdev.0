From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 02/12] openvswitch: avoid warnings in
	vport_from_priv
Date: Fri, 16 May 2014 14:07:29 -0700
Message-ID: <1400274459-56304-3-git-send-email-jesse@nicira.com>
References: <1400274459-56304-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1400274459-56304-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

This change, firstly, avoids declaring the formal parameter const,
since it is treated as non const. (to avoid -Wcast-qual)
Secondly, it cast the pointer from void* to u8*, since it is used
in arithmetic (to avoid -Wpointer-arith)

Signed-off-by: Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/vport.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index d7e50a1..3e12940 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -185,9 +185,9 @@ static inline void *vport_priv(const struct vport *vport)
  * the result of a hash table lookup.  @priv must point to the start of the
  * private data area.
  */
-static inline struct vport *vport_from_priv(const void *priv)
+static inline struct vport *vport_from_priv(void *priv)
 {
-	return (struct vport *)(priv - ALIGN(sizeof(struct vport), VPORT_ALIGN));
+	return (struct vport *)((u8 *)priv - ALIGN(sizeof(struct vport), VPORT_ALIGN));
 }
 
 void ovs_vport_receive(struct vport *, struct sk_buff *,
-- 
1.9.1
