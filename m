From: Andrey Borzenkov <arvidjaar@mail.ru>
Subject: Re: [2.6.25-rc2] e100: Trying to free already-free IRQ 11 during suspend ...
Date: Mon, 18 Feb 2008 21:01:58 +0300
Message-ID: <200802182101.59705.arvidjaar@mail.ru>
References: <200802171536.51695.arvidjaar@mail.ru> <20080218050113.1b4b0897.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1973545.oUyVvA2uOI";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx33.mail.ru ([194.67.23.194]:14491 "EHLO mx33.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309AbYBRSCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 13:02:06 -0500
In-Reply-To: <20080218050113.1b4b0897.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1973545.oUyVvA2uOI
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 18 February 2008, Andrew Morton wrote:
> On Sun, 17 Feb 2008 15:36:50 +0300 Andrey Borzenkov <arvidjaar@mail.ru> w=
rote:
>=20
> > ... and possibly reboot/poweroff (it flows by too fast to be legible).
> >=20
> > [ 8803.850634] ACPI: Preparing to enter system sleep state S3
> > [ 8803.853141] Suspending console(s)
> > [ 8805.287505] serial 00:09: disabled
> > [ 8805.291564] Trying to free already-free IRQ 11
> > [ 8805.291579] Pid: 6920, comm: pm-suspend Not tainted 2.6.25-rc2-1avb =
#2
> > [ 8805.291628]  [<c0152127>] free_irq+0xb7/0x130
> > [ 8805.291675]  [<c024bd80>] e100_suspend+0xc0/0x100
> > [ 8805.291724]  [<c01eaa36>] pci_device_suspend+0x26/0x70
> > [ 8805.291747]  [<c0243674>] suspend_device+0x94/0xd0
> > [ 8805.291763]  [<c02439a3>] device_suspend+0x153/0x240
> > [ 8805.291784]  [<c014314f>] suspend_devices_and_enter+0x4f/0xf0
> > [ 8805.291808]  [<c0143a5f>] ? freeze_processes+0x3f/0x80
> > [ 8805.291825]  [<c01432fa>] enter_state+0xaa/0x140
> > [ 8805.291840]  [<c014341f>] state_store+0x8f/0xd0
> > [ 8805.291852]  [<c0143390>] ? state_store+0x0/0xd0
> > [ 8805.291866]  [<c01d3404>] kobj_attr_store+0x24/0x30
> > [ 8805.291901]  [<c01b547b>] sysfs_write_file+0xbb/0x110
> > [ 8805.291936]  [<c0177d79>] vfs_write+0x99/0x130
> > [ 8805.291963]  [<c01b53c0>] ? sysfs_write_file+0x0/0x110
> > [ 8805.291979]  [<c01782fd>] sys_write+0x3d/0x70
> > [ 8805.291998]  [<c010409a>] sysenter_past_esp+0x5f/0xa5
> > [ 8805.292038]  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D
> > [ 8805.347640] ACPI: PCI interrupt for device 0000:00:06.0 disabled
> > [ 8805.361128] ACPI: PCI interrupt for device 0000:00:02.0 disabled
> > [ 8805.376670]  hwsleep-0322 [00] enter_sleep_state     : Entering slee=
p state [S3]
> > [ 8805.376670] Back to C!
> >=20
> > Interface is unused normally (only for netconsole sometimes). dmesg and=
 config
> > attached.
>=20
> Does reverting this:
>=20
> commit 8543da6672b0994921f014f2250e27ae81645580
[...]
> fix it?
>=20

no

> > Hmm ... after resume device has disappeared at all ...
> >=20
> > {pts/1}% cat /proc/interrupts
> >            CPU0
> >   0:    1290492    XT-PIC-XT        timer
> >   1:       6675    XT-PIC-XT        i8042
> >   2:          0    XT-PIC-XT        cascade
> >   3:          2    XT-PIC-XT
> >   4:          2    XT-PIC-XT
> >   5:          3    XT-PIC-XT
> >   7:          4    XT-PIC-XT        irda0
> >   8:          0    XT-PIC-XT        rtc0
> >   9:        583    XT-PIC-XT        acpi
> >  10:          2    XT-PIC-XT
> >  11:      31483    XT-PIC-XT        yenta, yenta, yenta, ohci_hcd:usb1,=
 ALI 5451, pcmcia0.0
> >  12:      28070    XT-PIC-XT        i8042
> >  14:      21705    XT-PIC-XT        ide0
> >  15:      82123    XT-PIC-XT        ide1
> > NMI:          0   Non-maskable interrupts
> > TRM:          0   Thermal event interrupts
> > SPU:          0   Spurious interrupts
> > ERR:          0
>=20
> I hope that's not a separate bug...
>=20
>=20

this is red herring. pm-utils restart network across suspend; eth0 is not
activated automatically so it "disappears". ifconfig eth0 up brings it back.

--nextPart1973545.oUyVvA2uOI
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (GNU/Linux)

iEYEABECAAYFAke5yBcACgkQR6LMutpd94yuWgCfa9XwZ6kzfhOvO+qG8RKv1/k4
L9YAn29xdaVUe7mG/L/0pZNgrVREV874
=MvjR
-----END PGP SIGNATURE-----

--nextPart1973545.oUyVvA2uOI--
