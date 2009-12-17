From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [Bugme-new] [Bug 14791] New: Something has been broken in the
 network stack this week
Date: Thu, 17 Dec 2009 00:03:31 +0000
Message-ID: <1261008211.2284.16.camel@localhost>
References: <bug-14791-10286@http.bugzilla.kernel.org/>
	 <20091216154018.e3baaed6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-BX+7lxtih6jK2r1sat0o"
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, speedyboyinovator@hotmail.com,
	Andrew Morton <akpm@linux-foundation.org>
To: Oliver Neukum <oliver@neukum.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50710 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758187AbZLQAHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 19:07:25 -0500
In-Reply-To: <20091216154018.e3baaed6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BX+7lxtih6jK2r1sat0o
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

speedyboyinovator@hotmail.com wrote (via Bugzilla):
> > Apparently something has been broken in the network stack this week
> >=20
> > Hi. This is my first bug/issue report, so understand any mistake or n00=
b thing
> > I make here. And sorry for the bad english ;)
> >=20
> > It looks like that from the 2.6.32 release, to the git commit
> > 2.6.32-05254-g3067e02 (i've compiled it in Dec 10 11:39:26 (Brazilian T=
Z)
> > 2009), something weird happened ;)
> >=20
> > I've used the USB_NET_CDCETHER for 2 years now, and it always worked.
> > But when I rebooted to my new kernel 2.6.32-05254-g3067e02, from the 2.=
6.32, it
> > just dont get connected.
> >=20
> > [   16.683465] ADDRCONF(NETDEV_UP): eth1: link is not ready
> > [   94.854539] ADDRCONF(NETDEV_UP): eth1: link is not ready
> >=20
> > There's no symptom of anything wrong. And even restarting the modem and=
 then
> > reconnecting the USB cable, it does'nt work.
> >=20
> > Then I reboot to the 2.6.32 one, and it takes just one dhclient command=
 and 1
> > second to be online again.

This may well be due to this change, which sets the initial assumed link
state to be down, not up:

commit 37e8273cd30592d3a82bcb70cbb1bdc4eaeb6b71
Author: Ben Hutchings <ben@decadent.org.uk>
Date:   Wed Nov 4 15:29:52 2009 +0000

    usbnet: Set link down initially for drivers that update link state
   =20
    Some usbnet drivers update link state while others do not due to
    hardware limitations.  Add a flag to distinguish those that do, and
    set the link down initially for their devices.
   =20
    This is intended to fix this bug: http://bugs.debian.org/444043
   =20
    Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Perhaps cdc_ether should poll the hardware to get the initial link
state?

Ben.

--=20
Ben Hutchings
Hoare's Law of Large Problems:
        Inside every large problem is a small problem struggling to get out=
.

--=-BX+7lxtih6jK2r1sat0o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASyl1TOe/yOyVhhEJAQJopxAA0EomR2n/Na1xOzDR7h1wHj0ykznFozko
ottcEZZXPMP6khm+zz7FB4QyFgk5I8vrycChbaOl2ofWR9yljXj8B9iCzIJ8HU1Y
w5D0UB7l1rBsryRKs3dIDRbWxRmtRv8ehzg7zYqNlNstxbH31HU0tPZel03WjOFb
Zyvwe3jgElwaSBjMLflgSTkGYQmgCQCWZd1dJdsgdlegNytfIxuhNUSaE/7hf+EZ
jmmwjBuPLzRhU6Tvd2lM2zwV5QI/vPY3tGJEbV8hT/JvNJ+KSyDIxcLd1SAG+1h9
fx0N2ppzpEafW8+/ROzvX753wQWNG0/b6AmKNlY2oc1y6bI1DFAbD0EOUGNKgVbW
VCddHxcnHDdsrVsQgAFfDZODvZNDnrUWvJqhohAq7vyxRnpAHCkNDrYbmOZuA0rM
NB8WPLxm/OoCJ9zNqmZrOzK9MF+UhE9noXviVhfQdiPGAHFqXCpXXwi00Dz39h7n
kaJdYTU0J9OV7IFU5jc3eO+vpwCcTCQ6O8hG8viwfGMgsxWNwxl8VX84c4IW6Da6
uUUoeLS8/j7wfUDBNQa4/RCl+StfZ7JlZCd+dthNwrnjn8KSk9wAA7j9apsMB13Q
0I14MOxMo7nT9df0zhZAREt1FsHz6iSmupwogk8t7fXQDBShA7Hg7nS4YcIo7lZc
zZTZdBpXMv4=
=Pb3c
-----END PGP SIGNATURE-----

--=-BX+7lxtih6jK2r1sat0o--
