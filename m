From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] Makefile: really suppress printing of directories
Date: Wed,  7 Dec 2016 12:55:09 -0800
Message-ID: <1481144109-11116-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:35222 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933015AbcLGUzO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 15:55:14 -0500
Received: by mail-pg0-f53.google.com with SMTP id p66so165745197pga.2
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 12:55:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makefile adds --no-print-directory to MAKEFLAGS if VERBOSE is not
defined however Config always defines VERBOSE. Update the check to
whether VERBOSE is 0.

Fixes: 57bdf8b76451 ("Make builds default to quiet mode")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Makefile b/Makefile
index 37b68ad87f06..18de7dcb315b 100644
--- a/Makefile
+++ b/Makefile
@@ -3,7 +3,7 @@ ifneq ($(wildcard Config),)
 include Config
 endif
 
-ifndef VERBOSE
+ifeq ($(VERBOSE),0)
 MAKEFLAGS += --no-print-directory
 endif
 
-- 
2.1.4
