From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 2/2] tc/em_ipset: Don't leak sockfd on error path
Date: Thu, 17 Aug 2017 19:09:31 +0200
Message-ID: <20170817170931.24224-3-phil@nwl.cc>
References: <20170817170931.24224-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:40069 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753346AbdHQRKV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:10:21 -0400
In-Reply-To: <20170817170931.24224-1-phil@nwl.cc>
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
