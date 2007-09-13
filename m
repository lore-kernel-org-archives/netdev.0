From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH for 2.6.24] SCTP: Move sysctl_sctp_[rw]mem definitions to
 protocol.c
Date: Thu, 13 Sep 2007 17:03:45 -0400
Message-ID: <46E9A5B1.5070202@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "lksctp-developers@lists.sourceforge.net"
	<lksctp-developers@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:52767 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251AbXIMVEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 17:04:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sctp_[rw]mem definitions should really be in protocol.c
since that is where they are initialized.  This also allows
one to build a kernel without sysctl support.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/protocol.c |    6 +++---
 net/sctp/sysctl.c   |   11 +++--------
 2 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 193835d..c49eb99 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -84,9 +84,9 @@ static struct sctp_af *sctp_af_v6_specific;
 struct kmem_cache *sctp_chunk_cachep __read_mostly;
 struct kmem_cache *sctp_bucket_cachep __read_mostly;
 
-extern int sysctl_sctp_mem[3];
-extern int sysctl_sctp_rmem[3];
-extern int sysctl_sctp_wmem[3];
+int sysctl_sctp_mem[3];
+int sysctl_sctp_rmem[3];
+int sysctl_sctp_wmem[3];
 
 /* Return the address of the control sock. */
 struct sock *sctp_get_ctl_sock(void)
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index ba75ef4..39b10ee 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -52,14 +52,9 @@ static int int_max = INT_MAX;
 static long sack_timer_min = 1;
 static long sack_timer_max = 500;
 
-int sysctl_sctp_mem[3];
-int sysctl_sctp_rmem[3];
-int sysctl_sctp_wmem[3];
-
-/*
- * per assoc memory limitationf for sends
- */
-int sysctl_sctp_wmem[3];
+extern int sysctl_sctp_mem[3];
+extern int sysctl_sctp_rmem[3];
+extern int sysctl_sctp_wmem[3];
 
 static ctl_table sctp_table[] = {
 	{
-- 
1.5.2.4

