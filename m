From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the net
 tree
Date: Tue, 12 Jun 2012 11:41:29 +1000
Message-ID: <20120612114129.68159847828093544c867306@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__12_Jun_2012_11_41_29_+1000_qf5PuksRafMoQ/gn"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Johannes Berg <johannes.berg@intel.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__12_Jun_2012_11_41_29_+1000_qf5PuksRafMoQ/gn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/iwlwifi/pcie/trans.c between commit d012d04e4d63
("iwlwifi: disable the buggy chain extension feature in HW") from the net
tree and commit 4beaf6c2f8af ("iwlwifi: s/txq_setup/txq_enable") from the
wireless-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/iwlwifi/pcie/trans.c
index cb951ad,1eabb83..0000000
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@@ -1058,11 -1054,17 +1054,22 @@@ static void iwl_tx_start(struct iwl_tra
  	iwl_write_prph(trans, SCD_DRAM_BASE_ADDR,
  		       trans_pcie->scd_bc_tbls.dma >> 10);
 =20
 +	/* The chain extension of the SCD doesn't work well. This feature is
 +	 * enabled by default by the HW, so we need to disable it manually.
 +	 */
 +	iwl_write_prph(trans, SCD_CHAINEXT_EN, 0);
 +
+ 	for (i =3D 0; i < trans_pcie->n_q_to_fifo; i++) {
+ 		int fifo =3D trans_pcie->setup_q_to_fifo[i];
+=20
+ 		__iwl_trans_pcie_txq_enable(trans, i, fifo, IWL_INVALID_STATION,
+ 					    IWL_TID_NON_QOS,
+ 					    SCD_FRAME_LIMIT, 0);
+ 	}
+=20
+ 	/* Activate all Tx DMA/FIFO channels */
+ 	iwl_trans_txq_set_sched(trans, IWL_MASK(0, 7));
+=20
  	/* Enable DMA channel */
  	for (chan =3D 0; chan < FH_TCSR_CHNL_NUM ; chan++)
  		iwl_write_direct32(trans, FH_TCSR_CHNL_TX_CONFIG_REG(chan),
@@@ -1356,10 -1317,10 +1322,10 @@@ static int iwl_trans_pcie_tx(struct iwl
  	iwl_trans_txq_update_byte_cnt_tbl(trans, txq, le16_to_cpu(tx_cmd->len));
 =20
  	dma_sync_single_for_device(trans->dev, txcmd_phys, firstlen,
- 			DMA_BIDIRECTIONAL);
+ 				   DMA_BIDIRECTIONAL);
 =20
  	trace_iwlwifi_dev_tx(trans->dev,
 -			     &((struct iwl_tfd *)txq->tfds)[txq->q.write_ptr],
 +			     &txq->tfds[txq->q.write_ptr],
  			     sizeof(struct iwl_tfd),
  			     &dev_cmd->hdr, firstlen,
  			     skb->data + hdr_len, secondlen);

--Signature=_Tue__12_Jun_2012_11_41_29_+1000_qf5PuksRafMoQ/gn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP1p5JAAoJEECxmPOUX5FEfbQP/1NnH56yep7zsRa1yjUbd9wq
t1hRrg1QumdOIDCWkeIlaikPaPZL/fIHyWBYCA6rdlvooKBbw8bSHtc0oxK7bM5p
xXMhhJJdfxmFiYiyg6NRdcWfkB8c/d6nVeQPj0fB4AXeilwJnLpKJoR4kdYCo/9/
bLZUfLwg1+WfqtSm4ORCM6gq05xBHDT9mOsyIFBtTo4HR9rrb94m++rA6VGcXXEk
SzP/zSpjvYq2GPhTQq7qkCWbh3BF5Qx3NraOafMLkOxWqGh5tyMToryeoKxVbQuE
ckNhnDFO0Z8XprahwiIYmmj31XR6mGcnWLcxZWBzGe/cTxLMatssFpk9uGDDcO2O
g+zmv9cyiWMXpcgbUG+ZSudeZd5OHUO1mgOoVcKHF8ygC+S/DzBYm9/hea0mnQK/
Klfn6Fx+RtIhTYfbiPB7aZXEYj3IimTttk7f64k4Xljf8OqeTgidlu6FkMocAaLr
vVLJhVX0jvAaFL3unrCx2AUVZmxsDxCLomBYqN09jRxh8WIf+n+2m4PXvQpSDAbf
IWtbbfcKDwT7rxDBOKIAdOxJJSTvS1kuDYLoRZHt9hOD1WbVrrIQ2BgJ3SrRICXG
73eXojggjE1mX0+URbCEOGiLgjxv7CRLpXK903d3xS3SKygBcysz/pGzbPbvINGd
wNdzhW9YbELG5zKsZrZ2
=E7zU
-----END PGP SIGNATURE-----

--Signature=_Tue__12_Jun_2012_11_41_29_+1000_qf5PuksRafMoQ/gn--
