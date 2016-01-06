From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net 3/3] ipv4: eliminate lock count warnings in ping.c
Date: Wed,  6 Jan 2016 17:22:47 -0500
Message-ID: <1452118967-32123-4-git-send-email-lrichard@redhat.com>
References: <1452118967-32123-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662AbcAFWWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 17:22:49 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id 0BC0B8C1B0
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 22:22:49 +0000 (UTC)
Received: from dhcp129-205.rdu.redhat.com (dhcp129-10.rdu.redhat.com [10.13.129.10])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u06MMlZq005846
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2016 17:22:48 -0500
In-Reply-To: <1452118967-32123-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add lock release/acquire annotations to ping_seq_start() and
ping_seq_stop() to satisfy sparse.

Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 net/ipv4/ping.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index e89094a..c117b21 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -1063,6 +1063,7 @@ static struct sock *ping_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 void *ping_seq_start(struct seq_file *seq, loff_t *pos, sa_family_t family)
+	__acquires(ping_table.lock)
 {
 	struct ping_iter_state *state = seq->private;
 	state->bucket = 0;
@@ -1094,6 +1095,7 @@ void *ping_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 EXPORT_SYMBOL_GPL(ping_seq_next);
 
 void ping_seq_stop(struct seq_file *seq, void *v)
+	__releases(ping_table.lock)
 {
 	read_unlock_bh(&ping_table.lock);
 }
-- 
2.5.0
