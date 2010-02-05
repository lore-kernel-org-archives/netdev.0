From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 04/13] net: rose: use seq_hlist_foo() helpers
Date: Fri, 05 Feb 2010 09:45:41 +0800
Message-ID: <4B6B7845.8070507@cn.fujitsu.com>
References: <4B6B77FE.5000104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B6B77FE.5000104@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify seq_file code.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/rose/af_rose.c |   22 +++-------------------
 1 files changed, 3 insertions(+), 19 deletions(-)

diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 8feb9e5..e90b9b6 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1404,29 +1404,13 @@ static int rose_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 static void *rose_info_start(struct seq_file *seq, loff_t *pos)
 	__acquires(rose_list_lock)
 {
-	int i;
-	struct sock *s;
-	struct hlist_node *node;
-
 	spin_lock_bh(&rose_list_lock);
-	if (*pos == 0)
-		return SEQ_START_TOKEN;
-
-	i = 1;
-	sk_for_each(s, node, &rose_list) {
-		if (i == *pos)
-			return s;
-		++i;
-	}
-	return NULL;
+	return seq_hlist_start_head(&rose_list, *pos);
 }
 
 static void *rose_info_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	++*pos;
-
-	return (v == SEQ_START_TOKEN) ? sk_head(&rose_list)
-		: sk_next((struct sock *)v);
+	return seq_hlist_next(v, &rose_list, pos);
 }
 
 static void rose_info_stop(struct seq_file *seq, void *v)
@@ -1444,7 +1428,7 @@ static int rose_info_show(struct seq_file *seq, void *v)
 			 "dest_addr  dest_call src_addr   src_call  dev   lci neigh st vs vr va   t  t1  t2  t3  hb    idle Snd-Q Rcv-Q inode\n");
 
 	else {
-		struct sock *s = v;
+		struct sock *s = sk_entry(v);
 		struct rose_sock *rose = rose_sk(s);
 		const char *devname, *callsign;
 		const struct net_device *dev = rose->device;
-- 
1.6.3
