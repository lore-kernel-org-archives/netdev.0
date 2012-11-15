From: Tommi Rantala <tt.rantala@gmail.com>
Subject: [PATCH] sctp: fix /proc/net/sctp/ memory leak
Date: Thu, 15 Nov 2012 10:23:22 +0200
Message-ID: <1352967802-2335-1-git-send-email-tt.rantala@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, Dave Jones <davej@redhat.com>,
	Tommi Rantala <tt.rantala@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:39433 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754028Ab2KOIZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 03:25:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are using single_open_net() and seq_open_net() in the opener
functions, so avoid leaking memory by using single_release_net() and
seq_release_net() as the struct file_operations release functions.

Discovered with Trinity (the syscall fuzzer).

Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
---
 net/sctp/proc.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index c3bea26..9966e7b 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -102,7 +102,7 @@ static const struct file_operations sctp_snmp_seq_fops = {
 	.open	 = sctp_snmp_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = single_release,
+	.release = single_release_net,
 };
 
 /* Set up the proc fs entry for 'snmp' object. */
@@ -251,7 +251,7 @@ static const struct file_operations sctp_eps_seq_fops = {
 	.open	 = sctp_eps_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
 /* Set up the proc fs entry for 'eps' object. */
@@ -372,7 +372,7 @@ static const struct file_operations sctp_assocs_seq_fops = {
 	.open	 = sctp_assocs_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
 /* Set up the proc fs entry for 'assocs' object. */
@@ -517,7 +517,7 @@ static const struct file_operations sctp_remaddr_seq_fops = {
 	.open = sctp_remaddr_seq_open,
 	.read = seq_read,
 	.llseek = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_net,
 };
 
 int __net_init sctp_remaddr_proc_init(struct net *net)
-- 
1.7.9.5
