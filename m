From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] (1/4) netem - update API for new features
Date: Wed, 25 Aug 2004 10:53:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Extend netem options to support new features.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
--- a/include/linux/pkt_sched.h	2004-08-24 14:43:33 -07:00
+++ b/include/linux/pkt_sched.h	2004-08-24 14:43:33 -07:00
@@ -401,7 +401,8 @@
 
 #define TCA_ATM_MAX	TCA_ATM_STATE
 
-/* Network emulator */
+/* Network section */
+
 struct tc_netem_qopt
 {
 	__u32	latency;	/* added delay (us) */
@@ -409,6 +410,13 @@
 	__u32	loss;		/* random packet loss (0=none ~0=100%) */
 	__u32	gap;		/* re-ordering gap (0 for delay all) */
 	__u32   duplicate;	/* random packet dup  (0=none ~0=100%) */
-	__u32	jitter;		/* random jitter in latency (us) */
+	__u32	jitter;		/* delay sigma (us) */
+
+	__u32	delay_corr;	/* delay correllation (0=none ~0=100%) */
+	__u32	loss_corr;	/* packet loss correllation (0=none ~0=100%) */
+	__u32	dup_corr;	/* duplicate correlation (0=none ~0=100%) */
+
+	__s16	delay_dist[0];	/* delay distribution table (optional) */
+#define TCA_NETEM_TABLEFACTOR	8192
 };
 #endif
