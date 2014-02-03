From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [RFC PATCH] openvswitch: Use net_ratelimit in OVS_NLERR
Date: Sun, 02 Feb 2014 22:55:26 -0800
Message-ID: <1391410526.2784.9.camel@joe-AO722>
References: <1391389686-34303-1-git-send-email-jesse@nicira.com>
	<1391389686-34303-6-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	dev-yBygre7rU0SM8Zsap4Y0gw@public.gmane.org
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1391389686-34303-6-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

Perhaps it'd make sense to use net_ratelimit()
instead of printk_once for OVS_NLERR
---
 net/openvswitch/datapath.h | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 6be9fbb..0f5e77c 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -194,7 +194,9 @@ struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 pid, u32 seq,
 int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb);
 void ovs_dp_notify_wq(struct work_struct *work);
 
-#define OVS_NLERR(fmt, ...) \
-	pr_info_once("netlink: " fmt, ##__VA_ARGS__)
-
+#define OVS_NLERR(fmt, ...)					\
+do {								\
+	if (net_ratelimit())					\
+		pr_info("netlink: " fmt, ##__VA_ARGS__);	\
+} while (0)
 #endif /* datapath.h */
