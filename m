From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 6 Jan 2014 15:35:51 +1100
Message-ID: <20140106153551.96ff6d1cdd77e857d68e00b9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__6_Jan_2014_15_35_51_+1100_apAzP_Kqy6P754wZ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Manish Chopra <manish.chopra@qlogic.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__6_Jan_2014_15_35_51_+1100_apAzP_Kqy6P754wZ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c between commit
f3e3ccf83bab ("qlcnic: Fix resource allocation for TX queues") from the
net tree and commit 154d0c810c53 ("qlcnic: VLAN enhancement for 84XX
adapters") from the net-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 024f8161d2fe,98b621fb1227..000000000000
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@@ -75,17 -76,22 +76,22 @@@ static int qlcnic_sriov_pf_cal_res_limi
  	num_vfs =3D sriov->num_vfs;
  	max =3D num_vfs + 1;
  	info->bit_offsets =3D 0xffff;
- 	info->max_rx_mcast_mac_filters =3D res->num_rx_mcast_mac_filters;
- 	num_vf_macs =3D QLCNIC_SRIOV_VF_MAX_MAC;
 -	info->max_tx_ques =3D res->num_tx_queues / max;
+=20
+ 	if (qlcnic_83xx_pf_check(adapter))
+ 		num_macs =3D 1;
 =20
  	if (adapter->ahw->pci_func =3D=3D func) {
- 		temp =3D res->num_rx_mcast_mac_filters - (num_vfs * num_vf_macs);
- 		info->max_rx_ucast_mac_filters =3D temp;
- 		temp =3D res->num_tx_mac_filters - (num_vfs * num_vf_macs);
- 		info->max_tx_mac_filters =3D temp;
  		info->min_tx_bw =3D 0;
  		info->max_tx_bw =3D MAX_BW;
 +		info->max_tx_ques =3D res->num_tx_queues - sriov->num_vfs;
+ 		temp =3D res->num_rx_ucast_mac_filters - num_macs * num_vfs;
+ 		info->max_rx_ucast_mac_filters =3D temp;
+ 		temp =3D res->num_tx_mac_filters - num_macs * num_vfs;
+ 		info->max_tx_mac_filters =3D temp;
+ 		temp =3D num_macs * num_vfs * QLCNIC_SRIOV_VF_MAX_MAC;
+ 		temp =3D res->num_rx_mcast_mac_filters - temp;
+ 		info->max_rx_mcast_mac_filters =3D temp;
+=20
  	} else {
  		id =3D qlcnic_sriov_func_to_index(adapter, func);
  		if (id < 0)
@@@ -93,9 -99,10 +99,11 @@@
  		vp =3D sriov->vf_info[id].vp;
  		info->min_tx_bw =3D vp->min_tx_bw;
  		info->max_tx_bw =3D vp->max_tx_bw;
- 		info->max_rx_ucast_mac_filters =3D num_vf_macs;
- 		info->max_tx_mac_filters =3D num_vf_macs;
+ 		info->max_rx_ucast_mac_filters =3D num_macs;
+ 		info->max_tx_mac_filters =3D num_macs;
 +		info->max_tx_ques =3D QLCNIC_SINGLE_RING;
+ 		temp =3D num_macs * QLCNIC_SRIOV_VF_MAX_MAC;
+ 		info->max_rx_mcast_mac_filters =3D temp;
  	}
 =20
  	info->max_rx_ip_addr =3D res->num_destip / max;

--Signature=_Mon__6_Jan_2014_15_35_51_+1100_apAzP_Kqy6P754wZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSyjKnAAoJEMDTa8Ir7ZwVzkwP+wd4KyRUtSa1TbfskcD/dk15
NFZ8CZaEw5lg+jeFaR97iIbhzOs3HtfnX2dF7DMOg+O9R6fVMiFlsYgA99AVku9D
5ve6Iy0AqzUDoSuqHhWxqCDXZbD92lBe7PAnrmF/yDhOmMHOB6hsr9lv0PYQqdba
NjjuUK+S4/EMajNcJ/5r1WeGeS0L0rHlqsMkSYisZNsMaqjL1T5hkTRsR0PCGdAr
uk+R+U1OHXCDDS/LEa1bOyxtKsOUo3E4rkhUrLnQnzybe2m1lDepLn9Dc9ZW4Qrp
DU8ROVeu/TFlczvZKaU3rLdmq3VTVUw2Jj9Nw67QwpHczhlICOgp7N7rQyrTWiH9
82xvZQBD3QgsEJ1Q+43GMeQxuFENqhkhzVKP0sUwBPBum75H1PU1dHyCjMtggszW
w4FrYP0Z+wHXZA4ykfsVkGIxQUZFpESq3sHnFToxrbBS9aNJM8PTh3qc3cQDaNuN
Cb14kG9FIjvbLSzSgxU6irakfMPj+eazmgjzYeaOJ1mrxLJJ3nnxG+yEiuM7Z+vB
+O6EKymjAb6EGxWFlq8/Zr/LXMjPOtsjlkSscWD0UCe7JF05vyunyrlV8YN1Ms8N
lSiJFF/2URnZQSWhpCU3v3LoUL4cBygAvSteinEr5/quYg8UVIlT5ZJPMU7LwEQU
4qhDoHvBZAO3KqrViz38
=J41P
-----END PGP SIGNATURE-----

--Signature=_Mon__6_Jan_2014_15_35_51_+1100_apAzP_Kqy6P754wZ--
