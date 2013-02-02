From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Sat, 2 Feb 2013 14:22:38 +1100
Message-ID: <20130202142238.966d4a1e8a587313fe5e6a4f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Sat__2_Feb_2013_14_22_38_+1100_7jkS/LOaeRFwKXzI"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Sat__2_Feb_2013_14_22_38_+1100_7jkS/LOaeRFwKXzI
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/vmxnet3/vmxnet3_drv.c between commit 6cdd20c380eb ("vmxnet3:
set carrier state properly on probe") from the net tree and commit
204a6e659439 ("vmxnet3: use netdev_ printk wrappers") from the net-next
tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/vmxnet3/vmxnet3_drv.c
index 12c6440,b1c90f8..0000000
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@@ -152,9 -148,10 +148,9 @@@ vmxnet3_check_link(struct vmxnet3_adapt
 =20
  	adapter->link_speed =3D ret >> 16;
  	if (ret & 1) { /* Link is up. */
- 		printk(KERN_INFO "%s: NIC Link is Up %d Mbps\n",
- 		       adapter->netdev->name, adapter->link_speed);
+ 		netdev_info(adapter->netdev, "NIC Link is Up %d Mbps\n",
+ 			    adapter->link_speed);
 -		if (!netif_carrier_ok(adapter->netdev))
 -			netif_carrier_on(adapter->netdev);
 +		netif_carrier_on(adapter->netdev);
 =20
  		if (affectTxQueue) {
  			for (i =3D 0; i < adapter->num_tx_queues; i++)
@@@ -162,9 -159,9 +158,8 @@@
  						 adapter);
  		}
  	} else {
- 		printk(KERN_INFO "%s: NIC Link is Down\n",
- 		       adapter->netdev->name);
+ 		netdev_info(adapter->netdev, "NIC Link is Down\n");
 -		if (netif_carrier_ok(adapter->netdev))
 -			netif_carrier_off(adapter->netdev);
 +		netif_carrier_off(adapter->netdev);
 =20
  		if (affectTxQueue) {
  			for (i =3D 0; i < adapter->num_tx_queues; i++)

--Signature=_Sat__2_Feb_2013_14_22_38_+1100_7jkS/LOaeRFwKXzI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRDIZ+AAoJEECxmPOUX5FE+p0P/0bQOWIbWT7wN3A64U2dpgAn
MZLlwuaaqsFK7wX3Dx+NoDhxxyKwYUr7rWQPgbiVYvO28re1/Mfz/9fmTII5/v78
66bpY/QQpB9ADQZIeaQL4GycWWO3gF1Eq1sTx3XhIdbCsY5ygCQTCJPdo9vg7kSd
rdK22zb2mXZom1xxBl2fDvyOUzA8xr936m9cxNs/zD4AFN5ZjOVatntNQbxFar2p
urc56yFW8aZW947fSgkE1cvdU0umkNO4f0eTDSDDxF5czfRC0ylP1y58md3Upmuk
RI8rZA7EsX9w9oZHHa73xf6+4DApakhJeHBJeHPLJ2H45VKaCy9aPzP4jArc2TS0
ISWzMw+CCMIPCAjvcQPRsK0tiXSvp4vPqDLbA1HRdOzEt0hmLjavt8oNOo+l/h75
Edn6a6JPgWQDLbyb2Bp4eUvXtU8c6E4HK3JUOBSNLPbym6dXQuXZDVafIlpwXfPZ
7LIV6wPn2/xRgB8maI7yQ55keXzZ+IQ7RAFyx25BDzOYhNv+LBlcpG83zuxRRmzr
3+Xhu8HN+Kydjore6Fu9x8JRQnBIvNBklvza80SAXjCShswDA7vYO6qiw6Dxfu9y
ZQDnkRzg8UPCmpggAICF8QOrVemGavh3ryvoUzCbuW3S+UfY2aLV7l2xqtWB8B/n
AhvGhhK8QS8T9a36hkxc
=fvSB
-----END PGP SIGNATURE-----

--Signature=_Sat__2_Feb_2013_14_22_38_+1100_7jkS/LOaeRFwKXzI--
