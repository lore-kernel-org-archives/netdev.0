From: Dan Carpenter <error27@gmail.com>
Subject: [patch] enic: cleanup vic_provinfo_alloc()
Date: Thu, 10 Jun 2010 09:59:03 +0200
Message-ID: <20100610075903.GL5483@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:58364 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396Ab0FJH7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 03:59:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If oui were a null variable then vic_provinfo_alloc() would leak memory.
But this function is only called from one place and oui is not null so 
I removed the check.

I also moved the memory allocation down a line so it was easier to spot.
(No one ever reads variable declarations).

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/enic/vnic_vic.c b/drivers/net/enic/vnic_vic.c
index d769772..0a35085 100644
--- a/drivers/net/enic/vnic_vic.c
+++ b/drivers/net/enic/vnic_vic.c
@@ -25,9 +25,10 @@
 
 struct vic_provinfo *vic_provinfo_alloc(gfp_t flags, u8 *oui, u8 type)
 {
-	struct vic_provinfo *vp = kzalloc(VIC_PROVINFO_MAX_DATA, flags);
+	struct vic_provinfo *vp;
 
-	if (!vp || !oui)
+	vp = kzalloc(VIC_PROVINFO_MAX_DATA, flags);
+	if (!vp)
 		return NULL;
 
 	memcpy(vp->oui, oui, sizeof(vp->oui));
