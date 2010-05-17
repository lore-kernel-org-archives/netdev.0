From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the m68k tree
Date: Mon, 17 May 2010 12:11:53 +1000
Message-ID: <20100517121153.438f94dc.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
include/linux/mod_devicetable.h between commit
52498c252690651f915aecbcd10e26bcbafbe2a3 ("m68k: amiga - Zorro bus
modalias support") from the m68k tree and commit
8626d3b4328061f5b82b11ae1d6918a0c3602f42 ("phylib: Support phy module
autoloading") from the net tree.

Just overlapping additions.  I fixed it up (see below) and can carry the
fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/linux/mod_devicetable.h
index 56fde43,55f1f9c..0000000
--- a/include/linux/mod_devicetable.h
+++ b/include/linux/mod_devicetable.h
@@@ -474,13 -474,30 +474,39 @@@ struct platform_device_id 
  			__attribute__((aligned(sizeof(kernel_ulong_t))));
  };
  
 +struct zorro_device_id {
 +	__u32 id;			/* Device ID or ZORRO_WILDCARD */
 +	kernel_ulong_t driver_data;	/* Data private to the driver */
 +};
 +
 +#define ZORRO_WILDCARD			(0xffffffff)	/* not official */
 +
 +#define ZORRO_DEVICE_MODALIAS_FMT	"zorro:i%08X"
 +
+ #define MDIO_MODULE_PREFIX	"mdio:"
+ 
+ #define MDIO_ID_FMT "%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d"
+ #define MDIO_ID_ARGS(_id) \
+ 	(_id)>>31, ((_id)>>30) & 1, ((_id)>>29) & 1, ((_id)>>28) & 1,	\
+ 	((_id)>>27) & 1, ((_id)>>26) & 1, ((_id)>>25) & 1, ((_id)>>24) & 1, \
+ 	((_id)>>23) & 1, ((_id)>>22) & 1, ((_id)>>21) & 1, ((_id)>>20) & 1, \
+ 	((_id)>>19) & 1, ((_id)>>18) & 1, ((_id)>>17) & 1, ((_id)>>16) & 1, \
+ 	((_id)>>15) & 1, ((_id)>>14) & 1, ((_id)>>13) & 1, ((_id)>>12) & 1, \
+ 	((_id)>>11) & 1, ((_id)>>10) & 1, ((_id)>>9) & 1, ((_id)>>8) & 1, \
+ 	((_id)>>7) & 1, ((_id)>>6) & 1, ((_id)>>5) & 1, ((_id)>>4) & 1, \
+ 	((_id)>>3) & 1, ((_id)>>2) & 1, ((_id)>>1) & 1, (_id) & 1
+ 
+ /**
+  * struct mdio_device_id - identifies PHY devices on an MDIO/MII bus
+  * @phy_id: The result of
+  *     (mdio_read(&MII_PHYSID1) << 16 | mdio_read(&PHYSID2)) & @phy_id_mask
+  *     for this PHY type
+  * @phy_id_mask: Defines the significant bits of @phy_id.  A value of 0
+  *     is used to terminate an array of struct mdio_device_id.
+  */
+ struct mdio_device_id {
+ 	__u32 phy_id;
+ 	__u32 phy_id_mask;
+ };
+ 
  #endif /* LINUX_MOD_DEVICETABLE_H */
