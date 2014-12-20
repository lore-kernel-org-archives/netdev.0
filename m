From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH] igb in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 02:35:09 -0800
Message-ID: <1419071709.2461.86.camel@jtkirshe-mobl.home>
References: <001101d01c2c$8dcc0040$a96400c0$@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vqw8aTRB6isLWCjrJcFx"
Cc: todd.fujinaka@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, linux.nics@intel.com
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:25155 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751040AbaLTKfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 05:35:10 -0500
In-Reply-To: <001101d01c2c$8dcc0040$a96400c0$@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vqw8aTRB6isLWCjrJcFx
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-12-20 at 16:11 +0800, Jia-Ju Bai wrote:
> I have actually tested igb driver on the real hardware(Intel 82575EB
> PCI-E
> Gigabit Ethernet Controller), and find some potential bugs:
> The target file is drivers/net/ethernet/intel/igb/igb_main.c
>=20
> (1) In the normal process of igb, pci_enable_pcie_error_reporting and
> pci_disable_pcie_error_reporting is called in pairs in igb_probe and
> igb_remove. However, when pci_enable_pcie_error_reporting has been
> called
> and alloc_etherdev_mqs in igb_probe is failed, "err_alloc_etherdev"
> segment
> in igb_probe is executed immediately to exit, but
> pci_disable_pcie_error_reporting is not called.
> (2) The same situation happens when pci_iomap in igb_probe is failed.
> (3) The same situation happens when igb_sw_init in igb_probe is
> failed.
> (4) The same situation happens when register_netdev in igb_probe is
> failed.
> (5) The same situation happens when igb_init_i2c in igb_probe is
> failed.
>=20
> (6) The function kcalloc is called by igb_sw_init when initializing
> the
> ethernet card driver, but kfree is not called when register_netdev in
> igb_probe is failed, which may cause memory leak.
> (7) The same situation happens when igb_init_i2c in igb_probe is
> failed.
> (8) The same situation happens when kzalloc in igb_alloc_q_vector is
> failed.
> (9) The same situation happens when igb_alloc_q_vector in
> igb_alloc_q_vectors is failed.
>=20
> (10) When igb_init_i2c in igb_probe is failed, igb_enable_sriov is
> called in
> igb_probe_vfs, but igb_disable_sriov is not called.
> (11) The same situation with [10] happens when register_netdev in
> igb_probe
> is failed.
>=20
> Meanwhile, I also write the patch to fix the bugs. I have run the
> patch on
> the hardware, it can work normally and fix the above bugs.

Was this a bug you actually saw?  Or a theoretical bug based on code
review?

I do not mind adding this to my queue so that we can review and test the
patch, although this will cause a fair amount of regression testing.

--=-vqw8aTRB6isLWCjrJcFx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUlVDdAAoJEOVv75VaS+3OIDsP/isjILlt1HrU+wL2laOMaJA+
e67NDYwoN2po/dtHxzNoz82uJa6Qg8eR/yMfvBPns5NY9dilPa+scgp7FQ/oyD2N
FU+wrl6Bah5cGbJqPNA6xFffoUi6ZyaWaLu+/axvOvH0T5ptO6MPlz2T8xkuU1ML
qIMQKkwNsq/xfSm4eUZmoR2m5X+4lAUjDqvuYXznqIc5M9DT1WRSjRFZkBpIJiUM
ziXVYN7qVAXxckREgodQEB5uayNYh9SC6Ns38TojofHl7OV+plqxwWPQUgaY0ErX
xLp4pWRSeWHR4YHeO7AeUTe6+SR6/Dau42fZISBm0MuILG8lzBggAc+mrfeM8J/w
OnqVMA+D26XtTL4NBJ600DXx96ALDHodFOivgkBFZ/0iEIbQugBTqht7VsddEnZu
QhWVU6GCuALZRacpeBOBboNlYdQdc4z0ZzGASFfLePydYChEaJBZDQOTLuGPcZQ8
WxJT1WiYgH/ugPWZv1LxHe+KSZyRlw74hG8yMV+mxDfl0QKR6aT4UMG2i6oA2m8C
iwMoA+4Y93ugZJ30icNgh+lo7D/VHkiRHgjHt63t+UK4wEtbhxQNez25CdpbD7Ib
HqaqOBhI8mKoteSq+YFpsXqObEcNG6hbq+ZltCMLdxrLqs89xeyBl9zuTJtj3/Ez
WF0+4V2J9lKY8c5uXyP/
=q3Nk
-----END PGP SIGNATURE-----

--=-vqw8aTRB6isLWCjrJcFx--
