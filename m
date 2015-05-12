From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2] ip route: should show the hoplimit value what kernel returns
Date: Tue, 12 May 2015 13:32:47 +0800
Message-ID: <1431408767-15917-1-git-send-email-liuhangbin@gmail.com>
Cc: Ulrich Weber <uweber@astaro.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53695 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752521AbbELFdC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 01:33:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Kernel commit a02e4b7 set the default hoplimit as zero.
2. Kernel should return the correct values and iproute should show what kernel
returns, not invent magic transformations.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iproute.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 670a4c6..569bff9 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -579,9 +579,6 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				print_rtax_features(fp, val);
 				break;
 			case RTAX_HOPLIMIT:
-				if ((int)val == -1)
-					val = 0;
-				/* fall through */
 			default:
 				fprintf(fp, " %u", val);
 				break;
-- 
1.9.3
