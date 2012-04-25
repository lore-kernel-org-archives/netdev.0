From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH 1/2] ss: fix the incorrect value of total UNIX_DIAG_* number
Date: Wed, 25 Apr 2012 15:15:16 +0800
Message-ID: <4F97A484.2040300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: xemul@parallels.com, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:33714 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab2DYHOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 03:14:30 -0400
Received: by dadz8 with SMTP id z8so1990313dad.10
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 00:14:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <davidshan@tencent.com>

UNIX_DIAG_MAX is included in enum type.
It is equal to the total number of enum element.

But lots of enum MAX value is defined as the max enum element, e.g. INET_DIAG_MAX, XFRMA_MAX. 
The right fixing way seems to define UNIX_DIAG_MAX as UNIX_DIAG_MEMINFO,
but this way will break other user application.

So, just fix it on user application.


Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 misc/ss.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 4017918..5f70a26 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2011,12 +2011,12 @@ void unix_list_print(struct unixstat *list, struct filter *f)
 static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
 {
 	struct unix_diag_msg *r = NLMSG_DATA(nlh);
-	struct rtattr *tb[UNIX_DIAG_MAX+1];
+	struct rtattr *tb[UNIX_DIAG_MAX];
 	char name[128];
 	int peer_ino;
 	int rqlen;
 
-	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
+	parse_rtattr(tb, UNIX_DIAG_MAX-1, (struct rtattr*)(r+1),
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	if (netid_width)
-- 
1.7.1
