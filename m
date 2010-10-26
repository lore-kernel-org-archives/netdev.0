From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH net-next-2.6 1/2] be2net: Adding an option to use INTx
 instead of MSI-X
Date: Tue, 26 Oct 2010 17:52:08 +1100
Message-ID: <1288075928.6578.185.camel@concordia>
References: <20101025111235.GA2024@emulex.com>
	 <20101025.120943.189699949.davem@davemloft.net>
	 <20101025223853.GD15074@solarflare.com>
	 <20101025.162535.226782713.davem@davemloft.net>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-NrA7c9r2ghiymiU5wGec"
Cc: bhutchings@solarflare.com, somnath.kotur@emulex.com,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20101025.162535.226782713.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-NrA7c9r2ghiymiU5wGec
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2010-10-25 at 16:25 -0700, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Mon, 25 Oct 2010 23:38:53 +0100
>=20
> > David Miller wrote:
> >> From: Somnath Kotur <somnath.kotur@emulex.com>
> >> Date: Mon, 25 Oct 2010 16:42:35 +0530
> >>=20
> >> > By default, be2net uses MSIx wherever possible.
> >> > Adding a module parameter to use INTx for users who do not want to u=
se MSIx.
> >> >=20
> >> > Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> >>=20
> >> Either add a new ethtool flag, or use the PCI subsystem facilities
> >> for tweaking things to implement this.
> >>
> >> Do not use a module option, otherwise every other networking driver
> >> author will get the same "cool" idea, give the module option
> >> different names, and the resulting user experience is terrible.
> >=20
> > This has already happened, sadly.  So far as I can see it's mostly done
> > to allow users to work around systems with broken MSIs; I'm not aware o=
f
> > any other reason to prefer legacy interrupts.  However, the PCI subsyst=
em
> > already implements a blacklist and a kernel parameter for disabling MSI=
s
> > on these systems.
>=20
> The PCI subsystem bits I'm totally fine with.
>=20
> But in the drivers themselves, that's what I don't want.

That horse has really really bolted, it's gawn.

I count 26 drivers with "disable MSI/X" parameters. Some even have more
than one.

11 of them are network drivers, 9 scsi, 3 ata.

I agree it's a mess for users, but it's probably preferable to a
non-working driver.

Ethtool would be nice, but only for network drivers. Is there a generic
solution, quirks are obviously not keeping people happy.

cheers



MSI:

