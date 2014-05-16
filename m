From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 05/12] openvswitch: Use net_ratelimit in
	OVS_NLERR
Date: Fri, 16 May 2014 14:07:32 -0700
Message-ID: <1400274459-56304-6-git-send-email-jesse@nicira.com>
References: <1400274459-56304-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
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

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

Each use of pr_<level>_once has a per-site flag.

Some of the OVS_NLERR messages look as if seeing them
multiple times could be useful, so use net_ratelimit()
instead of pr_info_once.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/datapath.h | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 0531738..7ede507 100644
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
-- 
1.9.1
