From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] e1000e: Modify tx/rx configurations to avoid null
 pointer dereferences in e1000_open
Date: Wed, 05 Aug 2015 03:43:49 -0700
Message-ID: <1438771429.3467.28.camel@intel.com>
References: <1438769770-8887-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-eNzQauNk8sCPce2Q2GcO"
Cc: jesse.brandeburg@intel.com, alexander.duyck@gmail.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438769770-8887-1-git-send-email-baijiaju1990@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-eNzQauNk8sCPce2Q2GcO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-08-05 at 18:16 +0800, Jia-Ju Bai wrote:
> When e1000e_setup_rx_resources is failed in e1000_open,
> e1000e_free_tx_resources in "err_setup_rx" segment is executed.
> "writel(0, tx_ring->head)" statement in e1000_clean_tx_ring
> in e1000e_free_tx_resources will cause a null poonter
> dereference(crash),
> because "tx_ring->head" is only assigned in e1000_configure_tx
> in e1000_configure, but it is after e1000e_setup_rx_resources.
>=20
> This patch moves head/tail register writing to e1000_configure_tx/rx,=20
> which can fix this problem. It is inspired by igb_configure_tx_ring=20
> in the igb driver.
>=20
> Specially, thank Alexander Duyck for his valuable suggestion.
>=20
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |   24
> ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)

Is your intention that this patch replace the existing patch:
http://patchwork.ozlabs.org/patch/502990/
...which is currently in my queue?

--=-eNzQauNk8sCPce2Q2GcO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVwejlAAoJEOVv75VaS+3O0hEP/1LvQxKqt2YQHIXhGsszoUuc
mtP9wfswPLQ1P8oONAQgg/vFKmi1jj7+qM8gWCWoH3WQ0ElfLIECVLxQknGAX8e4
rGXVle0txXxqMDPWuWSK2rV96NH+YnLzdDKjpqoody/OMUF+KuK0y4+J+zqr5Hrb
VihfDisez22tTNZcjxatswYBxS5n0y8/3lwDSDxHw/+AiOXP+mSdNU6DsdyNjU/N
JJLC/ZicOc5jbgSR/jO6DcY9M0RQvZtaHrDyuyLCQs9d1AXHrUPzTVRYxya2OuGz
IGrPvLn4G1DwAD2KXpyHafFmmpdIDlcWClwg+GJCC8aS9iJXeoSL2pg+Cw1RCoUr
I44YI/OlYLLwvyfvRqlSQMEa2SroRayXBQaYVkZmW6hcn7z6lhjzUhGvpQFWcsPU
tuMveLeOWqBO2y5pdhy7NfzQiiRc6ilvwLEc8a8rG19fbJZdq6yPVxAY5EFGIJlT
ZMBC1y+EKQCXWVvsLKNBPGMWwi7ASxiu4UPtsYXBVHDT4BdC0WllJn/K1e9H4kBq
2XrNViaRMmxYB0naaMMdWh8+bo8mdkAvL+Gghd/xwmKLKoCjR/QExR2OPvq2ruTa
BkxKF9Z/It/M7tMRTOriqVrkq+TOsTJV5/WQD5rwIl07IbId8iAvbBHg4zqzGupD
zZSIwh8nmSHzeUL0CzYa
=tZWL
-----END PGP SIGNATURE-----

--=-eNzQauNk8sCPce2Q2GcO--
