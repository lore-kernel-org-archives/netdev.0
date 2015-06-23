From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next 3/3 v6] iproute2: add support to print 'linkdown' nexthop flag
Date: Tue, 23 Jun 2015 11:51:51 -0400
Message-ID: <1435074711-924-4-git-send-email-gospo@cumulusnetworks.com>
References: <1435074711-924-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:34228 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933254AbbFWPw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 11:52:56 -0400
Received: by ykfy125 with SMTP id y125so7847703ykf.1
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 08:52:56 -0700 (PDT)
In-Reply-To: <1435074711-924-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Gospodaerk <gospo@cumulusnetworks.com>
Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
Acked-by: Scott Feldman <sfeldma@gmail.com>

---
 ip/iproute.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ip/iproute.c b/ip/iproute.c
index 3795baf..3369c49 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -451,6 +451,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "offload ");
 	if (r->rtm_flags & RTM_F_NOTIFY)
 		fprintf(fp, "notify ");
+	if (r->rtm_flags & RTNH_F_LINKDOWN)
+		fprintf(fp, "linkdown ");
 	if (tb[RTA_MARK]) {
 		unsigned int mark = *(unsigned int*)RTA_DATA(tb[RTA_MARK]);
 		if (mark) {
@@ -670,6 +672,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				fprintf(fp, " onlink");
 			if (nh->rtnh_flags & RTNH_F_PERVASIVE)
 				fprintf(fp, " pervasive");
+			if (nh->rtnh_flags & RTNH_F_LINKDOWN)
+				fprintf(fp, " linkdown");
 			len -= NLMSG_ALIGN(nh->rtnh_len);
 			nh = RTNH_NEXT(nh);
 		}
-- 
1.9.3
