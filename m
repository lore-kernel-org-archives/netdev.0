From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 02/27] ip: add new command line argument -json (mutually exclusive with -color)
Date: Thu,  3 Aug 2017 17:54:50 +0200
Message-ID: <20170803155515.99226-3-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38474 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751133AbdHCPzh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:55:37 -0400
Received: by mail-wm0-f48.google.com with SMTP id m85so19183290wma.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:55:36 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 include/utils.h | 1 +
 ip/ip.c         | 6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/include/utils.h b/include/utils.h
index 6080b962..565bda60 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -20,6 +20,7 @@ extern int show_raw;
 extern int resolve_hosts;
 extern int oneline;
 extern int brief;
+extern int json;
 extern int timestamp;
 extern int timestamp_short;
 extern const char * _SL_;
diff --git a/ip/ip.c b/ip/ip.c
index 7c14a8ec..23399e37 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -33,6 +33,7 @@ int show_details;
 int resolve_hosts;
 int oneline;
 int brief;
+int json;
 int timestamp;
 const char *_SL_;
 int force;
@@ -258,6 +259,8 @@ int main(int argc, char **argv)
 			batch_file = argv[1];
 		} else if (matches(opt, "-brief") == 0) {
 			++brief;
+		} else if (matches(opt, "-json") == 0) {
+			++json;
 		} else if (matches(opt, "-rcvbuf") == 0) {
 			unsigned int size;
 
@@ -292,6 +295,9 @@ int main(int argc, char **argv)
 
 	_SL_ = oneline ? "\\" : "\n";
 
+	if (json)
+		disable_color();
+
 	if (batch_file)
 		return batch(batch_file);
 
-- 
2.13.3
