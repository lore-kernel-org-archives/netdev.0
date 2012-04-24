From: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Subject: linux-next: manual merge of the net-next tree with the infiniband
 tree
Date: Tue, 24 Apr 2012 12:06:11 +1000
Message-ID: <20120424120611.cce0e2cdee61b60c700725a8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__24_Apr_2012_12_06_11_+1000_QBc0z=7ZcH=PXpsO"
Cc: linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Parav Pandit <parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>,
	Ajit Khaparde <ajitkhaparde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__24_Apr_2012_12_06_11_+1000_QBc0z=7ZcH=PXpsO
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/emulex/benet/be.h between commit c72adfd767af
("be2net: Add functionality to support RoCE driver") from the infiniband
tree and commit 42f11cf20cc5 ("be2net: fix ethtool get settings") from
the net-next tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org

diff --cc drivers/net/ethernet/emulex/benet/be.h
index 7bb2e97,ad69cf8..0000000
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@@ -379,22 -394,7 +396,18 @@@ struct be_adapter=20
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
@@@ -606,17 -597,5 +620,18 @@@ extern void be_link_status_update(struc
  extern void be_parse_stats(struct be_adapter *adapter);
  extern int be_load_fw(struct be_adapter *adapter, u8 *func);
  extern bool be_is_wol_supported(struct be_adapter *adapter);
+ extern bool be_pause_supported(struct be_adapter *adapter);
 +
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

--Signature=_Tue__24_Apr_2012_12_06_11_+1000_QBc0z=7ZcH=PXpsO
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPlgqTAAoJEECxmPOUX5FEbUAP/jIf5CKRfbZXwM2tRgh1wg+Z
kipdXKoFPouQoHLtyyOx3Vcs39j0wL12qQqa2O2bhHO+vQzmTyEtOMczGPytbEd5
XPmv2w8Qoi4ZexbCi6eVPhJYlwRP3cluQZhH7pAIvEaJt9VWg2q0In4VSXUhKggY
iydQAYBhyFx55wQ5ZqahGdx4UKFeP/wyjDYImXXGvJ9gn86PRW8qXw1QsrVPSoPR
uNp2EOKZBW0Q9NMUkuqzHtgpz3TSiO30A/2IxmN6GB6HSJcyIylyMVGQWzMyv5df
8v9SjAS0k8BITNJOsoFcJytkzCv/5Tv2Hme4uVaBGQLkdPyYjvqnJ+A/jOoyKGXI
TEwhr4/HSRwbQOJZwIfswLTZIgFMkiCHzn5icxpbK/bLTS3K7BYno+awGxzcv9YF
C/sh8738jthBUzvimDGqUKakc2bVvs9owHowAvcokKcgzAZDdTGOae/Dnz7hC6o3
r5jEvpnD0SthlOQjilO09D1ke4vCbk35K9G5jON6+PQ1YZd5F1ft+a2HIIcaYmqq
gVMX+td4sCj4RFzaqoG0mxS5GsNgQs3haYvF3lv+qGOIx4AMDzP0yfDn3M5b58Vc
aQ6gVU/uPEyJV/SSxRUMtvX6cCXI8KfXk1LKImSVq3DMP29f5fhvvcPWhupK18Yu
UkPngkPoiG9LnCXrrrqe
=H1b7
-----END PGP SIGNATURE-----

--Signature=_Tue__24_Apr_2012_12_06_11_+1000_QBc0z=7ZcH=PXpsO--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
