From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 2/5] fou: exit early when parsing config fails
Date: Mon,  6 Apr 2015 16:41:27 -0700
Message-ID: <1428363690-16288-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1428363690-16288-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33008 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026AbbDFXln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 19:41:43 -0400
Received: by paboj16 with SMTP id oj16so59123791pab.0
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 16:41:43 -0700 (PDT)
In-Reply-To: <1428363690-16288-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Tom Herbert <therbert@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/fou.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index c8db627..ad0ee82 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -605,8 +605,11 @@ static int fou_nl_cmd_add_port(struct sk_buff *skb, struct genl_info *info)
 static int fou_nl_cmd_rm_port(struct sk_buff *skb, struct genl_info *info)
 {
 	struct fou_cfg cfg;
+	int err;
 
-	parse_nl_config(info, &cfg);
+	err = parse_nl_config(info, &cfg);
+	if (err)
+		return err;
 
 	return fou_destroy(&init_net, &cfg);
 }
-- 
1.8.3.1
