From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [VLAN] sparse warning fix
Date: Mon, 21 Jan 2008 09:48:49 -0800
Message-ID: <20080121094849.1e2ccee1@deepthought>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
	<20080121.003406.162149599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:57236 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537AbYAURwA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 12:52:00 -0500
In-Reply-To: <20080121.003406.162149599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor sparse warning fix.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/8021q/vlanproc.c	2008-01-21 09:30:44.000000000 -0800
+++ b/net/8021q/vlanproc.c	2008-01-21 09:31:54.000000000 -0800
@@ -220,6 +220,7 @@ static inline int is_vlan_dev(struct net
 
 /* start read of /proc/net/vlan/config */
 static void *vlan_seq_start(struct seq_file *seq, loff_t *pos)
+ 	__acquires(dev_base_lock)
 {
 	struct net_device *dev;
 	loff_t i = 1;
@@ -261,6 +262,7 @@ static void *vlan_seq_next(struct seq_fi
 }
 
 static void vlan_seq_stop(struct seq_file *seq, void *v)
+	__releases(dev_base_lock)
 {
 	read_unlock(&dev_base_lock);
 }


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
