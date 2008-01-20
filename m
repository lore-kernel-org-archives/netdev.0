From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net: add sparse annotation to ptype_seq_start/stop
Date: Sun, 20 Jan 2008 15:21:46 -0800
Message-ID: <20080120152146.70bc0b12@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40356 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755261AbYATXYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 18:24:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of some more sparse warnings.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/dev.c	2008-01-20 14:25:00.000000000 -0800
+++ b/net/core/dev.c	2008-01-20 14:25:48.000000000 -0800
@@ -2543,6 +2543,7 @@ static void *ptype_get_idx(loff_t pos)
 }
 
 static void *ptype_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(rcu)
 {
 	rcu_read_lock();
 	return *pos ? ptype_get_idx(*pos - 1) : SEQ_START_TOKEN;
@@ -2578,6 +2579,7 @@ found:
 }
 
 static void ptype_seq_stop(struct seq_file *seq, void *v)
+	__releases(rcu)
 {
 	rcu_read_unlock();
 }
