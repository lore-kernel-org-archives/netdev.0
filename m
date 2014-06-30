From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] net: sctp: only warn in proc_sctp_do_alpha_beta if write
Date: Mon, 30 Jun 2014 13:52:09 +0200
Message-ID: <1404129129-23270-3-git-send-email-dborkman@redhat.com>
References: <1404129129-23270-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25185 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676AbaF3LwQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2014 07:52:16 -0400
In-Reply-To: <1404129129-23270-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only warn if the value is written to alpha or beta. We don't care
emitting a one-time warning when only reading it.

Reported-by: Jiri Pirko <jpirko@redhat.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/sysctl.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 12c7e01..2e9ada1 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -424,8 +424,9 @@ static int proc_sctp_do_alpha_beta(struct ctl_table *ctl, int write,
 				   void __user *buffer, size_t *lenp,
 				   loff_t *ppos)
 {
-	pr_warn_once("Changing rto_alpha or rto_beta may lead to "
-		     "suboptimal rtt/srtt estimations!\n");
+	if (write)
+		pr_warn_once("Changing rto_alpha or rto_beta may lead to "
+			     "suboptimal rtt/srtt estimations!\n");
 
 	return proc_dointvec_minmax(ctl, write, buffer, lenp, ppos);
 }
-- 
1.7.11.7
