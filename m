From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Subject: [PATCH net] igmp: fix byte order in /proc/net/igmp output
Date: Wed,  4 May 2016 14:11:24 +0200
Message-ID: <1462363884-34968-1-git-send-email-Eugene.Crosser@ru.ibm.com>
To: crosser@average.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:42763 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbcEDML5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 08:11:57 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <Eugene.Crosser@ru.ibm.com>;
	Wed, 4 May 2016 13:11:54 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 93BFC2190061
	for <netdev@vger.kernel.org>; Wed,  4 May 2016 13:11:01 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u44CBPl53670446
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 12:11:25 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u44CBOeH001013
	for <netdev@vger.kernel.org>; Wed, 4 May 2016 06:11:24 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/proc/net/igmp is a readonly attribute that shows multicast groups
to which different network interfaces are subscribed. Among other
things, it displays `multiaddr` which is a 32 bit network-byte-order
field, in hexadecimal format. Prior to this patch, the field was
displayed as an integer, resulting in reverse byte order on little
endian architectures. This patch converts it with ntohl() for display
the same way as this is done for the /proc/net/mcfilter attribute.

The patch changes (corrects) user-visible behaviour.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
---
 net/ipv4/igmp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index b3086cf..f9d2139 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2722,7 +2722,7 @@ static int igmp_mc_seq_show(struct seq_file *seq, void *v)
 		delta = im->timer.expires - jiffies;
 		seq_printf(seq,
 			   "\t\t\t\t%08X %5d %d:%08lX\t\t%d\n",
-			   im->multiaddr, im->users,
+			   ntohl(im->multiaddr), im->users,
 			   im->tm_running,
 			   im->tm_running ? jiffies_delta_to_clock_t(delta) : 0,
 			   im->reporter);
-- 
2.6.6
