From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] stmmac: fix comments, make debug output consistent
Date: Mon, 28 Nov 2016 12:55:59 +0100
Message-ID: <20161128115559.GB15034@amd>
References: <20161123105125.GA26394@amd>
 <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Bn2rw/3z4jIqBvZU"
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>
To: David Miller <davem@davemloft.net>, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124.110416.198867271899443489.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Bn2rw/3z4jIqBvZU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Fix comments, add some new, and make debugfs output consistent.
   =20
Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/eth=
ernet/stmicro/stmmac/common.h
index a61de04..6074d97 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -44,6 +44,7 @@
 #define	DWMAC_CORE_4_00	0x40
 #define STMMAC_CHAN0	0	/* Always supported and default for all chips */
=20
+/* These need to be power of two, and >=3D 4 */
 #define DMA_TX_SIZE 512
 #define DMA_RX_SIZE 512
 #define STMMAC_GET_ENTRY(x, size)	((x + 1) & (size - 1))
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index 9dfdbe0..f7133d0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -108,8 +108,8 @@ module_param(eee_timer, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(eee_timer, "LPI tx expiration time in msec");
 #define STMMAC_LPI_T(x) (jiffies + msecs_to_jiffies(x))
=20
-/* By default the driver will use the ring mode to manage tx and rx descri=
ptors
- * but passing this value so user can force to use the chain instead of th=
e ring
+/* By default the driver will use the ring mode to manage tx and rx descri=
ptors,
+ * but allow user to force to use the chain instead of the ring
  */
 static unsigned int chain_mode;
 module_param(chain_mode, int, S_IRUGO);
@@ -2966,6 +2966,8 @@ static int stmmac_sysfs_ring_open(struct inode *inode=
, struct file *file)
 	return single_open(file, stmmac_sysfs_ring_read, inode->i_private);
 }
=20
+/* Debugfs files, should appear in /sys/kernel/debug/stmmaceth/eth0 */
+
 static const struct file_operations stmmac_rings_status_fops =3D {
 	.owner =3D THIS_MODULE,
 	.open =3D stmmac_sysfs_ring_open,
@@ -2988,11 +2990,11 @@ static int stmmac_sysfs_dma_cap_read(struct seq_fil=
e *seq, void *v)
 	seq_printf(seq, "\tDMA HW features\n");
 	seq_printf(seq, "=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D\n");
=20
-	seq_printf(seq, "\t10/100 Mbps %s\n",
+	seq_printf(seq, "\t10/100 Mbps: %s\n",
 		   (priv->dma_cap.mbps_10_100) ? "Y" : "N");
-	seq_printf(seq, "\t1000 Mbps %s\n",
+	seq_printf(seq, "\t1000 Mbps: %s\n",
 		   (priv->dma_cap.mbps_1000) ? "Y" : "N");
-	seq_printf(seq, "\tHalf duple %s\n",
+	seq_printf(seq, "\tHalf duplex: %s\n",
 		   (priv->dma_cap.half_duplex) ? "Y" : "N");
 	seq_printf(seq, "\tHash Filter: %s\n",
 		   (priv->dma_cap.hash_filter) ? "Y" : "N");
@@ -3010,9 +3012,9 @@ static int stmmac_sysfs_dma_cap_read(struct seq_file =
*seq, void *v)
 		   (priv->dma_cap.rmon) ? "Y" : "N");
 	seq_printf(seq, "\tIEEE 1588-2002 Time Stamp: %s\n",
 		   (priv->dma_cap.time_stamp) ? "Y" : "N");
-	seq_printf(seq, "\tIEEE 1588-2008 Advanced Time Stamp:%s\n",
+	seq_printf(seq, "\tIEEE 1588-2008 Advanced Time Stamp: %s\n",
 		   (priv->dma_cap.atime_stamp) ? "Y" : "N");
-	seq_printf(seq, "\t802.3az - Energy-Efficient Ethernet (EEE) %s\n",
+	seq_printf(seq, "\t802.3az - Energy-Efficient Ethernet (EEE): %s\n",
 		   (priv->dma_cap.eee) ? "Y" : "N");
 	seq_printf(seq, "\tAV features: %s\n", (priv->dma_cap.av) ? "Y" : "N");
 	seq_printf(seq, "\tChecksum Offload in TX: %s\n",

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--Bn2rw/3z4jIqBvZU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg8G08ACgkQMOfwapXb+vLMHQCbBqmcR+H4LHtNZMJ6KLnrsjl1
J5UAmwYKQdiP2+0oliDpA198OtReqNdf
=XMLB
-----END PGP SIGNATURE-----

--Bn2rw/3z4jIqBvZU--
