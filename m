From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] SIS900 must select MII
Date: Sat, 30 Apr 2005 13:52:49 +0200
Message-ID: <20050430115249.GA3654@stusta.de>
References: <20050429231653.32d2f091.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261201AbVD3Lwx@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, venza@brownhat.org,
	jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20050429231653.32d2f091.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the following compile error caused by bk-netdev:

<--  snip  -->

...
  LD      .tmp_vmlinux1
drivers/built-in.o(.text+0x98528): In function `sis900_get_settings':
: undefined reference to `mii_ethtool_gset'
drivers/built-in.o(.text+0x98538): In function `sis900_set_settings':
: undefined reference to `mii_ethtool_sset'
drivers/built-in.o(.text+0x98517): In function `sis900_get_link':
: undefined reference to `mii_link_ok'
drivers/built-in.o(.text+0x98547): In function `sis900_nway_reset':
: undefined reference to `mii_nway_restart'
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->


Signed-off-by: Adrian Bunk <bunk@stusta.de>


--- linux-2.6.12-rc3-mm1/drivers/net/Kconfig.old	2005-04-30 13:47:25.000000000 +0200
+++ linux-2.6.12-rc3-mm1/drivers/net/Kconfig	2005-04-30 13:47:48.000000000 +0200
@@ -1543,8 +1543,9 @@
 config SIS900
 	tristate "SiS 900/7016 PCI Fast Ethernet Adapter support"
 	depends on NET_PCI && PCI
 	select CRC32
+	select MII
 	---help---
 	  This is a driver for the Fast Ethernet PCI network cards based on
 	  the SiS 900 and SiS 7016 chips. The SiS 900 core is also embedded in
 	  SiS 630 and SiS 540 chipsets.  If you have one of those, say Y and
