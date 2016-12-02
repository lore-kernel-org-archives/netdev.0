From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 11/18] ss: Make some variables function-local
Date: Fri,  2 Dec 2016 11:39:55 +0100
Message-ID: <20161202104002.17310-12-phil@nwl.cc>
References: <20161202104002.17310-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52208 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933964AbcLBKlR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 05:41:17 -0500
In-Reply-To: <20161202104002.17310-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addrp_width and screen_width are used in main() only, so no need to have
them globally available.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 44386c82c7578..3662f5f4861c7 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -105,10 +105,8 @@ int sctp_ino;
 
 int netid_width;
 int state_width;
-int addrp_width;
 int addr_width;
 int serv_width;
-int screen_width;
 
 static const char *TCP_PROTO = "tcp";
 static const char *SCTP_PROTO = "sctp";
@@ -3975,6 +3973,7 @@ int main(int argc, char *argv[])
 	FILE *filter_fp = NULL;
 	int ch;
 	int state_filter = 0;
+	int addrp_width, screen_width = 80;
 
 	while ((ch = getopt_long(argc, argv,
 				 "dhaletuwxnro460spbEf:miA:D:F:vVzZN:KHS",
@@ -4264,7 +4263,6 @@ int main(int argc, char *argv[])
 	if (current_filter.states&(current_filter.states-1))
 		state_width = 10;
 
-	screen_width = 80;
 	if (isatty(STDOUT_FILENO)) {
 		struct winsize w;
 
-- 
2.10.0
