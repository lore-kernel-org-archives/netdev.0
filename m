From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2] ip/iproute: allow routes to be configured with expire values
Date: Mon, 21 Dec 2015 16:29:36 +0800
Message-ID: <1450686576-18808-1-git-send-email-liuhangbin@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	stephen@networkplumber.org, Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33201 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbbLUI3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 03:29:42 -0500
Received: by mail-pf0-f181.google.com with SMTP id n128so68393356pfn.0
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 00:29:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 include/linux/rtnetlink.h |  1 +
 ip/iproute.c              | 11 ++++++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 3244947..ff2fe31 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -310,6 +310,7 @@ enum rtattr_type_t {
 	RTA_PREF,
 	RTA_ENCAP_TYPE,
 	RTA_ENCAP,
+	RTA_EXPIRES,
 	__RTA_MAX
 };
 
diff --git a/ip/iproute.c b/ip/iproute.c
index eab512d..3f52e0f 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -84,7 +84,7 @@ static void usage(void)
 	fprintf(stderr, "           [ ssthresh NUMBER ] [ realms REALM ] [ src ADDRESS ]\n");
 	fprintf(stderr, "           [ rto_min TIME ] [ hoplimit NUMBER ] [ initrwnd NUMBER ]\n");
 	fprintf(stderr, "           [ features FEATURES ] [ quickack BOOL ] [ congctl NAME ]\n");
-	fprintf(stderr, "           [ pref PREF ]\n");
+	fprintf(stderr, "           [ pref PREF ] [ expires TIME ]\n");
 	fprintf(stderr, "TYPE := [ unicast | local | broadcast | multicast | throw |\n");
 	fprintf(stderr, "          unreachable | prohibit | blackhole | nat ]\n");
 	fprintf(stderr, "TABLE_ID := [ local | main | default | all | NUMBER ]\n");
@@ -811,6 +811,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 	int table_ok = 0;
 	int raw = 0;
 	int type_ok = 0;
+	static int hz;
 
 	memset(&req, 0, sizeof(req));
 
@@ -881,6 +882,14 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (rtnl_dsfield_a2n(&tos, *argv))
 				invarg("\"tos\" value is invalid\n", *argv);
 			req.r.rtm_tos = tos;
+		} else if (strcmp(*argv, "expires") == 0 ) {
+			__u32 expires;
+			NEXT_ARG();
+			if (get_u32(&expires, *argv, 0))
+				invarg("\"expires\" value is invalid\n", *argv);
+			if (!hz)
+				hz = get_user_hz();
+			addattr32(&req.n, sizeof(req), RTA_EXPIRES, expires*hz);
 		} else if (matches(*argv, "metric") == 0 ||
 			   matches(*argv, "priority") == 0 ||
 			   strcmp(*argv, "preference") == 0) {
-- 
2.4.3
