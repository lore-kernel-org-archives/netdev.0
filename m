From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH net] PCI: fix the return value for the
 pci_find_pcie_root_port()
Date: Thu, 17 Aug 2017 12:51:56 +0200
Message-ID: <20170817105156.GA18789@ulmo>
References: <1502936730-7368-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="UlVJffcvxoiEqYs2"
Cc: leedom@chelsio.com, ashok.raj@intel.com, bhelgaas@google.com,
        helgaas@kernel.org, werner@chelsio.com, ganeshgr@chelsio.com,
        asit.k.mallick@intel.com, patrick.j.cramer@intel.com,
        Suravee.Suthikulpanit@amd.com, Bob.Shaw@amd.com,
        l.stach@pengutronix.de, amira@mellanox.com,
        gabriele.paoloni@huawei.com, David.Laight@aculab.com,
        jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        davem@davemloft.net, alexander.duyck@gmail.com,
        eric.dumazet@gmail.com, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, linux-pci@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1502936730-7368-1-git-send-email-dingtianhong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 17, 2017 at 10:25:30AM +0800, Ding Tianhong wrote:
> The pci_find_pcie_root_port() would return NULL if the given
> dev is already a Root Port, it looks like unfriendly to the
> PCIe Root Port device, Thierry and Bjorn suggest to let this
> function return the given dev under this circumstances.
>=20
> Fixes: 0e405232871d6 ("PCI: fix oops when try to find Root Port for a PCI=
 device")
> Suggested-by: Thierry Reding <thierry.reding@gmail.com>
> Suggested-by: Bjorn Helgaas <helgaas@kernel.org>
> Signed-off-by: Thierry Reding <thierry.reding@gmail.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>  drivers/pci/pci.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index 7e2022f..352bb53 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -514,7 +514,7 @@ struct resource *pci_find_resource(struct pci_dev *de=
v, struct resource *res)
>   */
>  struct pci_dev *pci_find_pcie_root_port(struct pci_dev *dev)
>  {
> -	struct pci_dev *bridge, *highest_pcie_bridge =3D NULL;
> +	struct pci_dev *bridge, *highest_pcie_bridge =3D dev;
> =20
>  	bridge =3D pci_upstream_bridge(dev);
>  	while (bridge && pci_is_pcie(bridge)) {

I think this should actually be this change on top of a revert of commit
0e405232871d6 ("PCI: fix oops when try to find Root Port for a PCI
device"). After the above change, the previous fix will have a redundant
check because highest_pcie_bridge will never be NULL.

Let me send out that version to clarify what I mean.

Thierry

--UlVJffcvxoiEqYs2
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAlmVdUoACgkQ3SOs138+
s6E9yBAAuGzNpKAheXSFZJM8f85OuPmQVY8Sml5KRjrwr8v7uMfpYoZiv+lsOzGL
LWBJO098ISl5jQ8wV0pLJ0UUtlN7BLuW0NhQynA+y8mSsZtoo/dmXG1NRcdw6GSk
Y1x/cReStuVaOEjgp6t2w1KVkWO04SRRnYqFPyhIc9JZONnNesZeuH/gGBXROhDT
zLT7zZGQW4m/7m6IQobpqEczZZ7/M4fd1gW0R6cN2AtpeeqlEwz5iSeBB3U9Y2ow
awzCIEVVFtKe27w0N/MKQvCXbax35S9XtwuxZzxijuLzaB8JCwwqgyzB/jyn8cHw
jgMKTYZ4aRImX8ktMk9oKXegJB3CuFHigvIKjiNEFDgIEvPAT1FMbgMuxSc5EKwn
DMBjq89LuebM10l001mrodyF/laNm5TC2UB7G+cFrwfBp99hviK3NyizlvJidr/d
QaEn/eBhWFVryVNaBexSdoX9b8if0lm3gUWxjLhgh3Vfc8NoRqQPZHGMJWyPa3Ha
tb7npzymmtWjv0xyO0vHPZ4m9djEOC4vlzszNJsR3KbCS7k0DqwawjZduzue9xS1
BUCDqrydKHRJi1PupX9TxF8L4vtm2r1CS59PMovsNip87vR/0RQyVYEVmlCASfTY
Q20sd9tBBSaUbU0sCgeg/xZ0heabJjdQzrx6LXuLc6hMA51UWqQ=
=B6wU
-----END PGP SIGNATURE-----

--UlVJffcvxoiEqYs2--
