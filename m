From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/3] net: pktgen: Adjust five checks for null pointers
Date: Mon, 22 May 2017 11:14:37 +0200
Message-ID: <9cbf8dea-1a36-9388-af71-9c07d788d0af@users.sourceforge.net>
References: <79472009-7764-bb92-5f29-60bb21793cec@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Florian Westphal <fw@strlen.de>,
        =?UTF-8?B?R8O8bnRlciBSw7Zjaw==?= <linux@roeck-us.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Willem de Bruijn <willemb@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <79472009-7764-bb92-5f29-60bb21793cec@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 10:44:16 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script “checkpatch.pl” pointed information out like the following.

Comparison to NULL could be written !…

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/core/pktgen.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 51008ddc7af6..a28350c9ac67 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1986,7 +1986,7 @@ static void pktgen_mark_device(const struct pktgen_net *pn, const char *ifname)
 	while (1) {
 
 		pkt_dev = __pktgen_NN_threads(pn, ifname, REMOVE);
-		if (pkt_dev == NULL)
+		if (!pkt_dev)
 			break;	/* success */
 
 		mutex_unlock(&pktgen_thread_lock);
@@ -3274,7 +3274,7 @@ static struct pktgen_dev *next_to_run(struct pktgen_thread *t)
 	list_for_each_entry_rcu(pkt_dev, &t->if_list, list) {
 		if (!pkt_dev->running)
 			continue;
-		if (best == NULL)
+		if (!best)
 			best = pkt_dev;
 		else if (ktime_compare(pkt_dev->next_tx, best->next_tx) < 0)
 			best = pkt_dev;
@@ -3402,7 +3402,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		kfree_skb(pkt_dev->skb);
 
 		pkt_dev->skb = fill_packet(odev, pkt_dev);
-		if (pkt_dev->skb == NULL) {
+		if (!pkt_dev->skb) {
 			pr_err("ERROR: couldn't allocate skb in fill_packet\n");
 			schedule();
 			pkt_dev->clone_count--;	/* back out increment, OOM */
@@ -3685,7 +3685,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	strcpy(pkt_dev->odevname, ifname);
 	pkt_dev->flows = vzalloc_node(MAX_CFLOWS * sizeof(struct flow_state),
 				      node);
-	if (pkt_dev->flows == NULL) {
+	if (!pkt_dev->flows) {
 		kfree(pkt_dev);
 		return -ENOMEM;
 	}
@@ -3868,7 +3868,7 @@ static int __net_init pg_net_init(struct net *net)
 		return -ENODEV;
 	}
 	pe = proc_create(PGCTRL, 0600, pn->proc_dir, &pktgen_fops);
-	if (pe == NULL) {
+	if (!pe) {
 		pr_err("cannot create %s procfs entry\n", PGCTRL);
 		ret = -EINVAL;
 		goto remove;
-- 
2.13.0
