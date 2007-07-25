From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] one e1000 driver should be enough for everyone
Date: Wed, 25 Jul 2007 15:36:50 +0200
Message-ID: <20070725133650.GB3572@stusta.de>
References: <20070725040304.111550f4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Auke Kok <auke-jan.h.kok@intel.com>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:43998 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756567AbXGYNhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 09:37:19 -0400
Content-Disposition: inline
In-Reply-To: <20070725040304.111550f4.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 25, 2007 at 04:03:04AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.22-rc6-mm1:
>...
>  git-e1000new.patch
>...
>  git trees
>...

Both e1000 drivers compiled into the kernel resulted in the following 
compile error:

<--  snip  -->

...
  LD      drivers/net/built-in.o
drivers/net/e1000/built-in.o: In function `e1000_read_mac_addr':
(.text+0xb9f2): multiple definition of `e1000_read_mac_addr'
drivers/net/e1000new/built-in.o:(.text+0x821a): first defined here
drivers/net/e1000/built-in.o: In function `e1000_phy_setup_autoneg':
(.text+0x8799): multiple definition of `e1000_phy_setup_autoneg'
drivers/net/e1000new/built-in.o:(.text+0xa9bd): first defined here
...
make[3]: *** [drivers/net/built-in.o] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

BTW:
Unless I'm misunderstanding anything, the new driver should support a 
superset of what the old driver supported.
Therefore, it would be good if the final merge into Linus' tree will
do an
  rm -r drivers/net/e1000
  mv drivers/net/e1000new drivers/net/e1000

--- linux-2.6.23-rc1-mm1/drivers/net/Kconfig.old	2007-07-25 15:06:13.000000000 +0200
+++ linux-2.6.23-rc1-mm1/drivers/net/Kconfig	2007-07-25 15:09:59.000000000 +0200
@@ -2036,7 +2036,7 @@
 
 config E1000
 	tristate "Intel(R) PRO/1000 Gigabit Ethernet support"
-	depends on PCI
+	depends on PCI && E1000NEW=n
 	---help---
 	  This driver supports Intel(R) PRO/1000 gigabit ethernet family of
 	  adapters.  For more information on how to identify your adapter, go 

