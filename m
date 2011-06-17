From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH] fs_enet: fix freescale FCC ethernet dp buffer alignment
Date: Fri, 17 Jun 2011 10:30:39 +0200
Message-ID: <1308299439-5975-1-git-send-email-holger.brunck@keymile.com>
Cc: Clive Stubbings <clive.stubbings@xentech.co.uk>,
	Holger Brunck <holger.brunck@keymile.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, netdev@vger.kernel.org
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.de.keymile.com ([195.8.104.1]:41035 "HELO
	mail.de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751743Ab1FQImR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 04:42:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Clive Stubbings <clive.stubbings@xentech.co.uk>

The RIPTR and TIPTR  (receive/transmit internal temporary data pointer),
used by microcode as a temporary buffer for data, must be 32-byte aligned
according to the RM for MPC8247.

Tested on mgcoge.

Signed-off-by: Clive Stubbings <clive.stubbings@xentech.co.uk>
Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>
cc: Vitaly Bordug <vbordug@ru.mvista.com>
cc: netdev@vger.kernel.org
---
This fixes a kernel crash on mgcoge when using SPI on CPM2 and
ethernet over FCC. Now fixed because the fcc driver now allocates
the space he really needs.

 drivers/net/fs_enet/mac-fcc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index 7a84e45..7583a95 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -105,7 +105,7 @@ static int do_pd_setup(struct fs_enet_private *fep)
 		goto out_ep;
 
 	fep->fcc.mem = (void __iomem *)cpm2_immr;
-	fpi->dpram_offset = cpm_dpalloc(128, 8);
+	fpi->dpram_offset = cpm_dpalloc(128, 32);
 	if (IS_ERR_VALUE(fpi->dpram_offset)) {
 		ret = fpi->dpram_offset;
 		goto out_fcccp;
-- 
1.7.1

