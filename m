From: Bryan Kadzban <bryan@kadzban.is-a-geek.net>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 19 Oct 2009 09:14:38 -0700
Message-ID: <4ADC906E.2050909@kadzban.is-a-geek.net>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091013150839.GD32107@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com> <20091013173638.GE1119@ldl.fc.hp.com> <20091016003245.GD29672@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com> <20091016152053.GA9862@ldl.fc.hp.com> <1255707193.2869.12.camel@achroite> <20091016214024.GA10091@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE5895AF@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-ripemd160;
 protocol="application/pgp-signature";
 boundary="------------enigFC838F5020A2E346D0E4E3C2"
Cc: dannf@hp.com, bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Matt_Domsch@Dell.com,
	Jordan_Hargrave@Dell.com, Charles_Rose@Dell.com
To: Narendra_K@Dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE5895AF@blrx3m08.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFC838F5020A2E346D0E4E3C2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Narendra_K@Dell.com wrote:
>>>>> And how would the regular file look like in terms of holding
>>>>>  ifindex of the interface, which can be passed to
>>>>> libnetdevname.
>>>> I can't think of anything we need to store in the regular file.
>>>> If we have the kernel name for the device, we can look up the
>>>> ifindex in /sys. Correct me if I'm wrong, but storing it
>>>> ourselves seems redundant.
>>> But the name of a netdev can change whereas its ifindex never
>>> does. Identifying netdevs by name would require additional work
>>> to update the links when a netdev is renamed and would still be
>>> prone to race conditions.  This is why Narendra and Matt were
>>> proposing to
>> store the
>>> ifindex in the node all along...
>> Matt, Ben and I talked about a few other possibilities on IRC. The
>> one I like the most at the moment is an idea Ben had to creat dummy
>> files named after the ifindex. Then, use symlinks for the kernel
>> name and the various by-$property subdirectories. This means the
>> KOBJ events will need to expose the ifindex.
>>=20
>=20
> I suppose the KOBJ events already expose the ifindex of a network=20
> interface. The file "/sys/class/net/ethN/uevent" contains
> INTERFACE=3DethN and IFINDEX=3Dn already. But it looks like udev doesn'=
t
> use it in any way.

Right; it could simply do the equivalent of:

touch /dev/netdev/$env{IFINDEX}

instead of its normal mknod(2), and then do normal SYMLINK processing.
That last part is what would link /dev/netdev/by-name/$env{INTERFACE} to
that device, along with /dev/netdev/by-mac/*, /dev/netdev/by-path/*,
etc., etc., in as many different ways as people want to add rules.

(Or /dev/net/by-* instead of netdev; I'm mostly ambivalent about the
first-level directory under /dev.  Looks like libnetdevname requires
/dev/netdev though.)

> For example, with the kernel patch the "/sys/class/net/ethN/uevent"=20
> contains in addition to the above details, MAJOR=3DM and MINOR=3Dm whic=
h
> the udev knows how to make use of with a rule like
>=20
> SUBSYSTEM=3D=3D"net", KERNEL!=3D"tun", NAME=3D"netdev/%k", MODE=3D"0600=
".

And if the only point is to get the ifindex via stat(2) on the resulting
symlinks, but people don't like device files, then why not get the
ifindex via readlink(2) (and a bit of string parsing, and a strtol(3) or
strtoul(3) call) instead?  :-)


--------------enigFC838F5020A2E346D0E4E3C2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEAREDAAYFAkrckHUACgkQYasYN+YI5W7nVwCcDMCx+WmE2rA/jCq0dref1+kX
MjcAnAip5w6rVqoZDK7T+ilXRzcZkFFd
=gXBU
-----END PGP SIGNATURE-----

--------------enigFC838F5020A2E346D0E4E3C2--
