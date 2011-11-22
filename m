From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] atm: use SKB_TRUESIZE() in atm_guess_pdu2truesize()
Date: Tue, 22 Nov 2011 06:51:34 +0100
Message-ID: <1321941094.27077.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43363 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913Ab1KVFvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 00:51:38 -0500
Received: by wwe5 with SMTP id 5so11851597wwe.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 21:51:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SKB_TRUESIZE() provides a better approximation of expected skb truesize.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/atmdev.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 49a83ca..43ea1b2 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -452,7 +452,7 @@ void atm_dev_release_vccs(struct atm_dev *dev);
 
 static inline int atm_guess_pdu2truesize(int size)
 {
-	return SKB_DATA_ALIGN(size) + sizeof(struct skb_shared_info);
+	return SKB_TRUESIZE(size);
 }
 
 
