From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net 3/5] openvswitch: Fix ovs_dp_cmd_msg_size()
Date: Sun,  2 Feb 2014 17:08:04 -0800
Message-ID: <1391389686-34303-4-git-send-email-jesse@nicira.com>
References: <1391389686-34303-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	dev-yBygre7rU0SM8Zsap4Y0gw@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1391389686-34303-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

commit 43d4be9cb55f3bac5253e9289996fd9d735531db (openvswitch: Allow user space
to announce ability to accept unaligned Netlink messages) introduced
OVS_DP_ATTR_USER_FEATURES netlink attribute in datapath responses,
but the attribute size was not taken into account in ovs_dp_cmd_msg_size().

Signed-off-by: Daniele Di Proietto <daniele.di.proietto-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ea0b30f..8b392cc 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1084,6 +1084,7 @@ static size_t ovs_dp_cmd_msg_size(void)
 	msgsize += nla_total_size(IFNAMSIZ);
 	msgsize += nla_total_size(sizeof(struct ovs_dp_stats));
 	msgsize += nla_total_size(sizeof(struct ovs_dp_megaflow_stats));
+	msgsize += nla_total_size(sizeof(u32)); /* OVS_DP_ATTR_USER_FEATURES */
 
 	return msgsize;
 }
-- 
1.8.3.2
