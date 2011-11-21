From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 2/5] genetlink: Add lockdep_genl_is_held().
Date: Mon, 21 Nov 2011 13:30:26 -0800
Message-ID: <1321911029-20707-3-git-send-email-jesse@nicira.com>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1321911029-20707-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

From: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>

Open vSwitch uses genl_mutex locking to protect datapath
data-structures like flow-table, flow-actions. Following patch adds
lockdep_genl_is_held() which is used for rcu annotation to prove
locking.

Signed-off-by: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
v2: Unchanged.
---
 include/linux/genetlink.h |    3 +++
 net/netlink/genetlink.c   |    8 ++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 61549b2..59311ad 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -85,6 +85,9 @@ enum {
 /* All generic netlink requests are serialized by a global lock.  */
 extern void genl_lock(void);
 extern void genl_unlock(void);
+#ifdef CONFIG_PROVE_LOCKING
+extern int lockdep_genl_is_held(void);
+#endif
 
 #endif /* __KERNEL__ */
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 8a36599..28453ae 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -33,6 +33,14 @@ void genl_unlock(void)
 }
 EXPORT_SYMBOL(genl_unlock);
 
+#ifdef CONFIG_PROVE_LOCKING
+int lockdep_genl_is_held(void)
+{
+	return lockdep_is_held(&genl_mutex);
+}
+EXPORT_SYMBOL(lockdep_genl_is_held);
+#endif
+
 #define GENL_FAM_TAB_SIZE	16
 #define GENL_FAM_TAB_MASK	(GENL_FAM_TAB_SIZE - 1)
 
-- 
1.7.5.4
