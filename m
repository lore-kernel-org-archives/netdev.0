From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v2] skbuff: align sk_buff::cb to 64 bit
Date: Sat, 30 Jan 2010 01:38:29 +0100
Message-ID: <4B637F85.8080809@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:59537 "EHLO ds10.nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755521Ab0A3Aie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 19:38:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The alignment requirement for 64-bit load/store instructions on ARM is
implementation defined. Some CPUs (such as Marvell Feroceon) do not
generate an exception, if such an instruction is executed with an
address that is not 64 bit aligned. In such a case, the Feroceon
corrupts adjacent memory, which showed up
in my tests as a crash in the rx path of ath9k that only occured with
CONFIG_XFRM set. This crash happened, because the first field of the
mac80211 rx status info in the cb is an u64, and changing it corrupted
the skb->sp field.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Cc: stable@kernel.org
---
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -329,7 +329,7 @@ struct sk_buff {
 	 * want to keep them across layers you have to do a skb_clone()
 	 * first. This is owned by whoever has the skb queued ATM.
 	 */
-	char			cb[48];
+	char			cb[48] __aligned(8);
  	unsigned int		len,
 				data_len;

