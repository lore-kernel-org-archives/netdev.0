From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: Fix multicast hash table handling
Date: Fri, 28 Mar 2008 22:25:29 +0100
Message-ID: <877ifmfsmu.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:15962 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755048AbYC1V2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:28:11 -0400
Received: by wa-out-1112.google.com with SMTP id v27so501964wah.23
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 14:28:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The loop forgot to walk the net->mc_list list, so only the first
multicast address was programmed into the hash table.
---
Jeff, I would like to get this patch in 2.6.25 if possible.

 drivers/net/usb/dm9601.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 0343b00..01660f6 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -354,7 +354,7 @@ static void dm9601_set_multicast(struct net_device *net)
 		struct dev_mc_list *mc_list = net->mc_list;
 		int i;
 
-		for (i = 0; i < net->mc_count; i++) {
+		for (i = 0; i < net->mc_count; i++, mc_list = mc_list->next) {
 			u32 crc = ether_crc(ETH_ALEN, mc_list->dmi_addr) >> 26;
 			hashes[crc >> 3] |= 1 << (crc & 0x7);
 		}
-- 
1.5.4.4


-- 
Bye, Peter Korsgaard
