From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] dm9601: Fix multicast hash table handling
Date: Wed, 26 Mar 2008 08:51:30 +0100
Message-ID: <87zlsldit9.fsf@macbook.be.48ers.dk>
References: <1205878614-29065-1-git-send-email-jacmet@sunsite.dk>
	<47E9C0E3.6040404@garzik.org> <47E9C419.3040706@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:2285 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbYCZHvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 03:51:54 -0400
Received: by fk-out-0910.google.com with SMTP id 19so4614651fkr.5
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2008 00:51:52 -0700 (PDT)
In-Reply-To: <47E9C419.3040706@garzik.org> (Jeff Garzik's message of "Tue\, 25 Mar 2008 23\:33\:45 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Jeff" == Jeff Garzik <jeff@garzik.org> writes:

 Jeff> I take that back... this breaks the build:  'mlist' not defined

Argh, it seems like I sent the wrong patch - Sorry about that :/

It was ofcause meant to be mc_list instead. I would like to get this
patch in 2.6.25 if possible.


>From 7ac36d3b2f78a31c6dc224968f9b19a0d6c71688 Mon Sep 17 00:00:00 2001
From: Peter Korsgaard <jacmet@sunsite.dk>
Date: Wed, 26 Mar 2008 08:48:52 +0100
Subject: [PATCH] dm9601: Fix multicast hash table handling

The loop forgot to walk the net->mc_list list, so only the first
multicast address was programmed into the hash table.
---
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
