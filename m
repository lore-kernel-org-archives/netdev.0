From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next] ipmroute: add support for age dumping
Date: Wed, 21 Sep 2016 11:45:58 +0200
Message-ID: <1474451158-15988-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, anuradhak@cumulusnetworks.com,
        stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38698 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753311AbcIUJqP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 05:46:15 -0400
Received: by mail-wm0-f42.google.com with SMTP id l132so81230739wmf.1
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 02:46:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to dump the mroute cache entry age if the show_stats (-s)
switch is provided.
Example:
$ ip -s mroute
(0.0.0.0, 239.10.10.10)          Iif: eth0       Oifs: eth0
  0 packets, 0 bytes, Age  245.44

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/ipmroute.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index 133367a2388d..512afcd2086e 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -169,6 +169,13 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			fprintf(fp, ", %"PRIu64" arrived on wrong iif.",
 				(uint64_t)mfcs->mfcs_wrong_if);
 	}
+	if (show_stats && tb[RTA_EXPIRES]) {
+		struct timeval tv;
+
+		__jiffies_to_tv(&tv, rta_getattr_u64(tb[RTA_EXPIRES]));
+		fprintf(fp, ", Age %4i.%.2i", (int)tv.tv_sec,
+			(int)tv.tv_usec/10000);
+	}
 	fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
-- 
2.1.4
