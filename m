From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 3/3] [POWERPC] 86xx: mpc8610_hpcd: use ULI526X driver for
	on-board ethernet
Date: Tue, 29 Apr 2008 19:53:33 +0400
Message-ID: <20080429155333.GC28166@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:49624 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1761469AbYD2Pxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 11:53:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As of current mainline tree, TULIP driver is unusable on MPC8610HPCD
boards. There is a patch[1] floating around (and also included in the
BSP), which tries to heal the situation, though the ethernet is still
unusable. Practically it takes ages to mount NFS filesystem:

VFS: Mounted root (nfs filesystem).
Freeing unused kernel memory: 180k init
nfs: server 10.0.0.2 not responding, still trying
nfs: server 10.0.0.2 OK
nfs: server 10.0.0.2 not responding, still trying
nfs: server 10.0.0.2 not responding, still trying
nfs: server 10.0.0.2 not responding, still trying
nfs: server 10.0.0.2 not responding, still trying
nfs: server 10.0.0.2 OK
nfs: server 10.0.0.2 not responding, still trying

So, instead of trying to add uli526x functionality into TULIP driver
(which is already bloated enough), I fixed existing ULI526X driver
and now it works perfectly well here.

[1] http://www.bitshrine.org/gpp/0024-MPC8610-ETH-Lyra-native-ethernet.txt

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

This is for powerpc tree.

 arch/powerpc/configs/mpc8610_hpcd_defconfig |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/configs/mpc8610_hpcd_defconfig b/arch/powerpc/configs/mpc8610_hpcd_defconfig
index 9270afe..f9e53bd 100644
--- a/arch/powerpc/configs/mpc8610_hpcd_defconfig
+++ b/arch/powerpc/configs/mpc8610_hpcd_defconfig
@@ -567,14 +567,11 @@ CONFIG_MII=y
 # CONFIG_NET_VENDOR_3COM is not set
 CONFIG_NET_TULIP=y
 # CONFIG_DE2104X is not set
-CONFIG_TULIP=y
-# CONFIG_TULIP_MWI is not set
-CONFIG_TULIP_MMIO=y
-# CONFIG_TULIP_NAPI is not set
+# CONFIG_TULIP is not set
 # CONFIG_DE4X5 is not set
 # CONFIG_WINBOND_840 is not set
 # CONFIG_DM9102 is not set
-# CONFIG_ULI526X is not set
+CONFIG_ULI526X=y
 # CONFIG_HP100 is not set
 # CONFIG_IBM_NEW_EMAC_ZMII is not set
 # CONFIG_IBM_NEW_EMAC_RGMII is not set
-- 
1.5.5.1
