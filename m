From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH] smsc95xx: fix tx checksum offload for big endian
Date: Fri,  2 Nov 2012 10:44:20 +0000
Message-ID: <1351853060-2330-1-git-send-email-steve.glendinning@shawell.net>
Cc: jose.ventura@efacec.com,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:39841 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756141Ab2KBKoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 06:44:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

f7b2927 introduced tx checksum offload support for smsc95xx,
and enabled it by default. This feature doesn't take
endianness into account, so causes most tx to fail on
those platforms.

This patch fixes the problem fully by adding the missing
conversion.

An alternate workaround is to disable TX checksum offload
on those platforms. The cpu impact of this feature is very low.

Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
---
 drivers/net/usb/smsc95xx.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 46cd784..34f2e78 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1398,6 +1398,7 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
 		} else {
 			u32 csum_preamble = smsc95xx_calc_csum_preamble(skb);
 			skb_push(skb, 4);
+			cpu_to_le32s(&csum_preamble);
 			memcpy(skb->data, &csum_preamble, 4);
 		}
 	}
-- 
1.7.10.4
