From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ip-route: Pretty-print expired routes
Date: Wed, 10 Aug 2016 13:14:50 +0200
Message-ID: <1470827690-5625-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46206 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932629AbcHJSYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 14:24:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of printing 'expires -23sec' for expired (but not yet garbage
collected) routes, print 'expired 23sec' instead.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iproute.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index c52294d298210..a89a26d68be0f 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -305,6 +305,14 @@ static void print_rtax_features(FILE *fp, unsigned int features)
 		fprintf(fp, " 0x%x", of);
 }
 
+static void print_expires(FILE *fp, __s32 expires, int hz)
+{
+	if (expires > 0)
+		fprintf(fp, " expires %dsec", expires/hz);
+	else
+		fprintf(fp, " expired %dsec", -expires/hz);
+}
+
 int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE *)arg;
@@ -502,7 +510,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			if (!hz)
 				hz = get_user_hz();
 			if (ci->rta_expires != 0)
-				fprintf(fp, " expires %dsec", ci->rta_expires/hz);
+				print_expires(fp, ci->rta_expires, hz);
 			if (ci->rta_error != 0)
 				fprintf(fp, " error %d", ci->rta_error);
 			if (show_stats) {
@@ -530,7 +538,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			if (r->rtm_flags & RTM_F_CLONED)
 				fprintf(fp, "%s    cache ", _SL_);
 			if (ci->rta_expires)
-				fprintf(fp, " expires %dsec", ci->rta_expires/hz);
+				print_expires(fp, ci->rta_expires, hz);
 			if (ci->rta_error != 0)
 				fprintf(fp, " error %d", ci->rta_error);
 			if (show_stats) {
-- 
2.8.2
