From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 master 2/4] pedit: Do not allow using retain for too big fields
Date: Sun, 14 May 2017 11:17:44 +0300
Message-ID: <20170514081746.9010-3-amir@vadai.me>
References: <20170514081746.9010-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36427 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751402AbdENIRu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 04:17:50 -0400
Received: by mail-wm0-f66.google.com with SMTP id u65so21151422wmu.3
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 01:17:49 -0700 (PDT)
In-Reply-To: <20170514081746.9010-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using retain for fields longer than 32 bits is not supported.
Do not allow user to do it.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 man/man8/tc-pedit.8 | 3 ++-
 tc/m_pedit.c        | 6 ++++++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/man/man8/tc-pedit.8 b/man/man8/tc-pedit.8
index 7f482eafc6c7..9c4d57b972cc 100644
--- a/man/man8/tc-pedit.8
+++ b/man/man8/tc-pedit.8
@@ -266,7 +266,8 @@ Keep the addressed data as is.
 .BI retain " RVAL"
 This optional extra part of
 .I CMD_SPEC
-allows to exclude bits from being changed.
+allows to exclude bits from being changed. Supported only for 32 bits fields
+or smaller.
 .TP
 .I CONTROL
 The following keywords allow to control how the tree of qdisc, classes,
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 7ef2acc52bce..9b74c965932e 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -353,6 +353,12 @@ int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
 		argv++;
 	}
 
+	if (len > 4 && retain != ~0) {
+		fprintf(stderr,
+			"retain is not supported for fields longer the 32 bits\n");
+		return -1;
+	}
+
 	if (type == TMAC) {
 		res = pack_mac(sel, tkey, (__u8 *)val);
 		goto done;
-- 
2.12.2
