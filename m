From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 10 Aug 2015 11:24:15 +1000
Message-ID: <20150810112415.3d7ffba8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ian Campbell <ijc@hellion.org.uk>,
	Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/ethernet/cavium/Kconfig

between commit:

  22f54bf932a0 ("net: thunderx: remove effective "default y" from Kconfig if ARCH_THUNDER=y")

from the net tree and commit:

  274b0b3984a9 ("net: thunderx: Select CONFIG_MDIO_OCTEON for ThunderX NIC")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/cavium/Kconfig
index 02e23e6f1424,358442087878..000000000000
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@@ -34,6 -36,9 +34,8 @@@ config THUNDER_NIC_V
  config	THUNDER_NIC_BGX
  	tristate "Thunder MAC interface driver (BGX)"
  	depends on 64BIT
 -	default ARCH_THUNDER
+ 	select PHYLIB
+ 	select MDIO_OCTEON
  	---help---
  	  This driver supports programming and controlling of MAC
  	  interface from NIC physical function driver.
