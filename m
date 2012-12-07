From: Jan Synacek <jsynacek@redhat.com>
Subject: [PATCH 2/2] ping6: Fix -F switch.
Date: Fri,  7 Dec 2012 09:25:24 +0100
Message-ID: <1354868724-15549-3-git-send-email-jsynacek@redhat.com>
References: <1354868724-15549-1-git-send-email-jsynacek@redhat.com>
Cc: netdev@vger.kernel.org, Jan Synacek <jsynacek@redhat.com>
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926Ab2LGIZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 03:25:47 -0500
In-Reply-To: <1354868724-15549-1-git-send-email-jsynacek@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even when the flowlabel is set correctly, ping6 exits with a warning. For some
reason, the errno is set when it should not be.

Signed-off-by: Jan Synacek <jsynacek@redhat.com>
---
 ping6.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ping6.c b/ping6.c
index 358a035..85d3782 100644
--- a/ping6.c
+++ b/ping6.c
@@ -725,7 +725,8 @@ int main(int argc, char *argv[])
 		switch(ch) {
 		case 'F':
 			flowlabel = hextoui(optarg);
-			if (errno || (flowlabel & ~IPV6_FLOWINFO_FLOWLABEL)) {
+			if ((flowlabel < 0 && errno) ||
+			    (flowlabel & ~IPV6_FLOWINFO_FLOWLABEL)) {
 				fprintf(stderr, "ping: Invalid flowinfo %s\n", optarg);
 				exit(2);
 			}
-- 
1.8.0.1
