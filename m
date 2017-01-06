From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 1/3] ip vrf: Fix run-on error message on mkdir failure
Date: Thu,  5 Jan 2017 16:22:21 -0800
Message-ID: <1483662143-15242-2-git-send-email-dsa@cumulusnetworks.com>
References: <1483662143-15242-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36746 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751688AbdAFA2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 19:28:40 -0500
Received: by mail-pg0-f45.google.com with SMTP id f188so245604192pgc.3
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 16:28:40 -0800 (PST)
In-Reply-To: <1483662143-15242-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy reported a missing newline if a non-root user attempts to run
'ip vrf exec':

$ ./ip/ip vrf exec default /bin/echo asdf
mkdir failed for /var/run/cgroup2: Permission deniedFailed to setup vrf cgroup2 directory

Reported-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 lib/fs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/fs.c b/lib/fs.c
index 39cc96dccca9..644bb486ae8e 100644
--- a/lib/fs.c
+++ b/lib/fs.c
@@ -121,7 +121,7 @@ int make_path(const char *path, mode_t mode)
 
 			if (mkdir(dir, mode) != 0) {
 				fprintf(stderr,
-					"mkdir failed for %s: %s",
+					"mkdir failed for %s: %s\n",
 					dir, strerror(errno));
 				goto out;
 			}
-- 
2.1.4
