From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the  tree
Date: Mon, 21 May 2012 12:27:38 +1000
Message-ID: <20120521122738.6efeece76ae43e7948a12d04@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__21_May_2012_12_27_38_+1000_Rb256l.qXR3KiJys"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Parav Pandit <parav.pandit@emulex.com>,
	Roland Dreier <roland@kernel.org>, linux-rdma@vger.kernel.org,
	Somnath Kotur <somnath.kotur@emulex.com>,
	Somnath Kotur <somnath.kotur@emulex.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__21_May_2012_12_27_38_+1000_Rb256l.qXR3KiJys
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/emulex/benet/be.h between commit c72adfd767af
("be2net: Add functionality to support RoCE driver") from the infiniband
tree and commit 941a77d582c8 ("be2net: Fix to allow get/set of debug
levels in the firmware") from the net-next tree.

Just context changes.  I fixed it up (see below) and carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/emulex/benet/be.h
index 7bb2e97,ff4eb8f..0000000
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@@ -32,9 -32,8 +32,9 @@@
  #include <linux/u64_stats_sync.h>
 =20
  #include "be_hw.h"
 +#include "be_roce.h"
 =20
- #define DRV_VER			"4.2.116u"
+ #define DRV_VER			"4.2.220u"
  #define DRV_NAME		"be2net"
  #define BE_NAME			"ServerEngines BladeEngine2 10Gbps NIC"
  #define BE3_NAME		"ServerEngines BladeEngine3 10Gbps NIC"
@@@ -379,22 -404,7 +406,18 @@@ struct be_adapter=20
  	u32 rx_fc;		/* Rx flow control */
  	u32 tx_fc;		/* Tx flow control */
  	bool stats_cmd_sent;
- 	int link_speed;
- 	u8 port_type;
- 	u8 transceiver;
- 	u8 autoneg;
  	u8 generation;		/* BladeEngine ASIC generation */
 +	u32 if_type;
 +	struct {
 +		u8 __iomem *base;	/* Door Bell */
 +		u32 size;
 +		u32 total_size;
 +		u64 io_addr;
 +	} roce_db;
 +	u32 num_msix_roce_vec;
 +	struct ocrdma_dev *ocrdma_dev;
 +	struct list_head entry;
 +
  	u32 flash_status;
  	struct completion flash_compl;
 =20
@@@ -606,17 -603,7 +626,19 @@@ extern void be_link_status_update(struc
  extern void be_parse_stats(struct be_adapter *adapter);
  extern int be_load_fw(struct be_adapter *adapter, u8 *func);
  extern bool be_is_wol_supported(struct be_adapter *adapter);
+ extern bool be_pause_supported(struct be_adapter *adapter);
+ extern u32 be_get_fw_log_level(struct be_adapter *adapter);
 =20
 +/*
 + * internal function to initialize-cleanup roce device.
 + */
 +extern void be_roce_dev_add(struct be_adapter *);
 +extern void be_roce_dev_remove(struct be_adapter *);
 +
 +/*
 + * internal function to open-close roce device during ifup-ifdown.
 + */
 +extern void be_roce_dev_open(struct be_adapter *);
 +extern void be_roce_dev_close(struct be_adapter *);
 +
  #endif				/* BE_H */

--Signature=_Mon__21_May_2012_12_27_38_+1000_Rb256l.qXR3KiJys
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPuagaAAoJEECxmPOUX5FEKz0P/0Uxpxw019qrDslPLhaACCMq
kVaH34tV1DtEPVEna3TzYmqqcVC1aIAshWWDDVDoeTDVolrKtDTzUTGdevZabSCs
l5UpE01ddktmGfQEikbRLE7327t3sloi6wOI4ESgD6lHlxEpQ9o22Ef7ZxvM3jxf
G3vBMXIZX/4pKvqlKnWJixInclyLdS6GnPtECUBA3CCClXPl7cxaEUhnU4ITCNGT
qlWlA3Ffnb2WinFTPDnXW+9CUl9iOxU5YfVV1HZcGZPr6GwIfdYSEqnDAoq1ibnp
E883+DCNPOfE2AF7+QcvgyxkhFviFUBB1XyUJyiMEviQ4Hc+fxD7uZSKlLn/imN/
/zK0omFiAMwyHVpCDb771XEpH+ICb9FG1+LyCiyyWDyHW9YJuS0zkI2HThU1P+7Z
TMBsx6OOY6eHEkupsM0O8YRBp9ExAF6cvSwOUS6k/y+dSK/liikYg7RV5bYwbrMM
EeIIzkNrozmVC6wud9i3oSib9u4qzSgtE9ywjMrwVUytfZLKxi5eLzTtzawBVfl2
DkEy+NYPxKiEuCJ1w4ZAmJyQRPH8PYfJ1nqNE0cbQAC1yFb3uaL3k32M1OLK/21h
l1JfNmhf/yEahdHRzHWuHKVj6lf3g5e9aSrSQsTDxHxVzEayS/GmE5n9OR0lfiuZ
6wy3QlAMA9/EaU8qhCXd
=nvHC
-----END PGP SIGNATURE-----

--Signature=_Mon__21_May_2012_12_27_38_+1000_Rb256l.qXR3KiJys--
