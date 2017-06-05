From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2] bridge: Distinguish between externally learned vs offloaded FDBs
Date: Mon,  5 Jun 2017 12:07:05 +0200
Message-ID: <20170605100705.3909-1-jiri@resnulli.us>
References: <20170605092043.3523-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34658 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbdFEKHI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 06:07:08 -0400
Received: by mail-wm0-f67.google.com with SMTP id 70so4471015wme.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 03:07:07 -0700 (PDT)
In-Reply-To: <20170605092043.3523-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Distinguish between externally learned vs offloaded FDBs. This is done
in order to indicate that FDBs added by software was successfully
offloaded.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 bridge/fdb.c              | 6 ++++++
 include/linux/neighbour.h | 1 +
 2 files changed, 7 insertions(+)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index a71a78f..e5cebf9 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -262,6 +262,10 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		}
 		if (r->ndm_flags & NTF_EXT_LEARNED) {
 			start_json_fdb_flags_array(&fdb_flags);
+			jsonw_string(jw_global, "extern_learn");
+		}
+		if (r->ndm_flags & NTF_OFFLOADED) {
+			start_json_fdb_flags_array(&fdb_flags);
 			jsonw_string(jw_global, "offload");
 		}
 		if (r->ndm_flags & NTF_MASTER)
@@ -280,6 +284,8 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		if (r->ndm_flags & NTF_ROUTER)
 			fprintf(fp, "router ");
 		if (r->ndm_flags & NTF_EXT_LEARNED)
+			fprintf(fp, "extern_learn ");
+		if (r->ndm_flags & NTF_OFFLOADED)
 			fprintf(fp, "offload ");
 		if (tb[NDA_MASTER]) {
 			fprintf(fp, "master %s ",
diff --git a/include/linux/neighbour.h b/include/linux/neighbour.h
index f3d16db..3199d28 100644
--- a/include/linux/neighbour.h
+++ b/include/linux/neighbour.h
@@ -41,6 +41,7 @@ enum {
 #define NTF_MASTER	0x04
 #define NTF_PROXY	0x08	/* == ATF_PUBL */
 #define NTF_EXT_LEARNED	0x10
+#define NTF_OFFLOADED   0x20
 #define NTF_ROUTER	0x80
 
 /*
-- 
2.9.3
