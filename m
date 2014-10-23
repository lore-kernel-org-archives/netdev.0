From: Michele Baldessari <michele@acksyn.org>
Subject: [net 1/2] sctp: add transport state in /proc/net/sctp/remaddr
Date: Thu, 23 Oct 2014 21:48:40 +0200
Message-ID: <1414093721-14921-1-git-send-email-michele@acksyn.org>
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	dborkman@redhat.com, Michele Baldessari <michele@acksyn.org>
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:55134 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932619AbaJWT4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 15:56:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is often quite helpful to be able to know the state of a transport
outside of the application itself (for troubleshooting purposes or for
monitoring purposes). Add it under /proc/net/sctp/remaddr.

Signed-off-by: Michele Baldessari <michele@acksyn.org>
---
 net/sctp/proc.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 34229ee7f379..bfb242af06ab 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -417,7 +417,7 @@ static void *sctp_remaddr_seq_start(struct seq_file *seq, loff_t *pos)
 
 	if (*pos == 0)
 		seq_printf(seq, "ADDR ASSOC_ID HB_ACT RTO MAX_PATH_RTX "
-				"REM_ADDR_RTX  START\n");
+				"REM_ADDR_RTX START STATE\n");
 
 	return (void *)pos;
 }
@@ -497,7 +497,13 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 			 * currently implemented, but we can record it with a
 			 * jiffies marker in a subsequent patch
 			 */
-			seq_printf(seq, "0");
+			seq_printf(seq, "0 ");
+
+			/*
+			 * The current state of this destination. I.e.
+			 * SCTP_ACTIVE, SCTP_INACTIVE, ...
+			 */
+			seq_printf(seq, "%d", tsp->state);
 
 			seq_printf(seq, "\n");
 		}
-- 
2.1.0
