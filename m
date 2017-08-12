From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 20/51] lib/inet_proto: Make sure destination buffers are NULL-terminated
Date: Sat, 12 Aug 2017 14:04:39 +0200
Message-ID: <20170812120510.28750-21-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47941 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752011AbdHLMHl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:07:41 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/inet_proto.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/inet_proto.c b/lib/inet_proto.c
index ceda082b12a2e..87ed4769fc3da 100644
--- a/lib/inet_proto.c
+++ b/lib/inet_proto.c
@@ -35,8 +35,10 @@ const char *inet_proto_n2a(int proto, char *buf, int len)
 	pe = getprotobynumber(proto);
 	if (pe) {
 		icache = proto;
-		strncpy(ncache, pe->p_name, 16);
-		strncpy(buf, pe->p_name, len);
+		strncpy(ncache, pe->p_name, 15);
+		ncache[15] = '\0';
+		strncpy(buf, pe->p_name, len - 1);
+		buf[len] = '\0';
 		return buf;
 	}
 	snprintf(buf, len, "ipproto-%d", proto);
@@ -62,7 +64,8 @@ int inet_proto_a2n(const char *buf)
 	pe = getprotobyname(buf);
 	if (pe) {
 		icache = pe->p_proto;
-		strncpy(ncache, pe->p_name, 16);
+		strncpy(ncache, pe->p_name, 15);
+		ncache[15] = '\0';
 		return pe->p_proto;
 	}
 	return -1;
-- 
2.13.1
