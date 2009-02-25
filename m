From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 1/8] net/802: fix sparse warnings: context imbalance
Date: Wed, 25 Feb 2009 21:31:24 +0100
Message-ID: <20090225203118.6251.34287.stgit@vmbox.hanneseder.net>
References: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758149AbZBYUbs@vger.kernel.org>
In-Reply-To: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Impact: Attribute function with __acquires(...) resp. __releases(...).

Fix this sparse warnings:
  net/802/tr.c:492:21: warning: context imbalance in 'rif_seq_start' - wrong count at exit
  net/802/tr.c:519:13: warning: context imbalance in 'rif_seq_stop' - unexpected unlock

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 net/802/tr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/802/tr.c b/net/802/tr.c
index 158150f..dab6334 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -486,6 +486,7 @@ static struct rif_cache *rif_get_idx(loff_t pos)
 }
 
 static void *rif_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(&rif_lock)
 {
 	spin_lock_irq(&rif_lock);
 
@@ -517,6 +518,7 @@ static void *rif_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void rif_seq_stop(struct seq_file *seq, void *v)
+	__releases(&rif_lock)
 {
 	spin_unlock_irq(&rif_lock);
 }
