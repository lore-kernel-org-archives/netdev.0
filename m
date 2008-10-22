From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 01/13] put_cmsg_compat + SO_TIMESTAMP[NS]: use same
	name for value as caller
Date: Wed, 22 Oct 2008 14:46:39 +0200
Message-ID: <1226415403.31699.0.camel@ecld0pohly>
References: <1226414697.17450.852.camel@ecld0pohly>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34540 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755837AbYKKO4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 09:56:44 -0500
In-Reply-To: <1226414697.17450.852.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In __sock_recv_timestamp() the additional SCM_TIMESTAMP[NS] is used. This
has the same value as SO_TIMESTAMP[NS], so this is a purely cosmetic change.

Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
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


