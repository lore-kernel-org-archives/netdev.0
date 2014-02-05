From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 5/5] openvswitch: Suppress error messages on
	megaflow updates
Date: Tue,  4 Feb 2014 22:59:21 -0800
Message-ID: <1391583561-25399-6-git-send-email-jesse@nicira.com>
References: <1391583561-25399-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1391583561-25399-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andy Zhou <azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

With subfacets, we'd expect megaflow updates message to carry
the original micro flow. If not, EINVAL is returned and kernel
logs an error message.  Now that the user space subfacet layer is
removed, it is expected that flow updates can arrive with a
micro flow other than the original. Change the return code to
EEXIST and remove the kernel error log message.

Reported-by: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Andy Zhou <azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 58689dd..e9a48ba 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -860,11 +860,8 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 			goto err_unlock_ovs;
 
 		/* The unmasked key has to be the same for flow updates. */
-		error = -EINVAL;
-		if (!ovs_flow_cmp_unmasked_key(flow, &match)) {
-			OVS_NLERR("Flow modification message rejected, unmasked key does not match.\n");
+		if (!ovs_flow_cmp_unmasked_key(flow, &match))
 			goto err_unlock_ovs;
-		}
 
 		/* Update actions. */
 		old_acts = ovsl_dereference(flow->sf_acts);
-- 
1.8.3.2
