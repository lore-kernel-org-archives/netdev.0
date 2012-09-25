From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] team: fix return value check
Date: Tue, 25 Sep 2012 12:29:35 +0800
Message-ID: <CAPgLHd9GYYu21FhiKAr2MvmYtWbL=85-E0EzJmiJm6cDDp=WcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:42116 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024Ab2IYE3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 00:29:35 -0400
Received: by qcro28 with SMTP id o28so4947577qcr.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 21:29:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the function genlmsg_put() returns NULL pointer
not ERR_PTR(). The IS_ERR() test in the return value check should
be replaced with NULL test.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/team/team.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 341b65d..e19da26 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1652,8 +1652,8 @@ static int team_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
 
 	hdr = genlmsg_put(msg, info->snd_pid, info->snd_seq,
 			  &team_nl_family, 0, TEAM_CMD_NOOP);
-	if (IS_ERR(hdr)) {
-		err = PTR_ERR(hdr);
+	if (!hdr) {
+		err = -EMSGSIZE;
 		goto err_msg_put;
 	}
 
@@ -1847,8 +1847,8 @@ start_again:
 
 	hdr = genlmsg_put(skb, pid, seq, &team_nl_family, flags | NLM_F_MULTI,
 			  TEAM_CMD_OPTIONS_GET);
-	if (IS_ERR(hdr))
-		return PTR_ERR(hdr);
+	if (!hdr)
+		return -EMSGSIZE;
 
 	if (nla_put_u32(skb, TEAM_ATTR_TEAM_IFINDEX, team->dev->ifindex))
 		goto nla_put_failure;
@@ -2067,8 +2067,8 @@ static int team_nl_fill_port_list_get(struct sk_buff *skb,
 
 	hdr = genlmsg_put(skb, pid, seq, &team_nl_family, flags,
 			  TEAM_CMD_PORT_LIST_GET);
-	if (IS_ERR(hdr))
-		return PTR_ERR(hdr);
+	if (!hdr)
+		return -EMSGSIZE;
 
 	if (nla_put_u32(skb, TEAM_ATTR_TEAM_IFINDEX, team->dev->ifindex))
 		goto nla_put_failure;
