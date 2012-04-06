From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: Expose ltr/obff interface by sysfs
Date: Fri, 6 Apr 2012 08:26:49 -0700
Message-ID: <20120406082649.68fe5842@jbarnes-desktop>
References: <403610A45A2B5242BD291EDAE8B37D300FD0A434@SHSMSX102.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/cX21.LD6aPtp7oavFH0w6Wh"; protocol="application/pgp-signature"
Cc: "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Hao, Xudong" <xudong.hao@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <403610A45A2B5242BD291EDAE8B37D300FD0A434@SHSMSX102.ccr.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/cX21.LD6aPtp7oavFH0w6Wh
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 6 Apr 2012 02:43:59 +0000
"Hao, Xudong" <xudong.hao@intel.com> wrote:

> Hi,=20
>=20
> I'm working on virtualization Xen/KVM. I saw there are ltr/obff enabling/=
disabling function in pci.c, but no called till now. I want to know if anyb=
ody(driver developer) are working for using it? Can driver change the LTR l=
atency value dynamically?

I believe the value is writable, but I'd expect some devices to
misbehave if the value were programmed too high.  Performance would
also suffer if the value were set too high, at least for IOPS sensitive
devices.

> /*
> LTR(Latency tolerance reporting) allows devices to send messages to the r=
oot complex indicating their latency tolerance for snooped & unsnooped memo=
ry transactions.
> OBFF (optimized buffer flush/fill), where supported, can help improve ene=
rgy efficiency by giving devices information about when interrupts and othe=
r activity will have a reduced power impact.
> */
>=20
> One way to control ltr/obff is used by driver, however, I'm considering t=
hat in virtualization, how guest OS driver control them. I have an idea tha=
t expose an inode interface by sysfs, like "reset" inode implemented in pci=
-sysfs.c, so that system user/administrator can enable/disable ltr/obff or =
set latency value on userspace, but not limited on driver. Comments?

Given how device specific these extensions are, I'd expect you'd need
to know about each specific device anyway, which is why I think the
control belongs in the driver.  I don't see why you'd need to
enable/disable/change these functions when assigning a device from one
guest to another...

--=20
Jesse Barnes, Intel Open Source Technology Center

--Sig_/cX21.LD6aPtp7oavFH0w6Wh
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPfws5AAoJEIEoDkX4Qk9h2SsQAJPizYQ7eIoEaMJzEVzF+owp
juoNC/Aat9JbD03GGPBmpQd6c1NT1C9SHTC8SdKRt3dGslxWuiuMMBvg3N9K0fhJ
dkj2nY7mE9hAUp/YDOKN0lev8OkigCbrOIkAKxEFGVmUXxy9vpiJyS5X0n6GQjeC
wq/m2tnFpllFBS4afgPeY1Ioi5S9Q/SBUD+vOXFGutK8q5wHJsbWlRm1w/S2Fq1Z
AojBwBkZS13IBtgsw4p+6o5FgvNhGbWwuuqzs1kVQmBxaWmXyZaVS1uVIFKfffCF
wwdkzWZulLI0REcJpeh7/RCssToNotOWPKwt1o4kiTUZwSnihRoBUsRJgimGAvJd
fexUoY4rOFBEqcKlvznfpoLZmex2wWvhHDXNeYhVEgggkqluolf26QG5VhLuTb54
wFShoyxFF/fPcyi1FGpAZCBnO3floOwhBquP1MJYXJzM0E2r7Vk/dF1o7PTWdzdr
YEShZSxd0WCc2gWbmXe7PYv7p59TaTY+cK+zzCNx90g0dF8GPe6tWwwPxpPTu/Pf
yyzm+SdbjKhoTaXtx6w31dpEPlACBwLRugxcpgJPdq2M2Ljshk0oDJC1YjtGA//J
JPWUPxtqeYe7aih3UbsvLtqONWLsh2kF4ah8CM0/k7nV5n/xDeVWuOtMZbZdmLH5
QKk0dy3MbioqWJoy8Snd
=F86i
-----END PGP SIGNATURE-----

--Sig_/cX21.LD6aPtp7oavFH0w6Wh--
