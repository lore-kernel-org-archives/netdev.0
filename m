From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH iproute2 3/3 v2] add support to print 'linkdown' nexthop flag
Date: Wed, 10 Jun 2015 02:47:21 -0400
Message-ID: <1433918841-15576-4-git-send-email-gospo@cumulusnetworks.com>
References: <1433918841-15576-1-git-send-email-gospo@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:32819 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933288AbbFJGsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 02:48:50 -0400
Received: by oiha141 with SMTP id a141so26256417oih.0
        for <netdev@vger.kernel.org>; Tue, 09 Jun 2015 23:48:49 -0700 (PDT)
In-Reply-To: <1433918841-15576-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Gospodaerk <gospo@cumulusnetworks.com>
Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>

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
