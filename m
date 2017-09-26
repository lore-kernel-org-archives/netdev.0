From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] ip: initialize FILE pointer in ip-monitor
Date: Tue, 26 Sep 2017 15:13:56 -0400
Message-ID: <1506453236-7034-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:50158 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751450AbdIZTOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 15:14:05 -0400
Received: by mail-it0-f65.google.com with SMTP id c195so4392469itb.4
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 12:14:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since FILE *_fp was not explicitly initialized, all the consequent print_*()
calls were failing.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 ip/ipmonitor.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 3171d47..f4d502a 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -284,6 +284,9 @@ int do_ipmonitor(int argc, char **argv)
 	if (lnsid) {
 		groups |= nl_mgrp(RTNLGRP_NSID);
 	}
+
+	new_json_obj(json, stdout);
+
 	if (file) {
 		FILE *fp;
 		int err;
-- 
1.9.1
