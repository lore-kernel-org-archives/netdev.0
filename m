From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 2/7] openvswitch: Do not send
	notification if ovs_vport_set_options() failed
Date: Fri, 20 Jul 2012 15:26:45 -0700
Message-ID: <1342823210-3308-3-git-send-email-jesse@nicira.com>
References: <1342823210-3308-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1342823210-3308-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Ansis Atteka <aatteka-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

There is no need to send a notification if ovs_vport_set_options() failed
and ovs_vport_cmd_set() did not change anything.

Signed-off-by: Ansis Atteka <aatteka-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index e44e631..4813d95 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1635,7 +1635,9 @@ static int ovs_vport_cmd_set(struct sk_buff *skb, struct genl_info *info)
 
 	if (!err && a[OVS_VPORT_ATTR_OPTIONS])
 		err = ovs_vport_set_options(vport, a[OVS_VPORT_ATTR_OPTIONS]);
-	if (!err && a[OVS_VPORT_ATTR_UPCALL_PID])
+	if (err)
+		goto exit_unlock;
+	if (a[OVS_VPORT_ATTR_UPCALL_PID])
 		vport->upcall_pid = nla_get_u32(a[OVS_VPORT_ATTR_UPCALL_PID]);
 
 	reply = ovs_vport_cmd_build_info(vport, info->snd_pid, info->snd_seq,
-- 
1.7.9.5
