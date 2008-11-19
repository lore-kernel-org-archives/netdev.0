From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 01/11] put_cmsg_compat + SO_TIMESTAMP[NS]: use same name for value as caller
Date: Wed, 19 Nov 2008 13:08:38 +0100
Message-ID: <1227096528-24150-2-git-send-email-patrick.ohly@intel.com>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick Ohly <patrick.ohly@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58043 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752483AbYKSMIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 07:08:53 -0500
In-Reply-To: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In __sock_recv_timestamp() the additional SCM_TIMESTAMP[NS] is used. This
has the same value as SO_TIMESTAMP[NS], so this is a purely cosmetic change.
---
 net/compat.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/compat.c b/net/compat.c
index 67fb6a3..6ce1a1c 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -226,14 +226,14 @@ int put_cmsg_compat(struct msghdr *kmsg, int level, int type, int len, void *dat
 		return 0; /* XXX: return error? check spec. */
 	}
 
-	if (level == SOL_SOCKET && type == SO_TIMESTAMP) {
+	if (level == SOL_SOCKET && type == SCM_TIMESTAMP) {
 		struct timeval *tv = (struct timeval *)data;
 		ctv.tv_sec = tv->tv_sec;
 		ctv.tv_usec = tv->tv_usec;
 		data = &ctv;
 		len = sizeof(ctv);
 	}
-	if (level == SOL_SOCKET && type == SO_TIMESTAMPNS) {
+	if (level == SOL_SOCKET && type == SCM_TIMESTAMPNS) {
 		struct timespec *ts = (struct timespec *)data;
 		cts.tv_sec = ts->tv_sec;
 		cts.tv_nsec = ts->tv_nsec;
-- 
1.6.0.4

