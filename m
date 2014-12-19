From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH Iproute2 next] ip netns: 'ip netns id' cmd without argument should not give error
Date: Thu, 18 Dec 2014 22:05:38 -0800
Message-ID: <1418969138-26199-1-git-send-email-maheshb@google.com>
Cc: Vadim Kochan <vadim4j@gmail.com>, Saied Kazemi <saied@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:34033 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbaLSGFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 01:05:49 -0500
Received: by mail-vc0-f201.google.com with SMTP id hq11so7243vcb.4
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 22:05:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The command 'ip netns identify' without PID parameter is supposed to
use the self PID to identify its ns but a trivial error prevented it
from doing so. This patch fixes that error.

So before the patch -
	# ip netns id
	No pid specified
	# echo $?
	1
	#

After the patch -
	# ip netns id
	test-ns
	# echo $?
	0
	#

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Vadim Kochan <vadim4j@gmail.com> 
Cc: Saied Kazemi <saied@google.com>
---
 ip/ipnetns.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 1c8aa029073e..ec9afa2177a5 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -298,7 +298,7 @@ static int netns_identify(int argc, char **argv)
 	DIR *dir;
 	struct dirent *entry;
 
-	if (argc < 1) {
+	if (!argc) {
 		pidstr = "self";
 	} else if (argc > 1) {
 		fprintf(stderr, "extra arguments specified\n");
-- 
2.2.0.rc0.207.ga3a616c
