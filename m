From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] (4/4) convert irlan to seq_file interface
Date: Wed, 20 Aug 2003 00:36:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820003648.A23942@electric-eye.fr.zoreil.com>
References: <20030818122702.67e9162d.shemminger@osdl.org> <20030818232554.A7779@electric-eye.fr.zoreil.com> <20030818150514.310f6f5d.shemminger@osdl.org> <20030819002637.B7779@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
   "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030819002637.B7779@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Tue, Aug 19, 2003 at 12:26:37AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Apply on top of Stephen's serie [1-4]. Compile ok.

Style: separate data from code.


 net/irda/irlan/irlan_filter.c |   34 ++++++++++++++++++++--------------
 1 files changed, 20 insertions(+), 14 deletions(-)

diff -puN net/irda/irlan/irlan_filter.c~irlan-fr-0 net/irda/irlan/irlan_filter.c
--- linux-2.6.0-test3/net/irda/irlan/irlan_filter.c~irlan-fr-0	Wed Aug 20 00:07:37 2003
+++ linux-2.6.0-test3-fr/net/irda/irlan/irlan_filter.c	Wed Aug 20 00:18:50 2003
@@ -218,23 +218,29 @@ void irlan_check_command_param(struct ir
  *
  */
 #ifdef CONFIG_PROC_FS
+#define MASK2STR(m,s)	{ .mask = m, .str = s }
+
 void irlan_print_filter(struct seq_file *seq, int filter_type)
 {
-	if (filter_type & IRLAN_DIRECTED)
-		seq_printf(seq, "%s", "DIRECTED ");
-	if (filter_type & IRLAN_FUNCTIONAL)
-		seq_printf(seq, "%s", "FUNCTIONAL ");
-	if (filter_type & IRLAN_GROUP)
-		seq_printf(seq, "%s", "GROUP ");
-	if (filter_type & IRLAN_MAC_FRAME)
-		seq_printf(seq, "%s", "MAC_FRAME ");
-	if (filter_type & IRLAN_MULTICAST)
-		seq_printf(seq, "%s", "MULTICAST ");
-	if (filter_type & IRLAN_BROADCAST)
-		seq_printf(seq, "%s", "BROADCAST ");
-	if (filter_type & IRLAN_IPX_SOCKET)
-		seq_printf(seq, "%s", "IPX_SOCKET");
+	static struct {
+		int mask;
+		const char *str;
+	} filter_mask2str[] = {
+		MASK2STR(IRLAN_DIRECTED,	"DIRECTED"),
+		MASK2STR(IRLAN_FUNCTIONAL,	"FUNCTIONAL"),
+		MASK2STR(IRLAN_GROUP,		"GROUP"),
+		MASK2STR(IRLAN_MAC_FRAME,	"MAC_FRAME"),
+		MASK2STR(IRLAN_MULTICAST,	"MULTICAST"),
+		MASK2STR(IRLAN_BROADCAST,	"BROADCAST"),
+		MASK2STR(IRLAN_IPX_SOCKET,	"IPX_SOCKET"),
+		MASK2STR(0,			NULL)
+	}, *p;
 
+	for (p = filter_mask2str; p->str; p++) {
+		if (filter_type & p->mask)
+			seq_printf(seq, "%s ", p->str);
+	}
 	seq_putc(seq, '\n');
 }
+#undef MASK2STR
 #endif

_
