From: "Mody, Rasesh" <Rasesh.Mody@cavium.com>
Subject: RE: [PATCH] scsi: bfa: Increase requested firmware version to 3.2.5.1
Date: Sat, 24 Dec 2016 00:15:01 +0000
Message-ID: <BLUPR0701MB15724638DA0BB8FB5CB9B3CF9F940@BLUPR0701MB1572.namprd07.prod.outlook.com>
References: <20161223220128.1226-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Tim Ehlers <tehlers@gwdg.de>, Rasesh Mody <rasesh.mody@qlogic.com>,
        "Anil Gurumurthy" <anil.gurumurthy@qlogic.com>,
        Sudarsana Kalluru <sudarsana.kalluru@qlogic.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Benjamin Poirier <bpoirier@suse.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0045.outbound.protection.outlook.com ([104.47.40.45]:5572
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751572AbcLXAPE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Dec 2016 19:15:04 -0500
In-Reply-To: <20161223220128.1226-1-bpoirier@suse.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Benjamin Poirier [mailto:benjamin.poirier@gmail.com] On Behalf Of
> Benjamin Poirier
> Sent: Friday, December 23, 2016 2:01 PM
>=20
> bna & bfa firmware version 3.2.5.1 was submitted to linux-firmware on Tue
> Feb 17 19:10:20 2015 -0500 in 0ab54ff1dc ("linux-firmware: Add QLogic BR
> Series Adapter Firmware").
>=20
> bna was updated to use the newer firmware on Thu, 19 Feb 2015 16:02:32
> -0500 in 3f307c3d70 ("bna: Update the Driver and Firmware Version")
>=20
> bfa was not updated. I presume this was an oversight but it broke support
> for bfa+bna cards such as the following
> 	04:00.0 Fibre Channel [0c04]: Brocade Communications Systems, Inc.
> 		1010/1020/1007/1741 10Gbps CNA [1657:0014] (rev 01)
> 	04:00.1 Fibre Channel [0c04]: Brocade Communications Systems, Inc.
> 		1010/1020/1007/1741 10Gbps CNA [1657:0014] (rev 01)
> 	04:00.2 Ethernet controller [0200]: Brocade Communications
> Systems,
> 		Inc. 1010/1020/1007/1741 10Gbps CNA [1657:0014] (rev 01)
> 	04:00.3 Ethernet controller [0200]: Brocade Communications
> Systems,
> 		Inc. 1010/1020/1007/1741 10Gbps CNA [1657:0014] (rev 01)
>=20
> Currently, if the bfa module is loaded first, bna fails to probe the resp=
ective
> devices with [  215.026787] bna: QLogic BR-series 10G Ethernet driver -
> version: 3.2.25.1 [  215.043707] bna 0000:04:00.2: bar0 mapped to
> ffffc90001fc0000, len 262144 [  215.060656] bna 0000:04:00.2: initializat=
ion
> failed err=3D1 [  215.073893] bna 0000:04:00.3: bar0 mapped to
> ffffc90002040000, len 262144 [  215.090644] bna 0000:04:00.3: initializat=
ion
> failed err=3D1
>=20
> Whereas if bna is loaded first, bfa fails with [  249.592109] QLogic BR-s=
eries
> BFA FC/FCOE SCSI driver - version: 3.2.25.0 [  249.610738] bfa 0000:04:00=
.0:
> Running firmware version is incompatible with the driver version [
> 249.833513] bfa 0000:04:00.0: bfa init failed [  249.833919] scsi host6: =
QLogic
> BR-series FC/FCOE Adapter, hwpath: 0000:04:00.0 driver: 3.2.25.0 [
> 249.841446] bfa 0000:04:00.1: Running firmware version is incompatible wi=
th
> the driver version [  250.045449] bfa 0000:04:00.1: bfa init failed [  25=
0.045962]
> scsi host7: QLogic BR-series FC/FCOE Adapter, hwpath: 0000:04:00.1 driver=
:
> 3.2.25.0
>=20
> Increase bfa's requested firmware version.
> I only tested that all of the devices probe without error.
>=20
> Cc: Rasesh Mody <rasesh.mody@qlogic.com>
> Reported-by: Tim Ehlers <tehlers@gwdg.de>
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

Acked-by: Rasesh Mody <rasesh.mody@cavium.com>=20

Thanks! We also need to bump up the BFA driver version to 3.2.25.1.

> ---
>  drivers/scsi/bfa/bfad.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/scsi/bfa/bfad.c b/drivers/scsi/bfa/bfad.c index
> 9d253cb..e70410b 100644
> --- a/drivers/scsi/bfa/bfad.c
> +++ b/drivers/scsi/bfa/bfad.c
> @@ -64,9 +64,9 @@ int		max_rport_logins =3D
> BFA_FCS_MAX_RPORT_LOGINS;
>  u32	bfi_image_cb_size, bfi_image_ct_size, bfi_image_ct2_size;
>  u32	*bfi_image_cb, *bfi_image_ct, *bfi_image_ct2;
>=20
> -#define BFAD_FW_FILE_CB		"cbfw-3.2.3.0.bin"
> -#define BFAD_FW_FILE_CT		"ctfw-3.2.3.0.bin"
> -#define BFAD_FW_FILE_CT2	"ct2fw-3.2.3.0.bin"
> +#define BFAD_FW_FILE_CB		"cbfw-3.2.5.1.bin"
> +#define BFAD_FW_FILE_CT		"ctfw-3.2.5.1.bin"
> +#define BFAD_FW_FILE_CT2	"ct2fw-3.2.5.1.bin"
>=20
>  static u32 *bfad_load_fwimg(struct pci_dev *pdev);  static void
> bfad_free_fwimg(void);
> --
> 2.10.2
