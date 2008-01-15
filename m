From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [ATM]: Suppress some sparse warnings
Date: Tue, 15 Jan 2008 12:15:02 +0100
Message-ID: <20080115121502.5975e68f.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:58409 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145AbYAOLPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 06:15:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CHECK   net/atm/br2684.c
net/atm/br2684.c:665:13: warning: context imbalance in 'br2684_seq_start' - wrong count at exit
net/atm/br2684.c:676:13: warning: context imbalance in 'br2684_seq_stop' - unexpected unlock
  CHECK   net/atm/lec.c
net/atm/lec.c:196:23: warning: expensive signed divide
  CHECK   net/atm/proc.c
net/atm/proc.c:151:14: warning: context imbalance in 'vcc_seq_start' - wrong count at exit
net/atm/proc.c:154:13: warning: context imbalance in 'vcc_seq_stop' - unexpected unlock

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 net/atm/br2684.c |    2 ++
 net/atm/lec.c    |    2 +-
 net/atm/proc.c   |    2 ++
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 5c8a0dc..574d9a9 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -663,6 +663,7 @@ static struct atm_ioctl br2684_ioctl_ops = {
 
 #ifdef CONFIG_PROC_FS
 static void *br2684_seq_start(struct seq_file *seq, loff_t * pos)
+	__acquires(devs_lock)
 {
 	read_lock(&devs_lock);
 	return seq_list_start(&br2684_devs, *pos);
@@ -674,6 +675,7 @@ static void *br2684_seq_next(struct seq_file *seq, void *v, loff_t * pos)
 }
 
 static void br2684_seq_stop(struct seq_file *seq, void *v)
+	__releases(devs_lock)
 {
 	read_unlock(&devs_lock);
 }
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 0a9c426..1a8c4c6 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -176,7 +176,7 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 static unsigned char *get_tr_dst(unsigned char *packet, unsigned char *rdesc)
 {
 	struct trh_hdr *trh;
-	int riflen, num_rdsc;
+	unsigned int riflen, num_rdsc;
 
 	trh = (struct trh_hdr *)packet;
 	if (trh->daddr[0] & (uint8_t) 0x80)
diff --git a/net/atm/proc.c b/net/atm/proc.c
index 565e75e..4912511 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -142,6 +142,7 @@ static int vcc_seq_release(struct inode *inode, struct file *file)
 }
 
 static void *vcc_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(vcc_sklist_lock)
 {
 	struct vcc_state *state = seq->private;
 	loff_t left = *pos;
@@ -152,6 +153,7 @@ static void *vcc_seq_start(struct seq_file *seq, loff_t *pos)
 }
 
 static void vcc_seq_stop(struct seq_file *seq, void *v)
+	__releases(vcc_sklist_lock)
 {
 	read_unlock(&vcc_sklist_lock);
 }
