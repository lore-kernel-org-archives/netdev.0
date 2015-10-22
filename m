From: Thomas Haller <thaller@redhat.com>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Thu, 22 Oct 2015 17:20:40 +0200
Message-ID: <1445527240.7084.46.camel@redhat.com>
References: <20151021164613.24650836@griffin>
	 <20151021.083214.534622235927401863.davem@davemloft.net>
	 <20151021172502.63220dbb@griffin>
	 <20151021.085635.1582760365341524949.davem@davemloft.net>
	 <1445447578.1265325.416533273.3D5599FD@webmail.messagingengine.com>
	 <5628F81D.1070009@6wind.com> <20151022170100.1e45a8b8@griffin>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-gEIppM2gab849RjPTOIp"
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43004 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753405AbbJVPUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 11:20:45 -0400
In-Reply-To: <20151022170100.1e45a8b8@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gEIppM2gab849RjPTOIp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2015-10-22 at 17:00 +0200, Jiri Benc wrote:
> On Thu, 22 Oct 2015 16:52:13 +0200, Nicolas Dichtel wrote:
> > With the proposed scenario:
> > 1. create netns 'new_netns'
> > 2. in root netns, move the interface with ifindex 2 to new_netns
> > 3. in new_netns, delete the interface with ifindex 2
> > 4. in new_netns, create an interface - it will get ifindex 2
> >=20
> > Operation 2 and 4 are done by dev_change_net_namespace() under
> > rtnl_lock().
> > RTM_DELLINK(root netns) and RTM_NEWLINK(new_netns) are sent by this
> > function.
> > It means that operation 3 has been done before and that
> > RTM_DELLINK(new_netns)
> > has been sent before.
>=20
> Imagine the application trying to configure the interface with
> ifindex 2
> after your step 2. It constructs a netlink message and sends it to
> the
> kernel; but while doing so, steps 3 and 4 happen. Now the application
> ends up configuring a different interface than it intended to. After
> that, it polls the netlink socket and receives the notifications
> about
> interface disappearing and a new one appearing.
>=20
> I don't see any way the user space application can prevent this.
> There
> will always be a race between receiving netlink notifications and
> sending config requests.
>=20
> I guess Thomas Haller can elaborate more as he ran into this.

Jiri,

It's really just what you said.

Whatever action the application wants to perform when using the
ifindex, there is a time-window between learning about the ifindex
and using it.

There is nothing userspace can do except trying to hurry and hoping for
the best.


Thomas

--=-gEIppM2gab849RjPTOIp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABAgAGBQJWKP7IAAoJECnCNm5N/Fco0H8P/0J9aqBnnYVhVqjeU+1WR3Jn
XpsluVnqkS824TEQQa17YRILW5YHXFXvSaYyBIpiDR2GGwWWldWdQlRJ5Ow/TlHo
fNUpXdsqPXCSMavyj49oDcVmJTZmXdVxdVZ2Ndc4WGFYzKVPWHnkGkimF4zrMOQQ
/E2e8B5/+NETnQJ/XjGeq4yqY8xxxJ2D1cfNn6g19BVxPpsZXOXXpJGjRDSd2dw1
nRwyOu7J4th+OCA65kLtKPaF+wa4tRPHgO/Vl5VkLMal0t20tGpoJUy38Sa9zRRC
z9fbuK2TrUmcyk3+iKfPwKgrRIiysTmC7l95psFZ3X2T+WVERMjZLSfiX/Z85Sqo
/ZHjoNbawVW305uKNxPaU8Wn4cpwQj9qbMee9DLvUmCDFTaGZhnEUKzJySuqhB47
HmAadrfjYxgPmjIg+39yXJngXVbtm3mRGvY0eiDjutfNA6iI6i9XcHVavxe8T1Wn
I22VGjihRFSuRO+ZZ2ygsUuPWT+a8OC6FR3raSwyVxisXWa9tQYovu7zyS5XRgx6
ACUi04BYpdeOumb5aMEcHklmcWBYrmAd1BD0c4mspZCA0DFy3wC3EWZGka6LZ5EO
xPu9xzXCWWNE1lfgXz9QEs6nn99pdMBW7/cECXgmfoAhDoQXkx/e0MvzSRylwiaN
A8H+p2Tv8OMDUWsv+DvR
=JaIg
-----END PGP SIGNATURE-----

--=-gEIppM2gab849RjPTOIp--
