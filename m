From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH] text ematch: check for NULL pointer before destroying
 textsearch config
Date: Sun, 31 Oct 2010 04:06:35 -0400
Message-ID: <20101031080635.GA22639@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:54164 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252Ab0JaIGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 04:06:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While validating the configuration em_ops is already set, thus the
individual destroy functions are called, but the ematch data has
not been allocated and associated with the ematch yet.

Signed-off-by: Thomas Graf <tgraf@infradead.org>

Index: net-2.6/net/sched/em_text.c
===================================================================
--- net-2.6.orig/net/sched/em_text.c
+++ net-2.6/net/sched/em_text.c
@@ -103,7 +103,8 @@ retry:
 
 static void em_text_destroy(struct tcf_proto *tp, struct tcf_ematch *m)
 {
-	textsearch_destroy(EM_TEXT_PRIV(m)->config);
+	if (EM_TEXT_PRIV(m) && EM_TEXT_PRIV(m)->config)
+		textsearch_destroy(EM_TEXT_PRIV(m)->config);
 }
 
 static int em_text_dump(struct sk_buff *skb, struct tcf_ematch *m)
