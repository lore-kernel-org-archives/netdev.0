From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] taskstats: fix the length of cgroupstats_cmd_get_policy
Date: Thu,  3 Nov 2016 09:42:36 -0700
Message-ID: <1478191356-10386-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1478191356-10386-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32928 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756145AbcKCQmp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 12:42:45 -0400
Received: by mail-pf0-f195.google.com with SMTP id a136so5327960pfa.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 09:42:44 -0700 (PDT)
In-Reply-To: <1478191356-10386-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cgroupstats_cmd_get_policy is [CGROUPSTATS_CMD_ATTR_MAX+1],
taskstats_cmd_get_policy[TASKSTATS_CMD_ATTR_MAX+1],
but their family.maxattr is TASKSTATS_CMD_ATTR_MAX.
CGROUPSTATS_CMD_ATTR_MAX is less than TASKSTATS_CMD_ATTR_MAX,
so we could end up accessing out-of-bound.

Change cgroupstats_cmd_get_policy to TASKSTATS_CMD_ATTR_MAX+1,
this is safe because the rest are initialized to 0's.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 kernel/taskstats.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/kernel/taskstats.c b/kernel/taskstats.c
index b3f05ee..cbb387a 100644
--- a/kernel/taskstats.c
+++ b/kernel/taskstats.c
@@ -54,7 +54,11 @@ static const struct nla_policy taskstats_cmd_get_policy[TASKSTATS_CMD_ATTR_MAX+1
 	[TASKSTATS_CMD_ATTR_REGISTER_CPUMASK] = { .type = NLA_STRING },
 	[TASKSTATS_CMD_ATTR_DEREGISTER_CPUMASK] = { .type = NLA_STRING },};
 
-static const struct nla_policy cgroupstats_cmd_get_policy[CGROUPSTATS_CMD_ATTR_MAX+1] = {
+/*
+ * We have to use TASKSTATS_CMD_ATTR_MAX here, it is the maxattr in the family.
+ * Make sure they are always aligned.
+ */
+static const struct nla_policy cgroupstats_cmd_get_policy[TASKSTATS_CMD_ATTR_MAX+1] = {
 	[CGROUPSTATS_CMD_ATTR_FD] = { .type = NLA_U32 },
 };
 
-- 
2.1.0
