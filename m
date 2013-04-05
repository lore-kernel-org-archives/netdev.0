From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH] TTY: ircomm, use GFP_KERNEL in ircomm_open()
Date: Fri,  5 Apr 2013 23:02:07 +0200
Message-ID: <1365195727-24780-1-git-send-email-minipli@googlemail.com>
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mathias Krause <minipli@googlemail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:41617 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162097Ab3DEVCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 17:02:39 -0400
Received: by mail-bk0-f51.google.com with SMTP id y8so2306324bkt.38
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 14:02:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Greg,

I'm unsure if you or Dave should take that one as it's for one a TTY
patch but also living under net/. So I'm uncertain and let you decide!

Thanks,
Mathias

-- >8 --
Subject: [PATCH] TTY: ircomm, use GFP_KERNEL in ircomm_open()

We're clearly running in non-atomic context as our only call site is
able to call wait_event_interruptible(). So we're safe to use GFP_KERNEL
here instead of GFP_ATOMIC.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/irda/ircomm/ircomm_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/irda/ircomm/ircomm_core.c b/net/irda/ircomm/ircomm_core.c
index 52079f1..b797daa 100644
--- a/net/irda/ircomm/ircomm_core.c
+++ b/net/irda/ircomm/ircomm_core.c
@@ -117,7 +117,7 @@ struct ircomm_cb *ircomm_open(notify_t *notify, __u8 service_type, int line)
 
 	IRDA_ASSERT(ircomm != NULL, return NULL;);
 
-	self = kzalloc(sizeof(struct ircomm_cb), GFP_ATOMIC);
+	self = kzalloc(sizeof(struct ircomm_cb), GFP_KERNEL);
 	if (self == NULL)
 		return NULL;
 
-- 
1.7.10.4
