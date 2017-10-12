From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 09/10] staging/irda/net: Combine some seq_printf() calls in
 two functions
Date: Thu, 12 Oct 2017 12:49:18 +0200
Message-ID: <a7428302-6ee3-59be-72ed-01048e51a403@users.sourceforge.net>
References: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        David Howells <dhowells@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Georgiana Chelu <georgiana.chelu93@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Samuel Ortiz <samuel@sortiz.org>,
        Srishti Sharma <srishtishar@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Yuan Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8152401b-d68d-c4fe-2619-82a09e0c52ec@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 12 Oct 2017 08:58:38 +0200

Some data were printed into a sequence by separate function calls.
Print the same data by a single function call at each place instead.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/staging/irda/net/irlap.c | 9 ++++-----
 drivers/staging/irda/net/irlmp.c | 6 ++----
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/irda/net/irlap.c b/drivers/staging/irda/net/irlap.c
index 715cedab2f41..345c4eb55a59 100644
--- a/drivers/staging/irda/net/irlap.c
+++ b/drivers/staging/irda/net/irlap.c
@@ -1141,9 +1141,9 @@ static int irlap_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "vr: %d ", self->vr);
 	seq_printf(seq, "va: %d\n", self->va);
 
-	seq_printf(seq, "  qos\tbps\tmaxtt\tdsize\twinsize\taddbofs\tmintt\tldisc\tcomp\n");
-
-	seq_printf(seq, "  tx\t%d\t",
+	seq_printf(seq,
+		   "  qos\tbps\tmaxtt\tdsize\twinsize\taddbofs\tmintt\tldisc\tcomp\n"
+		   "  tx\t%d\t",
 		   self->qos_tx.baud_rate.value);
 	seq_printf(seq, "%d\t",
 		   self->qos_tx.max_turn_time.value);
@@ -1157,9 +1157,8 @@ static int irlap_seq_show(struct seq_file *seq, void *v)
 		   self->qos_tx.min_turn_time.value);
 	seq_printf(seq, "%d\t",
 		   self->qos_tx.link_disc_time.value);
-	seq_printf(seq, "\n");
 
-	seq_printf(seq, "  rx\t%d\t",
+	seq_printf(seq, "\n  rx\t%d\t",
 		   self->qos_rx.baud_rate.value);
 	seq_printf(seq, "%d\t",
 		   self->qos_rx.max_turn_time.value);
diff --git a/drivers/staging/irda/net/irlmp.c b/drivers/staging/irda/net/irlmp.c
index 318660fbc094..6a09cf621bd4 100644
--- a/drivers/staging/irda/net/irlmp.c
+++ b/drivers/staging/irda/net/irlmp.c
@@ -1920,8 +1920,7 @@ static int irlmp_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq,
 			   "slsap_sel: %#02x, dlsap_sel: %#02x, ",
 			   self->slsap_sel, self->dlsap_sel);
-		seq_printf(seq, "(%s)", self->notify.name);
-		seq_printf(seq, "\n");
+		seq_printf(seq, "(%s)\n", self->notify.name);
 	} else if (iter->hashbin == irlmp->links) {
 		struct lap_cb *lap = v;
 
@@ -1930,9 +1929,8 @@ static int irlmp_seq_show(struct seq_file *seq, void *v)
 
 		seq_printf(seq, "saddr: %#08x, daddr: %#08x, ",
 			   lap->saddr, lap->daddr);
-		seq_printf(seq, "num lsaps: %d",
+		seq_printf(seq, "num lsaps: %d\n",
 			   HASHBIN_GET_SIZE(lap->lsaps));
-		seq_printf(seq, "\n");
 
 		/* Careful for priority inversions here !
 		 * All other uses of attrib spinlock are independent of
-- 
2.14.2
