From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] l2tp: fix return value check
Date: Tue, 25 Sep 2012 12:29:01 +0800
Message-ID: <CAPgLHd_qnPZq34uP2dnZKtcXKtB4Da29wO12jHr5N44dKr=KKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:38775 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab2IYE3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 00:29:03 -0400
Received: by qadc26 with SMTP id c26so1471123qad.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 21:29:01 -0700 (PDT)
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
 net/l2tp/l2tp_netlink.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index d71cd92..6f93635 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -80,8 +80,8 @@ static int l2tp_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
 
 	hdr = genlmsg_put(msg, info->snd_pid, info->snd_seq,
 			  &l2tp_nl_family, 0, L2TP_CMD_NOOP);
-	if (IS_ERR(hdr)) {
-		ret = PTR_ERR(hdr);
+	if (!hdr) {
+		ret = -EMSGSIZE;
 		goto err_out;
 	}
 
@@ -250,8 +250,8 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 pid, u32 seq, int flags,
 
 	hdr = genlmsg_put(skb, pid, seq, &l2tp_nl_family, flags,
 			  L2TP_CMD_TUNNEL_GET);
-	if (IS_ERR(hdr))
-		return PTR_ERR(hdr);
+	if (!hdr)
+		return -EMSGSIZE;
 
 	if (nla_put_u8(skb, L2TP_ATTR_PROTO_VERSION, tunnel->version) ||
 	    nla_put_u32(skb, L2TP_ATTR_CONN_ID, tunnel->tunnel_id) ||
@@ -617,8 +617,8 @@ static int l2tp_nl_session_send(struct sk_buff *skb, u32 pid, u32 seq, int flags
 	sk = tunnel->sock;
 
 	hdr = genlmsg_put(skb, pid, seq, &l2tp_nl_family, flags, L2TP_CMD_SESSION_GET);
-	if (IS_ERR(hdr))
-		return PTR_ERR(hdr);
+	if (!hdr)
+		return -EMSGSIZE;
 
 	if (nla_put_u32(skb, L2TP_ATTR_CONN_ID, tunnel->tunnel_id) ||
 	    nla_put_u32(skb, L2TP_ATTR_SESSION_ID, session->session_id) ||
