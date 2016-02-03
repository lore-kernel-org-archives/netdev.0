From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] ipmonitor: match user option 'all' before 'all-nsid'
Date: Tue,  2 Feb 2016 16:53:40 -0800
Message-ID: <1454460820-21851-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35298 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbcBCAxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 19:53:44 -0500
Received: by mail-pa0-f51.google.com with SMTP id ho8so3290276pac.2
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 16:53:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

'ip monitor all' is broken on older kernels.
This patch fixes 'ip monitor all' to match
'all' and not 'all-nsid'.

It moves parsing arg 'all-nsid' to after parsing
'all'.

Before:
$ip monitor all
NETLINK_LISTEN_ALL_NSID: Protocol not available

After:
$ip monitor all
[NEIGH]Deleted 10.0.0.1 dev eth1 lladdr c4:54:44:4f:b2:dd STALE

Fixes: 449b824ad196 ("ipmonitor: allows to monitor in several netns")
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 ip/ipmonitor.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 99a237f..7aeccd2 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -186,8 +186,6 @@ int do_ipmonitor(int argc, char **argv)
 			file = *argv;
 		} else if (matches(*argv, "label") == 0) {
 			prefix_banner = 1;
-		} else if (matches(*argv, "all-nsid") == 0) {
-			listen_all_nsid = 1;
 		} else if (matches(*argv, "link") == 0) {
 			llink=1;
 			groups = 0;
@@ -217,6 +215,8 @@ int do_ipmonitor(int argc, char **argv)
 			groups = 0;
 		} else if (strcmp(*argv, "all") == 0) {
 			prefix_banner=1;
+		} else if (matches(*argv, "all-nsid") == 0) {
+			listen_all_nsid = 1;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else if (strcmp(*argv, "dev") == 0) {
-- 
1.9.1
