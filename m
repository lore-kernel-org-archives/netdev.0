From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 38/51] tc/em_ipset: Don't leak sockfd on error path
Date: Sat, 12 Aug 2017 14:04:57 +0200
Message-ID: <20170812120510.28750-39-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55175 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752529AbdHLMG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:06:26 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/em_ipset.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tc/em_ipset.c b/tc/em_ipset.c
index fab975f5ea563..b59756515d239 100644
--- a/tc/em_ipset.c
+++ b/tc/em_ipset.c
@@ -84,6 +84,7 @@ static int get_version(unsigned int *version)
 	res = getsockopt(sockfd, SOL_IP, SO_IP_SET, &req_version, &size);
 	if (res != 0) {
 		perror("xt_set getsockopt");
+		close(sockfd);
 		return -1;
 	}
 
-- 
2.13.1
