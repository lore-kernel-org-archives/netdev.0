From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH] skb: add a comment to skb_csum_unnecessary to avoid miuse
Date: Wed, 23 Jan 2013 09:30:16 +0900
Message-ID: <50FF2F18.1050408@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:56923 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263Ab3AWAaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 19:30:19 -0500
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 582073EE0AE
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 09:30:17 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 387EA45DE55
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 09:30:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CCDB45DE4F
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 09:30:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 066EDE38001
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 09:30:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD20D1DB8037
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 09:30:16 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to its name and appearance, someone thinks this only checks if ip_summed is
CHECKSUM_UNNECESARRY.  But actually, this returns true even if ip_summed is
CHECKSUM_PARTIAL.  To avoid misuse, this patch a comment which specifies that
CHECKSUM_PARTIAL is OK.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/linux/skbuff.h |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8b2256e..bc41f64 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2522,6 +2522,16 @@ void skb_complete_wifi_ack(struct sk_buff *skb, bool acked);
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
+/**
+ * skb_csum_unnecessary - check if the checksum needs to be verified
+ * @skb: skb to check
+ *
+ * check if the checksum of this skb needs to be verified.  This function is
+ * effective only against skbs on inbound path.
+ *
+ * NB: This returns true if ip_summed is CHECKSUM_UNNECESSARY or
+ *     CHECKSUM_PARTIAL.
+ **/
 static inline int skb_csum_unnecessary(const struct sk_buff *skb)
 {
 	return skb->ip_summed & CHECKSUM_UNNECESSARY;
