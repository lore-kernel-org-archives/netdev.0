From: Mark Brown <broonie@kernel.org>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 12 Mar 2014 16:00:20 +0000
Message-ID: <20140312160020.32d84949c126564994c251be@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Wed__12_Mar_2014_16_00_20_+0000_Nv.Sa.YokVOqnVqA"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__12_Mar_2014_16_00_20_+0000_Nv.Sa.YokVOqnVqA
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in drivers/net=
/usb/r8152.c between commit 10c3271712f5821 ("r8152: disable the ECM mode")=
 from the net tree and commit 4f1d4d54f99e9 ("r8152: support dumping the hw=
 counters") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

diff --cc drivers/net/usb/r8152.c
index adb12f349a61,aa1d5b2e9c30..000000000000
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@@ -449,6 -465,25 +465,22 @@@ enum rtl8152_flags=20
  #define MCU_TYPE_PLA                  0x0100
  #define MCU_TYPE_USB                  0x0000
 =20
 -#define REALTEK_USB_DEVICE(vend, prod)        \
 -      USB_DEVICE_INTERFACE_CLASS(vend, prod, USB_CLASS_VENDOR_SPEC)
 -
+ struct tally_counter {
+       __le64  tx_packets;
+       __le64  rx_packets;
+       __le64  tx_errors;
+       __le32  rx_errors;
+       __le16  rx_missed;
+       __le16  align_errors;
+       __le32  tx_one_collision;
+       __le32  tx_multi_collision;
+       __le64  rx_unicast;
+       __le64  rx_broadcast;
+       __le32  rx_multicast;
+       __le16  tx_aborted;
+       __le16  tx_underun;
+ };
+=20
  struct rx_desc {
        __le32 opts1;
  #define RX_LEN_MASK                   0x7fff

--Signature=_Wed__12_Mar_2014_16_00_20_+0000_Nv.Sa.YokVOqnVqA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTIISUAAoJELSic+t+oim9y9MP/3gKnZwFrIVSgT7xcnMBekod
ipHtNguJIHCt/l+gqju4eQpNMa6urBdDYJQm3IY8XKDoxhbBLJ1oLgoEsnmz6otg
Ls3w5j9zIZUQh3XPuaItIbfKu4zOlgBoaE3qAMT0535mfpiSv4LQkNxOGnfrGY43
4U8ZCJj5JhwUxl4aojRCz69XFuiogT0AGg2QQe/BKB8BdzAxuYE3EbTfXBob81Wx
rIl71J1WqScuSNt9tYG/cpAp9OtB2PkU2pnfKE3n4uMybsRD8XAedS2QQsnHgg6l
kr++kzBrQ7R94XyAnAjZOGKJNyxcqWkzhL45rgXUaDbk23ytjeb64JiUTzzFSdF9
Kngz6nTIrmTat4CnAHLaKQVjCrRVFCkJm3fxn631VV/mEHX9iRobrVSe7G7vbxDb
vqh9igKSq+bPAPOisHByof0Qdt/S1KoBRFZ3GzAn+QrslpMqx12qrFh9U1DiJ70U
jAFpGW9XhQKv2NF7d/l61hbkYrroF1LwcmFwy+X17XKtm7jd8BypDbQUeUMHj3HK
dPFj0zwOPkY4/pSMnatr4aMFcgEuLgvSxRZIYXYU7+M/2jI0hzvgqIGMcCraC4ch
9j7app3AYmDXE6VrdTxQXs5ezlqFK2RmmMTAJpPOEwqSLWDqKdD9UKLf9+3sOXMa
QdipK80haxU687rz3cLy
=Rgq7
-----END PGP SIGNATURE-----

--Signature=_Wed__12_Mar_2014_16_00_20_+0000_Nv.Sa.YokVOqnVqA--
