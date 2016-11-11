From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 11/18] ss: Make some variables function-local
Date: Fri, 11 Nov 2016 14:10:07 +0100
Message-ID: <20161111131014.21865-12-phil@nwl.cc>
References: <20161111131014.21865-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35763 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756458AbcKKNLl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:11:41 -0500
In-Reply-To: <20161111131014.21865-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addrp_width and screen_width are used in main() only, so no need to have
them globally available.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 3e5c93bb7c6f9..d546a00eb2c24 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -103,10 +103,8 @@ int follow_events;
 
 int netid_width;
 int state_width;
-int addrp_width;
 int addr_width;
 int serv_width;
-int screen_width;
 
 static const char *TCP_PROTO = "tcp";
 static const char *UDP_PROTO = "udp";
@@ -3784,6 +3782,7 @@ int main(int argc, char *argv[])
 	FILE *filter_fp = NULL;
 	int ch;
 	int state_filter = 0;
+	int addrp_width, screen_width = 80;
 
 	while ((ch = getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:F:vVzZN:KH",
 				 long_opts, NULL)) != EOF) {
@@ -4067,7 +4066,6 @@ int main(int argc, char *argv[])
 	if (current_filter.states&(current_filter.states-1))
 		state_width = 10;
 
-	screen_width = 80;
 	if (isatty(STDOUT_FILENO)) {
 		struct winsize w;
 
-- 
2.10.0
