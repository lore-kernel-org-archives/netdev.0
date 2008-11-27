From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 25/29: nf_conntrack_ftp: change "partial ..." message to pr_debug()
Date: Thu, 27 Nov 2008 17:15:37 +0100 (MET)
Message-ID: <20081127161536.13891.30643.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53427 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605AbYK0QPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 11:15:38 -0500
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4813eadf6b17caa7fcce67ac2f929a3dd5178fa2
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 24 18:34:48 2008 +0100

    netfilter: nf_conntrack_ftp: change "partial ..." message to pr_debug()
    
    The message triggers when sending non-FTP data on port 21 or with
    certain clients that use multiple syscalls to send the command.
    
    Change to pr_debug() since users have been complaining.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 703a437..867cad6 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -428,10 +428,8 @@ static int help(struct sk_buff *skb,
 		   connection tracking, not packet filtering.
 		   However, it is necessary for accurate tracking in
 		   this case. */
-		if (net_ratelimit())
-			printk("conntrack_ftp: partial %s %u+%u\n",
-			       search[dir][i].pattern,
-			       ntohl(th->seq), datalen);
+		pr_debug("conntrack_ftp: partial %s %u+%u\n",
+			 search[dir][i].pattern,  ntohl(th->seq), datalen);
 		ret = NF_DROP;
 		goto out;
 	} else if (found == 0) { /* No match */
