From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 20/43] drivers/net/hamradio: fix sparse warning: context
	imbalance
Date: Sat, 14 Feb 2009 22:34:52 +0100
Message-ID: <20090214213329.24377.28382.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:51625 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158AbZBNVfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:35:02 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Attribute functions with __acquires(...) resp. __releases(...).

Fix this sparse warnings:
  drivers/net/hamradio/bpqether.c:387:13: warning: context imbalance in 'bpq_seq_start' - wrong count at exit
  drivers/net/hamradio/bpqether.c:419:13: warning: context imbalance in 'bpq_seq_stop' - unexpected unlock

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/hamradio/bpqether.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 723e9c1..44b183b 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -386,6 +386,7 @@ static int bpq_close(struct net_device *dev)
  *	Proc filesystem
  */
 static void *bpq_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(RCU)
 {
 	int i = 1;
 	struct bpqdev *bpqdev;
@@ -418,6 +419,7 @@ static void *bpq_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void bpq_seq_stop(struct seq_file *seq, void *v)
+	__releases(RCU)
 {
 	rcu_read_unlock();
 }