Param "msi", 10 users:
  drivers/ata/sata_mv.c:MODULE_PARM_DESC(msi, "Enable use of PCI MSI (0=3Do=
ff, 1=3Don)");
  drivers/ata/sata_nv.c:MODULE_PARM_DESC(msi, "Enable use of MSI (Default: =
false)");
  drivers/ata/sata_sil24.c:MODULE_PARM_DESC(msi, "Enable MSI (Default: fals=
e)");
  drivers/net/cxgb3/cxgb3_main.c:MODULE_PARM_DESC(msi, "whether to use MSI =
or MSI-X");
  drivers/net/cxgb4/cxgb4_main.c:MODULE_PARM_DESC(msi, "whether to use INTx=
 (0), MSI (1) or MSI-X (2)");
  drivers/net/cxgb4vf/cxgb4vf_main.c:MODULE_PARM_DESC(msi, "whether to use =
MSI-X or MSI");
  drivers/net/forcedeth.c:MODULE_PARM_DESC(msi, "MSI interrupts are enabled=
 by setting to 1 and disabled by setting to 0.");
  drivers/net/qla3xxx.c:MODULE_PARM_DESC(msi, "Turn on Message Signaled Int=
errupts.");
  drivers/scsi/aacraid/aachba.c:MODULE_PARM_DESC(msi, "IRQ handling."
  drivers/scsi/stex.c:MODULE_PARM_DESC(msi, "Enable Message Signaled Interr=
upts(0=3Doff, 1=3Don)");

Param "use_msi", 4 users:
  drivers/net/qlcnic/qlcnic_main.c:MODULE_PARM_DESC(use_msi, "MSI interrupt=
 (0=3Ddisabled, 1=3Denabled");
  drivers/scsi/3w-9xxx.c:MODULE_PARM_DESC(use_msi, "Use Message Signaled In=
terrupts.  Default: 0");
  drivers/scsi/3w-sas.c:MODULE_PARM_DESC(use_msi, "Use Message Signaled Int=
errupts. Default: 0");
  drivers/scsi/aic94xx/aic94xx_init.c:MODULE_PARM_DESC(use_msi, "\n"

Param "disable_msi", 4 users:
  drivers/scsi/vmw_pvscsi.c:MODULE_PARM_DESC(disable_msi, "Disable MSI use =
in driver - (default=3D0)");
  drivers/net/bnx2.c:MODULE_PARM_DESC(disable_msi, "Disable Message Signale=
d Interrupt (MSI)");
  drivers/net/chelsio/cxgb2.c:MODULE_PARM_DESC(disable_msi, "Disable Messag=
e Signaled Interrupt (MSI)");
  drivers/net/sky2.c:MODULE_PARM_DESC(disable_msi, "Disable Message Signale=
d Interrupt (MSI)");

Misc:
  sound/pci/hda/hda_intel.c:MODULE_PARM_DESC(enable_msi, "Enable Message Si=
gnaled Interrupt (MSI)");
  drivers/message/fusion/mptbase.c:MODULE_PARM_DESC(mpt_msi_enable_spi, " E=
nable MSI Support for SPI \
  drivers/message/fusion/mptbase.c:MODULE_PARM_DESC(mpt_msi_enable_fc, " En=
able MSI Support for FC \
  drivers/message/fusion/mptbase.c:MODULE_PARM_DESC(mpt_msi_enable_sas, " E=
nable MSI Support for SAS \
  drivers/net/myri10ge/myri10ge.c:MODULE_PARM_DESC(myri10ge_msi, "Enable Me=
ssage Signalled Interrupts");


MSI-X:

Param "msi_x", 2 users:
  drivers/infiniband/hw/mthca/mthca_main.c:MODULE_PARM_DESC(msi_x, "attempt=
 to use MSI-X if nonzero");
  drivers/net/mlx4/main.c:MODULE_PARM_DESC(msi_x, "attempt to use MSI-X if =
nonzero");

Misc:
  drivers/net/forcedeth.c:MODULE_PARM_DESC(msix, "MSIX interrupts are enabl=
ed by setting to 1 and disabled by setting to 0.");
  drivers/net/qlcnic/qlcnic_main.c:MODULE_PARM_DESC(use_msi_x, "MSI-X inter=
rupt (0=3Ddisabled, 1=3Denabled");
  drivers/scsi/bfa/bfad_intr.c:MODULE_PARM_DESC(msix_disable_cb, "Disable M=
SIX for Brocade-415/425/815/825"
  drivers/scsi/bfa/bfad_intr.c:MODULE_PARM_DESC(msix_disable_ct, "Disable M=
SIX for Brocade-1010/1020/804"
  drivers/scsi/mpt2sas/mpt2sas_base.c:MODULE_PARM_DESC(msix_disable, " disa=
ble msix routed interrupts (default=3D0)");
  drivers/scsi/qla4xxx/ql4_os.c:MODULE_PARM_DESC(ql4xenablemsix,
  drivers/scsi/vmw_pvscsi.c:MODULE_PARM_DESC(disable_msix, "Disable MSI-X u=
se in driver - (default=3D0)");


--=-NrA7c9r2ghiymiU5wGec
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAkzGepgACgkQdSjSd0sB4dI/zACeMLe0oZm/V45kSfU8VpOWmp5U
zxkAmgLHZ1hmqFHKgQeq5KI4hUBWHSCS
=dP3C
-----END PGP SIGNATURE-----

--=-NrA7c9r2ghiymiU5wGec--
