From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 12/12] net/openvswitch: Use with
	RCU_INIT_POINTER(x, NULL) in vport-gre.c
Date: Fri, 16 May 2014 14:07:39 -0700
Message-ID: <1400274459-56304-13-git-send-email-jesse@nicira.com>
References: <1400274459-56304-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Monam Agarwal <monamagarwal123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

From: Monam Agarwal <monamagarwal123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure
is carried out before storing a pointer to that structure.
And in the case of the NULL pointer, there is no structure to initialize.
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/vport-gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 0856f01..35ec4fe 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -256,7 +256,7 @@ static void gre_tnl_destroy(struct vport *vport)
 
 	ovs_net = net_generic(net, ovs_net_id);
 
-	rcu_assign_pointer(ovs_net->vport_net.gre_vport, NULL);
+	RCU_INIT_POINTER(ovs_net->vport_net.gre_vport, NULL);
 	ovs_vport_deferred_free(vport);
 	gre_exit();
 }
-- 
1.9.1
