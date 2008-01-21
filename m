From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [IPV4] igmp sparse warnings
Date: Mon, 21 Jan 2008 09:52:17 -0800
Message-ID: <20080121095217.4ddbcaf8@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57308 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751583AbYAURz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 12:55:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Partial sparse warning fix.  The other conditional locking
is too much for sparse to handle.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/igmp.c	2008-01-21 09:35:58.000000000 -0800
+++ b/net/ipv4/igmp.c	2008-01-21 09:36:20.000000000 -0800
@@ -2329,6 +2329,7 @@ static struct ip_mc_list *igmp_mc_get_id
 }
 
 static void *igmp_mc_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(dev_base_lock)
 {
 	read_lock(&dev_base_lock);
 	return *pos ? igmp_mc_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
@@ -2346,6 +2347,7 @@ static void *igmp_mc_seq_next(struct seq
 }
 
 static void igmp_mc_seq_stop(struct seq_file *seq, void *v)
+	__releases(dev_base_lock)
 {
 	struct igmp_mc_iter_state *state = igmp_mc_seq_private(seq);
 	if (likely(state->in_dev != NULL)) {
