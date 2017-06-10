From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next] sctp: use read_lock_bh in sctp_eps_seq_show
Date: Sat, 10 Jun 2017 15:13:32 +0800
Message-ID: <f845585a99f0cb76659f4d5dae4f7d6fd5552224.1497078812.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34667 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751797AbdFJHNl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 03:13:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to use read_lock_bh instead of local_bh_disable
and read_lock in sctp_eps_seq_show.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/proc.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 5a27d0f..8e34db5 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -218,8 +218,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 		return -ENOMEM;
 
 	head = &sctp_ep_hashtable[hash];
-	local_bh_disable();
-	read_lock(&head->lock);
+	read_lock_bh(&head->lock);
 	sctp_for_each_hentry(epb, &head->chain) {
 		ep = sctp_ep(epb);
 		sk = epb->sk;
@@ -234,8 +233,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 		sctp_seq_dump_local_addrs(seq, epb);
 		seq_printf(seq, "\n");
 	}
-	read_unlock(&head->lock);
-	local_bh_enable();
+	read_unlock_bh(&head->lock);
 
 	return 0;
 }
-- 
2.1.0
