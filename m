From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/3] sctp: remove rcu_read_lock in sctp_seq_dump_remote_addrs()
Date: Mon, 15 Feb 2016 14:28:04 +0800
Message-ID: <4e75be65afef4ccacca08e83316a8fbe811d5b1f.1455517541.git.lucien.xin@gmail.com>
References: <cover.1455517541.git.lucien.xin@gmail.com>
 <c805e4a1994f53947351e8d4dd79609fd206e807.1455517541.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33341 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbcBOG2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 01:28:19 -0500
In-Reply-To: <c805e4a1994f53947351e8d4dd79609fd206e807.1455517541.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1455517541.git.lucien.xin@gmail.com>
References: <cover.1455517541.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_seq_dump_remote_addrs is only called by sctp_assocs_seq_show()
and it has been protected by rcu_read_lock that is from
rhashtable_walk_start().

So we will remove this one.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/proc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index ded7d93..cfc3c71 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -161,7 +161,6 @@ static void sctp_seq_dump_remote_addrs(struct seq_file *seq, struct sctp_associa
 	struct sctp_af *af;
 
 	primary = &assoc->peer.primary_addr;
-	rcu_read_lock();
 	list_for_each_entry_rcu(transport, &assoc->peer.transport_addr_list,
 			transports) {
 		addr = &transport->ipaddr;
@@ -172,7 +171,6 @@ static void sctp_seq_dump_remote_addrs(struct seq_file *seq, struct sctp_associa
 		}
 		af->seq_dump_addr(seq, addr);
 	}
-	rcu_read_unlock();
 }
 
 static void *sctp_eps_seq_start(struct seq_file *seq, loff_t *pos)
-- 
2.1.0
