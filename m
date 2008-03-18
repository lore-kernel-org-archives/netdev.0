From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: Fix multicast hash table handling
Date: Tue, 18 Mar 2008 23:16:52 +0100
Message-ID: <1205878614-29065-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:31682 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936053AbYCSVFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 17:05:00 -0400
Received: by nf-out-0910.google.com with SMTP id g13so342168nfb.21
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 14:04:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The loop forgot to walk the net->mc_list list, so only the first
multicast address was programmed into the hash table.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/dm9601.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 4b131a6..96082fd 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -354,7 +354,7 @@ static void dm9601_set_multicast(struct net_device *net)
 		struct dev_mc_list *mc_list = net->mc_list;
 		int i;
 
-		for (i = 0; i < net->mc_count; i++) {
+		for (i = 0; i < net->mc_count; i++, mlist = mlist->next) {
 			u32 crc = ether_crc(ETH_ALEN, mc_list->dmi_addr) >> 26;
 			hashes[crc >> 3] |= 1 << (crc & 0x7);
 		}
-- 
1.5.4.1

