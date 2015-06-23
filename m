From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next 3/3 v7] iproute2: add support to print 'linkdown' nexthop flag
Date: Tue, 23 Jun 2015 13:45:38 -0400
Message-ID: <1435081538-1620-4-git-send-email-gospo@cumulusnetworks.com>
References: <1435081538-1620-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:35684 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754857AbbFWRq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 13:46:57 -0400
Received: by qgeu36 with SMTP id u36so5777024qge.2
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 10:46:57 -0700 (PDT)
In-Reply-To: <1435081538-1620-1-git-send-email-gospo@cumulusnetworks.com>
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
