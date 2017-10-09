From: Mark Brown <broonie@kernel.org>
Subject: linux-next: manual merge of the drivers-x86 tree with the net-next
 tree
Date: Mon, 9 Oct 2017 18:56:33 +0100
Message-ID: <20171009175633.dm7hjmgoxusspue5@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="qoei36hz4ztg5uv6"
Cc: netdev@vger.kernel.org,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Darren Hart <dvhart@infradead.org>,
        Mario Limonciello <mario.limonciello@dell.com>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Michael Jamet <michael.jamet@intel.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qoei36hz4ztg5uv6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Darren,

[Apologies for multiple copies - for some reason vger seems to eat mails
I send from scripts, still trying to figure this out]

Today's linux-next merge of the drivers-x86 tree got a conflict in:

  Documentation/admin-guide/thunderbolt.rst

between commit:

   e69b6c02b4c3b ("net: Add support for networking over Thunderbolt cable")

=66rom the net-next tree and commit:

   ce6a90027c10f ("platform/x86: Add driver to force WMI Thunderbolt contro=
ller power status")

=66rom the drivers-x86 tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

diff --cc Documentation/admin-guide/thunderbolt.rst
index 5c62d11d77e8,dadcd66ee12f..000000000000
--- a/Documentation/admin-guide/thunderbolt.rst
+++ b/Documentation/admin-guide/thunderbolt.rst
@@@ -198,26 -198,17 +198,41 @@@ information is missing
  To recover from this mode, one needs to flash a valid NVM image to the
  host host controller in the same way it is done in the previous chapter.
 =20
 +Networking over Thunderbolt cable
 +---------------------------------
 +Thunderbolt technology allows software communication across two hosts
 +connected by a Thunderbolt cable.
 +
 +It is possible to tunnel any kind of traffic over Thunderbolt link but
 +currently we only support Apple ThunderboltIP protocol.
 +
 +If the other host is running Windows or macOS only thing you need to
 +do is to connect Thunderbolt cable between the two hosts, the
 +``thunderbolt-net`` is loaded automatically. If the other host is also
 +Linux you should load ``thunderbolt-net`` manually on one host (it does
 +not matter which one)::
 +
 +  # modprobe thunderbolt-net
 +
 +This triggers module load on the other host automatically. If the driver
 +is built-in to the kernel image, there is no need to do anything.
 +
 +The driver will create one virtual ethernet interface per Thunderbolt
 +port which are named like ``thunderbolt0`` and so on. From this point
 +you can either use standard userspace tools like ``ifconfig`` to
 +configure the interface or let your GUI to handle it automatically.
++
+ Forcing power
+ -------------
+ Many OEMs include a method that can be used to force the power of a
+ thunderbolt controller to an "On" state even if nothing is connected.
+ If supported by your machine this will be exposed by the WMI bus with
+ a sysfs attribute called "force_power".
+=20
+ For example the intel-wmi-thunderbolt driver exposes this attribute in:
+   /sys/devices/platform/PNP0C14:00/wmi_bus/wmi_bus-PNP0C14:00/86CCFD48-20=
5E-4A77-9C48-2021CBEDE341/force_power
+=20
+   To force the power to on, write 1 to this attribute file.
+   To disable force power, write 0 to this attribute file.
+=20
+ Note: it's currently not possible to query the force power state of a pla=
tform.

--qoei36hz4ztg5uv6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlnbuFAACgkQJNaLcl1U
h9DIJgf/WYosj3cFcB5RpP4hHm1WbEfst/2x8VrmbI8G/pAIrmvaZ9iHZi4Cr3GP
sQN0x6NKihdDbb5mkcXl0/6cGwZgxI7UqmqQYI6exyTey8he2xbcDrJwMCqaQJbS
RepJ3aFQq49AUPp5umh2uwZLkxPEVdj+2OFlyfIJeOpJwvSfKwpKiy/aEqCiftAB
D+D0KaQzAUAzbb4dv8w/5hxBPZqojXF43HvVF8GsRnXiFG+sLa1xc7h+SLcAoL4r
l6e6J3ULCLT7B272mAyCWcsOol/Ygs7u7XnOuR6jxJADISH0elvMuah1unpwiSBz
kgrd+fAPgJ20PN+F8PBtAUqqUoBVyg==
=IHAN
-----END PGP SIGNATURE-----

--qoei36hz4ztg5uv6--
