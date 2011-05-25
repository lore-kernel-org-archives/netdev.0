From: Ulrich Hecht <uli@suse.de>
Subject: [PATCH] via-velocity: don't annotate MAC registers as packed
Date: Wed, 25 May 2011 13:07:22 +0200
Message-ID: <1306321642-2861-1-git-send-email-uli@suse.de>
Cc: uli@suse.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50364 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454Ab1EYLIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2011 07:08:25 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.221.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 89B0990847
	for <netdev@vger.kernel.org>; Wed, 25 May 2011 13:08:24 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ARM, memory accesses through packed pointers behave in unexpected
ways in GCC releases 4.3 and higher; see https://lkml.org/lkml/2011/2/2/163
for discussion.

In this particular case, 32-bit I/O registers are accessed bytewise,
causing incorrect setting of the DMA address registers which in turn
leads to an error interrupt storm that brings the system to a halt.

Since the mac_regs structure does not need any packing anyway, this patch
simply removes the attribute to fix the issue.

Signed-off-by: Ulrich Hecht <uli@suse.de>
---
 drivers/net/via-velocity.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 70da79d..659b211 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1096,7 +1096,7 @@ struct mac_regs {
 
 	volatile __le16 PatternCRC[8];	/* 0xB0 */
 	volatile __le32 ByteMask[4][4];	/* 0xC0 */
-} __packed;
+};
 
 
 enum hw_mib {
-- 
1.7.1

