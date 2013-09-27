From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Fri, 27 Sep 2013 13:03:13 +1000
Message-ID: <20130927130313.4e925fa7a760acfc3bf890e1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__27_Sep_2013_13_03_13_+1000_aMkG73iMLFohWM2_"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__27_Sep_2013_13_03_13_+1000_aMkG73iMLFohWM2_
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h between commit
db4efbbeb457 ("brcmfmac: obtain platform data upon module
initialization") from the wireless tree and commit 9bd91f3c00bd
("brcm80211: Remove extern from function prototypes") from the net-next
tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
index 74156f8,5bc0276..0000000
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
@@@ -132,35 -132,33 +132,34 @@@ struct pktq *brcmf_bus_gettxq(struct br
   * interface functions from common layer
   */
 =20
- extern bool brcmf_c_prec_enq(struct device *dev, struct pktq *q,
- 			 struct sk_buff *pkt, int prec);
+ bool brcmf_c_prec_enq(struct device *dev, struct pktq *q, struct sk_buff =
*pkt,
+ 		      int prec);
 =20
  /* Receive frame for delivery to OS.  Callee disposes of rxp. */
- extern void brcmf_rx_frames(struct device *dev, struct sk_buff_head *rxli=
st);
+ void brcmf_rx_frames(struct device *dev, struct sk_buff_head *rxlist);
 =20
  /* Indication from bus module regarding presence/insertion of dongle. */
- extern int brcmf_attach(uint bus_hdrlen, struct device *dev);
+ int brcmf_attach(uint bus_hdrlen, struct device *dev);
  /* Indication from bus module regarding removal/absence of dongle */
- extern void brcmf_detach(struct device *dev);
+ void brcmf_detach(struct device *dev);
  /* Indication from bus module that dongle should be reset */
- extern void brcmf_dev_reset(struct device *dev);
+ void brcmf_dev_reset(struct device *dev);
  /* Indication from bus module to change flow-control state */
- extern void brcmf_txflowblock(struct device *dev, bool state);
+ void brcmf_txflowblock(struct device *dev, bool state);
 =20
  /* Notify the bus has transferred the tx packet to firmware */
- extern void brcmf_txcomplete(struct device *dev, struct sk_buff *txp,
- 			     bool success);
+ void brcmf_txcomplete(struct device *dev, struct sk_buff *txp, bool succe=
ss);
 =20
- extern int brcmf_bus_start(struct device *dev);
+ int brcmf_bus_start(struct device *dev);
 =20
  #ifdef CONFIG_BRCMFMAC_SDIO
- extern void brcmf_sdio_exit(void);
- extern void brcmf_sdio_init(void);
- extern void brcmf_sdio_register(void);
+ void brcmf_sdio_exit(void);
+ void brcmf_sdio_init(void);
++void brcmf_sdio_register(void);
  #endif
  #ifdef CONFIG_BRCMFMAC_USB
- extern void brcmf_usb_exit(void);
- extern void brcmf_usb_register(void);
+ void brcmf_usb_exit(void);
 -void brcmf_usb_init(void);
++void brcmf_usb_register(void);
  #endif
 =20
  #endif				/* _BRCMF_BUS_H_ */

--Signature=_Fri__27_Sep_2013_13_03_13_+1000_aMkG73iMLFohWM2_
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.21 (GNU/Linux)

iQIcBAEBCAAGBQJSRPV1AAoJEMDTa8Ir7ZwVGBEP/3KCIGh5pgG9yOhGVqxsZmJv
yczsq+vGDoiuzgxjSMRoTpuq76s1WxWfLlS//lmJffch6RwmrhO1dcgqGDPDDfyy
kNyR/TbGblVHg2Adu8+dkIkJMYWgx+VDgrvc+h31hNaYsma14V4qbe1le9qzWqqy
ciYiTUOUNjRsXBnulRe1S+D1/CCAvoiDjdPM4VPm56Pv+NFUc8Tjy455BWM8wuhu
dNczWws4E4JNCVibqUK//DHj+EK88AMNOQG/+bGg/+rm56Fyx14YxJuryTrCgy8C
fxZzg0DPUnbu54dxFndDDj6qm9ezQWLYEdPtrTwblhbBQdBykaxLTjmkLwlGDxD4
jmyEl1nJ1ExgMq14CuCZ5KcnuVuAzIuAPIxNmn1b48ryC07wrhC6qMxQ2kvg3Yx+
d610JoaLDX8Sd1307HuQJmKOdOFgzmW+VsH6aOwPmmIOIyL1loYCM51S+80OdjKG
u0jQq/o/SN3WHQ5oETIhRV0Z4AH3x1aejknH36CTVD2QuVcYmFxcF6mGpoX9dXT+
nfVdeo5pRC5sN/mR7aEkyC265PLPQCYHFv2sDH1xwizQTC618S64/14o3sZ2wwp7
layotLn9q3dFy/O0l45F4XRohCE95IzxBEyTRkt8caLoYcqiAqELLS8or7UBeb9i
UvwJeGGT9qPxEo8Lh6z/
=DHkv
-----END PGP SIGNATURE-----

--Signature=_Fri__27_Sep_2013_13_03_13_+1000_aMkG73iMLFohWM2_--
