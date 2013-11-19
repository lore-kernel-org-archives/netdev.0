From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [patch iproute2] ipaddrlabel: use uint32_t instead of int32_t
Date: Tue, 19 Nov 2013 23:46:20 +0800
Message-ID: <1384875980-21835-1-git-send-email-liuhangbin@gmail.com>
Cc: Hangbin Liu <liuhangbin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:45729 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431Ab3KSPqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 10:46:37 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so5299144pad.26
        for <netdev@vger.kernel.org>; Tue, 19 Nov 2013 07:46:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As both linux kernel and function ipaddrlabel_modify use unsigned int for
label. We should also use unsigned int value when print addrlabel in case of
misunderstanding.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/ipaddrlabel.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index 1789d9c..68a94dd 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -86,10 +86,10 @@ int print_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg
 	if (ifal->ifal_index)
 		fprintf(fp, "dev %s ", ll_index_to_name(ifal->ifal_index));
 
-	if (tb[IFAL_LABEL] && RTA_PAYLOAD(tb[IFAL_LABEL]) == sizeof(int32_t)) {
-		int32_t label;
+	if (tb[IFAL_LABEL] && RTA_PAYLOAD(tb[IFAL_LABEL]) == sizeof(uint32_t)) {
+		uint32_t label;
 		memcpy(&label, RTA_DATA(tb[IFAL_LABEL]), sizeof(label));
-		fprintf(fp, "label %d ", label);
+		fprintf(fp, "label %u ", label);
 	}
 
 	fprintf(fp, "\n");
-- 
1.8.1.4
