From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] qdisc: meta return ENOMEM on alloc failure
Date: Thu, 26 Sep 2013 17:40:11 -0700
Message-ID: <20130926174011.22632779@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:57915 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091Ab3I0AkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 20:40:15 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so1842927pbb.33
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 17:40:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than returning earlier value (EINVAL), return ENOMEM if
kzalloc fails. Found while reviewing to find another EINVAL condition.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/sched/em_meta.c	2013-08-10 10:36:11.657498301 -0700
+++ b/net/sched/em_meta.c	2013-09-05 16:47:43.915846185 -0700
@@ -793,8 +793,10 @@ static int em_meta_change(struct tcf_pro
 		goto errout;
 
 	meta = kzalloc(sizeof(*meta), GFP_KERNEL);
-	if (meta == NULL)
+	if (meta == NULL) {
+		err = -ENOMEM;
 		goto errout;
+	}
 
 	memcpy(&meta->lvalue.hdr, &hdr->left, sizeof(hdr->left));
 	memcpy(&meta->rvalue.hdr, &hdr->right, sizeof(hdr->right));
