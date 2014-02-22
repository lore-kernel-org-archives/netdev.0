From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 28/35] qlcnic: Use pci_enable_msix_range()
 instead of pci_enable_msix()
Date: Sat, 22 Feb 2014 00:44:30 +0000
Message-ID: <1393029870.15717.71.camel@deadeye.wl.decadent.org.uk>
References: <cover.1392717502.git.agordeev@redhat.com>
	 <cb8eb41f672c62d1149c375bdaf97ca3328703f9.1392717503.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rPFm1fJUwh5zE557wHjZ"
Cc: linux-kernel@vger.kernel.org,
	Himanshu Madhani <himanshu.madhani@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <cb8eb41f672c62d1149c375bdaf97ca3328703f9.1392717503.git.agordeev@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rPFm1fJUwh5zE557wHjZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-02-18 at 11:11 +0100, Alexander Gordeev wrote:
> As result of deprecation of MSI-X/MSI enablement functions
> pci_enable_msix() and pci_enable_msi_block() all drivers
> using these two interfaces need to be updated to use the
> new pci_enable_msi_range() and pci_enable_msix_range()
> interfaces.
>=20
> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
> Cc: Himanshu Madhani <himanshu.madhani@qlogic.com>
> Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>
> Cc: linux-driver@qlogic.com
> Cc: netdev@vger.kernel.org
> Cc: linux-pci@vger.kernel.org
> ---
>  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/n=
et/ethernet/qlogic/qlcnic/qlcnic_main.c
> index 0c077cf..e07fd94 100644
> --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
> @@ -701,13 +701,17 @@ enable_msix:
>  		for (vector =3D 0; vector < num_msix; vector++)
>  			adapter->msix_entries[vector].entry =3D vector;
> =20
> -		err =3D pci_enable_msix(pdev, adapter->msix_entries, num_msix);
> -		if (err =3D=3D 0) {
> +		err =3D pci_enable_msix_range(pdev,
> +					    adapter->msix_entries, 1, num_msix);
> +
> +		if (err =3D=3D num_msix) {
>  			adapter->flags |=3D QLCNIC_MSIX_ENABLED;
>  			adapter->ahw->num_msix =3D num_msix;
>  			dev_info(&pdev->dev, "using msi-x interrupts\n");
>  			return 0;
>  		} else if (err > 0) {
> +			pci_disable_msix(pdev);
> +
>  			dev_info(&pdev->dev,
>  				 "Unable to allocate %d MSI-X vectors, Available vectors %d\n",
>  				 num_msix, err);

Well this log message is nonsense - we have no idea how many vectors are
available any more.

You should remove this and the retry loop that is no longer needed.

Ben.

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-rPFm1fJUwh5zE557wHjZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwfy7ue/yOyVhhEJAQrPWw/+JBTwM+nrdybdFxO50G34coeMeo8TMDU7
+sKBPYnpuRPKZ5Krs1FgZgRUv2W7yee/WNn5LfMD0VfXdda6kOxOCLLUbLS8q6dB
x1r70zGvmY6oiEpHJH5vZxLdlSpS/n7V/aN3kuFcOAsDftlAVdr4iO4/mnENvKwg
AFW8BcyLQ5r6mxnzNNf7FHcLT1ceZPUTfKEy0Yoc6NfoofTEkvx45kDERFdhd1RB
VfiUmLEq61Q6PVbgFbFaZwBFh8rRN50UXUJONmsyaZI7REv0evgpVHZe5SdE4S9c
Lr1q6oY7PZ7KCZHyI59HC8BgrzhSx9Br3lPLpeX0762fCqBrhfK7vboZhF0aHvwG
dFiPAaqp9MzVHCKt4EHXtUSAQzECXt8xI8NcsstzLn6fML74aRYsPiCWsY5bbQeN
l2JtITKSYAqDHvMMzSxRG4P9ThEhO/dzlvDoV+4F6UFBf3L4An81l3EsNWsCUXhm
OdSnbY6xVYCul9k3gDcb6A8j7rOIxpjnzeDcZonFsu6cJuDkXri7zLQnUD/7xZb4
RpAQk1MbtGHER1akP5xh1BcFMdrFmmE2MV5qiiRbqiFAxiyb3dLKNwh/LKIUCwA6
wcrklIqGnMsbt2jOtBBd8nx3/9ssrCzGhcXUfH4fH+kh4ViH/5oD5JCAzGWURVb6
j/ZR0euJLa4=
=P3P1
-----END PGP SIGNATURE-----

--=-rPFm1fJUwh5zE557wHjZ--
