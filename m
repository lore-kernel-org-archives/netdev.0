From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 2/6] openvswitch: Fix ovs_vport_cmd_new return
	value on success
Date: Thu, 14 Mar 2013 17:15:02 -0700
Message-ID: <1363306506-885-3-git-send-email-jesse@nicira.com>
References: <1363306506-885-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1363306506-885-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Rich Lane <rlane-oPdFNf9WwoK1Z/+hSey0Gg@public.gmane.org>

If the pointer does not represent an error then the PTR_ERR
macro may still return a nonzero value.

Signed-off-by: Rich Lane <rlane-oPdFNf9WwoK1Z/+hSey0Gg@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 5e275b9..a2cd3e6 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1691,6 +1691,7 @@ static int ovs_vport_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(vport))
 		goto exit_unlock;
 
+	err = 0;
 	reply = ovs_vport_cmd_build_info(vport, info->snd_portid, info->snd_seq,
 					 OVS_VPORT_CMD_NEW);
 	if (IS_ERR(reply)) {
-- 
1.7.10.4
