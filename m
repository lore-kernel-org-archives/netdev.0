From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v5 net-next 0/2] patchset: Support for configurable RSS
 hash key
Date: Fri, 21 Mar 2014 14:33:13 +0000
Message-ID: <1395412393.2770.48.camel@deadeye.wl.decadent.org.uk>
References: <193620ac-855b-4c2a-b9ab-962b2edfbfa2@CMEXHTCAS2.ad.emulex.com>
	 <20140319.155930.1805664690676428310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5D4wTVPe0cF37kyuklmL"
Cc: VenkatKumar.Duvvuru@Emulex.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34362 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753221AbaCUOdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 10:33:23 -0400
In-Reply-To: <20140319.155930.1805664690676428310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5D4wTVPe0cF37kyuklmL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-19 at 15:59 -0400, David Miller wrote:
> From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
> Date: Mon, 17 Mar 2014 18:01:33 +0530
>=20
> > NIC drivers that support RSS use either a hard-coded value or a random =
value for
> > the RSS hash key. Irrespective of the type of the key used, the user wo=
uld want
> > to change the hash key if he/she is not satisfied with the effectivenes=
s of the
> > default hash-key in spreading the incoming flows evenly across the RSS =
queues.
> >=20
> > This patch set adds support for configuring the RSS hash-key via the et=
htool
> > interface using -X option.
>=20
> I apologize, but I really dislike this.  For several reasons.
>=20
> First, why aren't we adding _just_ a RSS hash changing interface?
>
> We already have an interface for changing the indirection table,
> there is absolutely not need to add a second interface that supports
> both indirection table _plus_ hash modifications.

That's what I asked for, because I see the hash key and indirection
table as being a single logical object (RSS context).

> And combining these two is what leads to this hard to audit, ugly,
> data structure layout.
>=20
> There's the indirection table at some offset, then the key at some
> other offset.  This makes it impossible to impose type checking
> of any kind on both objects.
[...]

Which is why I previously suggested making the ethtool core find the two
arrays and pass those into the driver operations.  We do that for other
ethtool operations that use even a single variable-length array.

Ben.

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of them.

--=-5D4wTVPe0cF37kyuklmL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyxNqee/yOyVhhEJAQqG7g//VDo3K00Ijsopmvek8avoFIYbog5CFy2l
vqK9WE2vTQReWCw606379tq94LsCTofJS4BvHYnnKnxdWbNTJPlI8zKvUGYPc0fM
LkdXnYkyZ6DkAxyYZZ1gqaj7BEEE5XDzkbLHjLLhhYeofeezcL6l4QeT/KHCA1sh
ytYCzZP8bryo2mbr05n5oWQ936JFiJErrROqt8I1O338kgBb8AudSJymJxu+bSND
y2XQ0gXfox17sKE1mpOuVQALTM8Jj7ZhYGsoFQ+pO79a659iPLUDdPYlsVkozAgp
eMI5dvjl8xQqglC0JxbHkqPtOXRnuZRait5t9vE7PEblUjAt/5Kb91/bc4LX34gZ
5V4onj2N953q4VqJ28OW0qz6ZfbdpRrDUptewjpcwS9IKS/ijIvzhUZQ5EFci16e
7Gqqw54txervFvhyqshixWf1q5D6Y5NhDJsMQBq81bkXPqd8HAMtKUg7SBgRgYzi
KeTDzPSpVEZAx74wt50zamr6sQIWXsZW9y1chNWn7X2DJlu06+0C07WF1azzgbI8
pEE6Id+MuT6SMkH+NYBygwZMYkmQTBS8I+zEbp/vvNh1QYNezsWdybN9AOQlpwP7
8gFKYvejIBcMOB2TBj+Y59ZcFAzgk8wWirG0261AJhYuR/1ic2N0ceSHp9gd/4cc
fvgQBOq3OZ0=
=Ng41
-----END PGP SIGNATURE-----

--=-5D4wTVPe0cF37kyuklmL--
