From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] bridge: add calls to fflush in fdb and mdb print functions
Date: Thu, 15 Oct 2015 14:53:17 -0700
Message-ID: <1444945997-55864-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, wkok@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34812 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbbJOVxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 17:53:22 -0400
Received: by payp3 with SMTP id p3so51130796pay.1
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 14:53:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wilson Kok <wkok@cumulusnetworks.com>

This patch adds fflush in fdb and mdb print functions

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/fdb.c | 2 ++
 bridge/mdb.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index bd7e4f9..5ea50ab 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -163,6 +163,8 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "offload ");
 
 	fprintf(fp, "%s\n", state_n2a(r->ndm_state));
+	fflush(fp);
+
 	return 0;
 }
 
diff --git a/bridge/mdb.c b/bridge/mdb.c
index b14bd01..24c4903 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -135,6 +135,8 @@ int print_mdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		}
 	}
 
+	fflush(fp);
+
 	return 0;
 }
 
-- 
1.9.1
