From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net-next] net: ptp: mark filter as __initdata
Date: Sat, 10 May 2014 22:23:28 +0200
Message-ID: <1399753408-14861-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:55465 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038AbaEJUXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 16:23:45 -0400
Received: by mail-ee0-f41.google.com with SMTP id t10so3561519eei.14
        for <netdev@vger.kernel.org>; Sat, 10 May 2014 13:23:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_unattached_filter_create() will copy the filter's instructions so we
don't need to have the master copy hanging around after initialization.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/core/ptp_classifier.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/ptp_classifier.c b/net/core/ptp_classifier.c
index eaba0f68f8..37d86157b7 100644
--- a/net/core/ptp_classifier.c
+++ b/net/core/ptp_classifier.c
@@ -88,7 +88,7 @@ EXPORT_SYMBOL_GPL(ptp_classify_raw);
 
 void __init ptp_classifier_init(void)
 {
-	static struct sock_filter ptp_filter[] = {
+	static struct sock_filter ptp_filter[] __initdata = {
 		{ 0x28,  0,  0, 0x0000000c },
 		{ 0x15,  0, 12, 0x00000800 },
 		{ 0x30,  0,  0, 0x00000017 },
-- 
1.7.10.4
