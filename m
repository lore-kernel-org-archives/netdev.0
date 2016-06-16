From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/2] iplink: Add missing variable initialization
Date: Thu, 16 Jun 2016 16:19:39 +0200
Message-ID: <1466086780-5613-2-git-send-email-phil@nwl.cc>
References: <1466086780-5613-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49234 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754558AbcFPOUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 10:20:06 -0400
In-Reply-To: <1466086780-5613-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this, we might feed garbage to the kernel when the address is
shorter than expected.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index d2e586b6d1332..4cb9bab66b916 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -273,7 +273,7 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 	while (NEXT_ARG_OK()) {
 		NEXT_ARG();
 		if (matches(*argv, "mac") == 0) {
-			struct ifla_vf_mac ivm;
+			struct ifla_vf_mac ivm = { 0 };
 
 			NEXT_ARG();
 			ivm.vf = vf;
-- 
2.8.2
