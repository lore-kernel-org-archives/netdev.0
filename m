From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH iproute2 1/4] tc: m_ife: allow ife type to zero
Date: Mon, 28 Aug 2017 15:07:35 -0400
Message-ID: <20170828190738.26829-2-aring@mojatatu.com>
References: <20170828190738.26829-1-aring@mojatatu.com>
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36221 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751488AbdH1TIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:08:46 -0400
Received: by mail-io0-f193.google.com with SMTP id v96so1096913ioi.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:08:46 -0700 (PDT)
In-Reply-To: <20170828190738.26829-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to set an ethertype for IFE which is zero. There is no
kernel side validation which forbids a type to zero.

Signed-off-by: Alexander Aring <aring@mojatatu.com>
---
 tc/m_ife.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/tc/m_ife.c b/tc/m_ife.c
index e3521e62..e05e2276 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -63,6 +63,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 	char dbuf[ETH_ALEN];
 	char sbuf[ETH_ALEN];
 	__u16 ife_type = 0;
+	int user_type = 0;
 	__u32 ife_prio = 0;
 	__u32 ife_prio_v = 0;
 	__u32 ife_mark = 0;
@@ -125,6 +126,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 			if (get_u16(&ife_type, *argv, 0))
 				invarg("ife type is invalid", *argv);
 			fprintf(stderr, "IFE type 0x%x\n", ife_type);
+			user_type = 1;
 		} else if (matches(*argv, "dst") == 0) {
 			NEXT_ARG();
 			daddr = *argv;
@@ -185,7 +187,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 
 	if (daddr)
 		addattr_l(n, MAX_MSG, TCA_IFE_DMAC, dbuf, ETH_ALEN);
-	if (ife_type)
+	if (user_type)
 		addattr_l(n, MAX_MSG, TCA_IFE_TYPE, &ife_type, 2);
 	if (saddr)
 		addattr_l(n, MAX_MSG, TCA_IFE_SMAC, sbuf, ETH_ALEN);
-- 
2.11.0
