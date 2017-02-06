From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] ipv6: sr: fix non static symbol warnings
Date: Mon,  6 Feb 2017 16:15:05 +0000
Message-ID: <20170206161505.10457-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36207 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751372AbdBFQPN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 11:15:13 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so9457126pgf.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 08:15:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warnings:

net/ipv6/seg6_iptunnel.c:58:5: warning:
 symbol 'nla_put_srh' was not declared. Should it be static?
net/ipv6/seg6_iptunnel.c:238:5: warning:
 symbol 'seg6_input' was not declared. Should it be static?
net/ipv6/seg6_iptunnel.c:254:5: warning:
 symbol 'seg6_output' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/ipv6/seg6_iptunnel.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 6124e15..8558225 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -55,8 +55,8 @@ static const struct nla_policy seg6_iptunnel_policy[SEG6_IPTUNNEL_MAX + 1] = {
 	[SEG6_IPTUNNEL_SRH]	= { .type = NLA_BINARY },
 };
 
-int nla_put_srh(struct sk_buff *skb, int attrtype,
-		struct seg6_iptunnel_encap *tuninfo)
+static int nla_put_srh(struct sk_buff *skb, int attrtype,
+		       struct seg6_iptunnel_encap *tuninfo)
 {
 	struct seg6_iptunnel_encap *data;
 	struct nlattr *nla;
@@ -235,7 +235,7 @@ static int seg6_do_srh(struct sk_buff *skb)
 	return 0;
 }
 
-int seg6_input(struct sk_buff *skb)
+static int seg6_input(struct sk_buff *skb)
 {
 	int err;
 
@@ -251,7 +251,7 @@ int seg6_input(struct sk_buff *skb)
 	return dst_input(skb);
 }
 
-int seg6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
+static int seg6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *orig_dst = skb_dst(skb);
 	struct dst_entry *dst = NULL;
