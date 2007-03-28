From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH] atl1: remove unnecessary crc inversion
Date: Tue, 27 Mar 2007 19:43:49 -0500
Message-ID: <20070328004349.GA2792@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jareguero@telefonica.net,
	atl1-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf18aec.mail.bellsouth.net ([205.152.59.66]:57887 "EHLO
	imf18aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934300AbXC1Anv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 20:43:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Cliburn <jacliburn@bellsouth.net>

The original vendor driver contained a private ether_crc_le() function
that produced an inverted crc.  When we changed to the kernel version of
ether_crc_le(), we neglected to undo the inversion.  Let's do it now.
Discovered by and patch proffered by Jose Alberto Reguero.

Signed-off-by: Jose Alberto Reguero <jareguero@telefonica.net>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atl1/atl1_hw.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
index 314dbaa..69482e0 100644
--- a/drivers/net/atl1/atl1_hw.c
+++ b/drivers/net/atl1/atl1_hw.c
@@ -334,7 +334,6 @@ u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr)
 	int i;
 
 	crc32 = ether_crc_le(6, mc_addr);
-	crc32 = ~crc32;
 	for (i = 0; i < 32; i++)
 		value |= (((crc32 >> i) & 1) << (31 - i));
 
