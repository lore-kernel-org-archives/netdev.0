From: Alexander Aring <aring@mojatatu.com>
Subject: [PATCH iproute2 3/4] tc: m_ife: report about kernels default type
Date: Mon, 28 Aug 2017 15:07:37 -0400
Message-ID: <20170828190738.26829-4-aring@mojatatu.com>
References: <20170828190738.26829-1-aring@mojatatu.com>
Cc: yotamg@mellanox.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, Alexander Aring <aring@mojatatu.com>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33271 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751631AbdH1TIt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:08:49 -0400
Received: by mail-io0-f195.google.com with SMTP id s101so1107645ioe.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:08:49 -0700 (PDT)
In-Reply-To: <20170828190738.26829-1-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch will report about if the ethertype for IFE is not specified
that the default IFE type is used.

Signed-off-by: Alexander Aring <aring@mojatatu.com>
---
 tc/m_ife.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tc/m_ife.c b/tc/m_ife.c
index 7b57130e..5633ab90 100644
--- a/tc/m_ife.c
+++ b/tc/m_ife.c
@@ -189,6 +189,8 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
 		addattr_l(n, MAX_MSG, TCA_IFE_DMAC, dbuf, ETH_ALEN);
 	if (user_type)
 		addattr_l(n, MAX_MSG, TCA_IFE_TYPE, &ife_type, 2);
+	else
+		fprintf(stderr, "IFE type 0x%04X\n", ETH_P_IFE);
 	if (saddr)
 		addattr_l(n, MAX_MSG, TCA_IFE_SMAC, sbuf, ETH_ALEN);
 
-- 
2.11.0
