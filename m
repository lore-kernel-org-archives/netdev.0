From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 03/14] sctp: remove the typedef sctp_scope_policy_t
Date: Sat,  5 Aug 2017 19:59:53 +0800
Message-ID: <09ffe75e4e16f00b61b682261e2a4b05fa76e814.1501934087.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
 <88e505f76dd927887d8cdcc7de2b82595237aa85.1501934087.git.lucien.xin@gmail.com>
 <7ceee2b1bf33403b8ecb04c9c30354f71dd2198a.1501934087.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33930 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751878AbdHEMAh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:00:37 -0400
In-Reply-To: <7ceee2b1bf33403b8ecb04c9c30354f71dd2198a.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_scope_policy_t and keep
it's members as an anonymous enum.

It is also to define SCTP_SCOPE_POLICY_MAX to replace the num 3
in sysctl.c to make codes clear.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h | 6 ++++--
 net/sctp/sysctl.c            | 2 +-
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 922fba5..acb03eb 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -341,12 +341,14 @@ typedef enum {
 	SCTP_SCOPE_UNUSABLE,		/* IPv4 unusable addresses */
 } sctp_scope_t;
 
-typedef enum {
+enum {
 	SCTP_SCOPE_POLICY_DISABLE,	/* Disable IPv4 address scoping */
 	SCTP_SCOPE_POLICY_ENABLE,	/* Enable IPv4 address scoping */
 	SCTP_SCOPE_POLICY_PRIVATE,	/* Follow draft but allow IPv4 private addresses */
 	SCTP_SCOPE_POLICY_LINK,		/* Follow draft but allow IPv4 link local addresses */
-} sctp_scope_policy_t;
+};
+
+#define SCTP_SCOPE_POLICY_MAX	SCTP_SCOPE_POLICY_LINK
 
 /* Based on IPv4 scoping <draft-stewart-tsvwg-sctp-ipv4-00.txt>,
  * SCTP IPv4 unusable addresses: 0.0.0.0/8, 224.0.0.0/4, 198.18.0.0/24,
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 0e732f6..ef7ca44 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -46,7 +46,7 @@ static int timer_max = 86400000; /* ms in one day */
 static int int_max = INT_MAX;
 static int sack_timer_min = 1;
 static int sack_timer_max = 500;
-static int addr_scope_max = 3; /* check sctp_scope_policy_t in include/net/sctp/constants.h for max entries */
+static int addr_scope_max = SCTP_SCOPE_POLICY_MAX;
 static int rwnd_scale_max = 16;
 static int rto_alpha_min = 0;
 static int rto_beta_min = 0;
-- 
2.1.0
