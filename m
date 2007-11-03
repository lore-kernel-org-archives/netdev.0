From: Jochen Friedrich <jochen@scram.de>
Subject: [PATCH] [POWERPC] Fix typo #ifdef -> #ifndef
Date: Sat, 03 Nov 2007 20:16:36 +0100
Message-ID: <472CC914.3030709@scram.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>,
	Scott Wood <scottwood@freescale.com>,
	Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>
To: "linuxppc-embedded@ozlabs.org" <linuxppc-embedded@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail0.scram.de ([78.47.204.202]:46016 "EHLO mail0.scram.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755741AbXKCTQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2007 15:16:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

fpi->cp_command should be overwritten only if CONFIG_PPC_CPM_NEW_BINDING
is NOT set. Otherwise it is already set from the device tree.

Signed-off-by: Jochen Friedrich <jochen@scram.de>
---

This can be pulled from git://git.bocc.de/dbox2.git for-2.6.24

 drivers/net/fs_enet/mac-scc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/fs_enet/mac-scc.c
index 03134f4..48f2f30 100644
--- a/drivers/net/fs_enet/mac-scc.c
+++ b/drivers/net/fs_enet/mac-scc.c
@@ -158,7 +158,7 @@ static int setup_data(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 
-#ifdef CONFIG_PPC_CPM_NEW_BINDING
+#ifndef CONFIG_PPC_CPM_NEW_BINDING
 	struct fs_platform_info *fpi = fep->fpi;
 
 	fep->scc.idx = fs_get_scc_index(fpi->fs_no);
-- 
1.5.3.4

