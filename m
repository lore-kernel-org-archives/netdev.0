From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 10/10] staging/irda/net: Use seq_puts() in four functions
Date: Thu, 12 Oct 2017 12:50:29 +0200
Message-ID: <17f62072-0f1d-c32c-c568-02a0690235b7@users.sourceforge.net>
References: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Al Viro <viro@zeniv.linux.org.uk>, Corentin Labbe
 <clabbe.montjoie@gmail.com>, David Howells <dhowells@redhat.com>,
 "David S. Miller" <davem@davemloft.net>,
 Georgiana Chelu <georgiana.chelu93@gmail.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Johannes Berg <johannes.berg@intel.com>, Julia Lawall
 <julia.lawall@lip6.fr>, Samuel Ortiz <samuel@sortiz.org>,
 Srishti Sharma <srishtishar@gmail.com>,
 Stephen Hemminger <stephen@networkplumber.org>,
 Yuan Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Content-Language: en-GB
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 12 Oct 2017 11:08:36 +0200

Strings which did not contain a data format specification should be put
into a sequence. Thus use the corresponding function "seq_puts".

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/irda/net/ircomm/ircomm_core.c | 8 ++++----
 drivers/staging/irda/net/ircomm/ircomm_tty.c  | 2 +-
 drivers/staging/irda/net/irlan/irlan_common.c | 3 +--
 drivers/staging/irda/net/irlmp.c              | 2 +-
 4 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/irda/net/ircomm/ircomm_core.c b/drivers/staging/irda/net/ircomm/ircomm_core.c
index 6c02fbf380bd..9bb2ff306470 100644
--- a/drivers/staging/irda/net/ircomm/ircomm_core.c
+++ b/drivers/staging/irda/net/ircomm/ircomm_core.c
@@ -530,13 +530,13 @@ static int ircomm_seq_show(struct seq_file *seq, void *v)
 		   self->slsap_sel, self->dlsap_sel);
 
 	if(self->service_type & IRCOMM_3_WIRE_RAW)
-		seq_printf(seq, " 3-wire-raw");
+		seq_puts(seq, " 3-wire-raw");
 	if(self->service_type & IRCOMM_3_WIRE)
-		seq_printf(seq, " 3-wire");
+		seq_puts(seq, " 3-wire");
 	if(self->service_type & IRCOMM_9_WIRE)
-		seq_printf(seq, " 9-wire");
+		seq_puts(seq, " 9-wire");
 	if(self->service_type & IRCOMM_CENTRONICS)
-		seq_printf(seq, " Centronics");
+		seq_puts(seq, " Centronics");
 	seq_putc(seq, '\n');
 
 	return 0;
diff --git a/drivers/staging/irda/net/ircomm/ircomm_tty.c b/drivers/staging/irda/net/ircomm/ircomm_tty.c
index d1beec413fa3..dc7097576917 100644
--- a/drivers/staging/irda/net/ircomm/ircomm_tty.c
+++ b/drivers/staging/irda/net/ircomm/ircomm_tty.c
@@ -1174,7 +1174,7 @@ static void ircomm_tty_line_info(struct ircomm_tty_cb *self, struct seq_file *m)
 
 	seq_printf(m, "Port name: %s\n", self->settings.port_name);
 
-	seq_printf(m, "DTE status:");
+	seq_puts(m, "DTE status:");
 	sep = ' ';
 	if (self->settings.dte & IRCOMM_RTS) {
 		seq_printf(m, "%cRTS", sep);
diff --git a/drivers/staging/irda/net/irlan/irlan_common.c b/drivers/staging/irda/net/irlan/irlan_common.c
index 481bbc2a4349..f4633d4dc390 100644
--- a/drivers/staging/irda/net/irlan/irlan_common.c
+++ b/drivers/staging/irda/net/irlan/irlan_common.c
@@ -1138,8 +1138,7 @@ static int irlan_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq,"media: %s\n",
 			       irlan_media[self->media]);
 
-		seq_printf(seq,"local filter:\n");
-		seq_printf(seq,"remote filter: ");
+		seq_puts(seq, "local filter:\nremote filter: ");
 		irlan_print_filter(seq, self->client.filter_type);
 		seq_printf(seq,"tx busy: %s\n",
 			       netif_queue_stopped(self->dev) ? "TRUE" : "FALSE");
diff --git a/drivers/staging/irda/net/irlmp.c b/drivers/staging/irda/net/irlmp.c
index 6a09cf621bd4..60a3dd7d6f49 100644
--- a/drivers/staging/irda/net/irlmp.c
+++ b/drivers/staging/irda/net/irlmp.c
@@ -1937,7 +1937,7 @@ static int irlmp_seq_show(struct seq_file *seq, void *v)
 		 * the object spinlock, so we are safe. Jean II */
 		spin_lock(&lap->lsaps->hb_spinlock);
 
-		seq_printf(seq, "\n  Connected LSAPs:\n");
+		seq_puts(seq, "\n  Connected LSAPs:\n");
 		for (self = (struct lsap_cb *) hashbin_get_first(lap->lsaps);
 		     self;
 		     self = (struct lsap_cb *)hashbin_get_next(lap->lsaps)) {
-- 
2.14.2
