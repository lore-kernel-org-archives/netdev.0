From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 5/8] decnet: fix sparse warnings: context imbalance
Date: Wed, 25 Feb 2009 21:32:25 +0100
Message-ID: <20090225203222.6251.63933.stgit@vmbox.hanneseder.net>
References: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761118AbZBYUcs@vger.kernel.org>
In-Reply-To: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Impact: Attribute functions with __acquires(...) resp. __releases(...).

Fix this sparse warnings:
  net/decnet/dn_dev.c:1324:13: warning: context imbalance in 'dn_dev_seq_start' - wrong count at exit
  net/decnet/dn_dev.c:1366:13: warning: context imbalance in 'dn_dev_seq_stop' - unexpected unlock

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 net/decnet/dn_dev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index daf2b98..5e21a2f 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1322,6 +1322,7 @@ static inline int is_dn_dev(struct net_device *dev)
 }
 
 static void *dn_dev_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(&dev_base_lock)
 {
 	int i;
 	struct net_device *dev;
@@ -1364,6 +1365,7 @@ static void *dn_dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void dn_dev_seq_stop(struct seq_file *seq, void *v)
+	__releases(&dev_base_lock)
 {
 	read_unlock(&dev_base_lock);
 }
