From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v2] sctp: Add process name and pid to deprecation warnings
Date: Thu,  2 Jan 2014 15:39:27 -0500
Message-ID: <1388695167-21896-1-git-send-email-nhorman@tuxdriver.com>
References: <1388685267-18319-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46650 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521AbaABUkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 15:40:00 -0500
In-Reply-To: <1388685267-18319-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I updated the sctp socket option deprecation warnings to be both a bit
more clear and ratelimited to prevent user processes from spamming the log file.
Ben Hutchings suggested that I add the process name and pid to these warnings so
that users can tell who is responsible for using the deprecated apis.  This
patch accomplishes that.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org

---
Change Notes
v2) Convert formatting to use  %s (%d) rather than %s (pid %d) as per request
from Ben
---
 net/sctp/socket.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e9c5121..bcc71aa 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2579,8 +2579,10 @@ static int sctp_setsockopt_delayed_ack(struct sock *sk,
 			return 0;
 	} else if (optlen == sizeof(struct sctp_assoc_value)) {
 		pr_warn_ratelimited(DEPRECATED
+				    "%s (%d) "
 				    "Use of struct sctp_assoc_value in delayed_ack socket option.\n"
-				    "Use struct sctp_sack_info instead\n");
+				    "Use struct sctp_sack_info instead\n",
+				    current->comm, task_pid_nr(current));
 		if (copy_from_user(&params, optval, optlen))
 			return -EFAULT;
 
@@ -2996,8 +2998,10 @@ static int sctp_setsockopt_maxseg(struct sock *sk, char __user *optval, unsigned
 
 	if (optlen == sizeof(int)) {
 		pr_warn_ratelimited(DEPRECATED
+				    "%s (%d) "
 				    "Use of int in maxseg socket option.\n"
-				    "Use struct sctp_assoc_value instead\n");
+				    "Use struct sctp_assoc_value instead\n",
+				    current->comm, task_pid_nr(current));
 		if (copy_from_user(&val, optval, optlen))
 			return -EFAULT;
 		params.assoc_id = 0;
@@ -3255,8 +3259,10 @@ static int sctp_setsockopt_maxburst(struct sock *sk,
 
 	if (optlen == sizeof(int)) {
 		pr_warn_ratelimited(DEPRECATED
+				    "%s (%d) "
 				    "Use of int in max_burst socket option deprecated.\n"
-				    "Use struct sctp_assoc_value instead\n");
+				    "Use struct sctp_assoc_value instead\n",
+				    current->comm, task_pid_nr(current));
 		if (copy_from_user(&val, optval, optlen))
 			return -EFAULT;
 	} else if (optlen == sizeof(struct sctp_assoc_value)) {
@@ -4577,8 +4583,10 @@ static int sctp_getsockopt_delayed_ack(struct sock *sk, int len,
 			return -EFAULT;
 	} else if (len == sizeof(struct sctp_assoc_value)) {
 		pr_warn_ratelimited(DEPRECATED
+				    "%s (%d) "
 				    "Use of struct sctp_assoc_value in delayed_ack socket option.\n"
-				    "Use struct sctp_sack_info instead\n");
+				    "Use struct sctp_sack_info instead\n",
+				    current->comm, task_pid_nr(current));
 		if (copy_from_user(&params, optval, len))
 			return -EFAULT;
 	} else
@@ -5223,8 +5231,10 @@ static int sctp_getsockopt_maxseg(struct sock *sk, int len,
 
 	if (len == sizeof(int)) {
 		pr_warn_ratelimited(DEPRECATED
+				    "%s (%d) "
 				    "Use of int in maxseg socket option.\n"
-				    "Use struct sctp_assoc_value instead\n");
+				    "Use struct sctp_assoc_value instead\n",
+				    current->comm, task_pid_nr(current));
 		params.assoc_id = 0;
 	} else if (len >= sizeof(struct sctp_assoc_value)) {
 		len = sizeof(struct sctp_assoc_value);
@@ -5316,8 +5326,10 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
 
 	if (len == sizeof(int)) {
 		pr_warn_ratelimited(DEPRECATED
+				    "%s (%d) "
 				    "Use of int in max_burst socket option.\n"
-				    "Use struct sctp_assoc_value instead\n");
+				    "Use struct sctp_assoc_value instead\n",
+				    current->comm, task_pid_nr(current));
 		params.assoc_id = 0;
 	} else if (len >= sizeof(struct sctp_assoc_value)) {
 		len = sizeof(struct sctp_assoc_value);
-- 
1.8.3.1
