From: Patrick McHardy <kaber@trash.net>
Subject: Re: ~3 hours old git tree: Virtual device lo asks to queue packet!
Date: Thu, 19 Jul 2007 11:25:40 +0200
Message-ID: <469F2E14.9050200@trash.net>
References: <200707182218.13548.arekm@maven.pl> <469E9CF7.1040403@trash.net> <200707190819.53364.arekm@maven.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010405090702070004040101"
Cc: netdev@vger.kernel.org
To: Arkadiusz Miskiewicz <arekm@maven.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61882 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964908AbXGSJ03 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 05:26:29 -0400
In-Reply-To: <200707190819.53364.arekm@maven.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010405090702070004040101
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Arkadiusz Miskiewicz wrote:
> On Thursday 19 of July 2007, Patrick McHardy wrote:
> 
>>Arkadiusz Miskiewicz wrote:
>>
>>>I'm having problems with networking on recent git kernel.
>>>
>>>kernel logs tons of "Virtual device lo asks to queue packet!"
>>>and networking stops working correctly:
>>>
>>>CONFIG_NETDEVICES_MULTIQUEUE=y
>>
>>Does it go away if you disable this option?
> 
> 
> Yes, it goes away after disabling this.


I don't see a bug in the code itself, maybe the queue_mapping points
to an invalid subqueue. Could you please try this patch and post the
output?


--------------010405090702070004040101
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/core/dev.c b/net/core/dev.c
index 6357f54..f188ffa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1605,7 +1605,8 @@ gso:
 			HARD_TX_UNLOCK(dev);
 			if (net_ratelimit())
 				printk(KERN_CRIT "Virtual device %s asks to "
-				       "queue packet!\n", dev->name);
+				       "queue packet subqueue %u!\n",
+				       dev->name, skb->queue_mapping);
 		} else {
 			/* Recursion is detected! It is possible,
 			 * unfortunately */

--------------010405090702070004040101--
