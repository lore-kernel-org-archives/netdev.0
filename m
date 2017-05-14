From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 master 3/4] pedit: Check for extended capability in protocol parser
Date: Sun, 14 May 2017 11:17:45 +0300
Message-ID: <20170514081746.9010-4-amir@vadai.me>
References: <20170514081746.9010-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36638 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751403AbdENIRw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 04:17:52 -0400
Received: by mail-wr0-f196.google.com with SMTP id v42so11188954wrc.3
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 01:17:51 -0700 (PDT)
In-Reply-To: <20170514081746.9010-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not allow using eth and udp header types if non-extended pedit kABI
is being used. Other protocol parsers already have this check.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 tc/p_eth.c | 3 +++
 tc/p_udp.c | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/tc/p_eth.c b/tc/p_eth.c
index ad3e28f80eb6..2d2f96ca2f0f 100644
--- a/tc/p_eth.c
+++ b/tc/p_eth.c
@@ -34,6 +34,9 @@ parse_eth(int *argc_p, char ***argv_p,
 	if (argc < 2)
 		return -1;
 
+	if (!sel->extended)
+		return -1;
+
 	tkey->htype = TCA_PEDIT_KEY_EX_HDR_TYPE_ETH;
 
 	if (strcmp(*argv, "type") == 0) {
diff --git a/tc/p_udp.c b/tc/p_udp.c
index a56a1b519254..3916d9586040 100644
--- a/tc/p_udp.c
+++ b/tc/p_udp.c
@@ -34,6 +34,9 @@ parse_udp(int *argc_p, char ***argv_p,
 	if (argc < 2)
 		return -1;
 
+	if (!sel->extended)
+		return -1;
+
 	tkey->htype = TCA_PEDIT_KEY_EX_HDR_TYPE_UDP;
 
 	if (strcmp(*argv, "sport") == 0) {
-- 
2.12.2
