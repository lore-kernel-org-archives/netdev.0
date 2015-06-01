From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 0/2] Fix couple of issues with 'ethtool' get/set API's
Date: Mon, 01 Jun 2015 20:29:23 +0100
Message-ID: <1433186963.6319.195.camel@decadent.org.uk>
References: <1432334609-3971-1-git-send-email-aparames@broadcom.com>
		 <1433102379.6319.110.camel@decadent.org.uk>
	 <556C92E3.3030707@broadcom.com> <1433182033.6319.178.camel@decadent.org.uk>
	 <556CAEA9.5090003@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-NF7sq4u4n5eSrJkcGYcq"
Cc: Ben Hutchings <bwh@kernel.org>, netdev@vger.kernel.org,
	jdzheng@broadcom.com
To: Arun Parameswaran <aparames@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34171 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751493AbbFAT3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 15:29:35 -0400
In-Reply-To: <556CAEA9.5090003@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NF7sq4u4n5eSrJkcGYcq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-06-01 at 12:12 -0700, Arun Parameswaran wrote:
> On 15-06-01 11:07 AM, Ben Hutchings wrote:
> > On Mon, 2015-06-01 at 10:14 -0700, Arun Parameswaran wrote:
> >> On 15-05-31 12:59 PM, Ben Hutchings wrote:
> >>> On Fri, 2015-05-22 at 15:43 -0700, Arun Parameswaran wrote:
> >>>> Hi,
> >>>> The patch fixes 2 issues with 'ethtool' getting/setting parametres i=
n
> >>>> the do_gset() do_sset() API's.
> >>>>
> >>>> I have pushed a patch to the Kernel to fix an issue in the handling =
of
> >>>> the 'ethtool' commands which got accepted.
> >>>> This Kernel patch was based on Linux v4.1-rc4 and is available in:
> >>>> https://github.com/Broadcom/cygnus-linux/tree/net-core-ethtool-fix-v=
1
> >>>>
> >>>> The Kernel was always clearing the command from the 'ethtool' result=
ing
> >>>> in all operations to deal with PHY0. This prevents querying/setting
> >>>> PHY 1's settings.
> >>> [...]
> >>>
> >>> Each net device can be associated with a single PHY at a time, and th=
e
> >>> ETHTOOL_GSET implementation should fill in the PHY address in the
> >>> ethtool_cmd::phy_address field.  Where there are multiple PHYs that c=
an
> >>> be connected to the net device's MAC, an ETHTOOL_SSET operation can b=
e
> >>> used to change that PHY address.
> >>>
> >> The above can be done by the driver when there is one PHY per MAC. In =
our
> >> case we have multiple PHYs controlled by the same MAC. I should have
> >> clarified this earlier, I apologize.
> >=20
> > I understand that you can have multiple PHYs on the same MDIO bus, but
> > not how the MAC can use them at the same time.  Is this hardware level
> > bonding?  Or are multiple PHYs needed for a single link?
> >=20
> We have an internal switch which manages the traffic to the PHY's (ports)=
.
> There is 1 PHY per external port.
> The MAC is connected to the internal port of the switch.

Then you should create net devices for those external ports as well as
the internal port.

If I understand the switchdev API rightly, the external port devices
should implement the ethtool {get,set}_settings operations and the
ndo_switch_parent_id_get operation.  The existing net device should
expose only the internal link to the switch (which presumably isn't
configurable at all).

[...]
> But this prevents the 'ethtool' from being used to get/set data of
> specific PHY's.

That is fine because it is meant to manage the net device's own link (in
this case, the internal port), not other switch ports.

Ben.

--=20
Ben Hutchings
Power corrupts.  Absolute power is kind of neat.
                           - John Lehman, Secretary of the US Navy 1981-198=
7

--=-NF7sq4u4n5eSrJkcGYcq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWyymOe/yOyVhhEJAQoI0xAAmYoi1um7vQVEq7QcGkUNhBOFmp056lrA
QWn/atE4AvCCn0EMcxuD/jWZcAhDZH5miFSDdE8v5Fd0+FgOMZkUfo9RM2dUZ7cQ
1FAG50R1kOXk6xknTrl+IvIzgrCkWoiV9OmrYnFYHdRg5rc2vsvuk40wX1AEqh53
KrM6qfl1FbrVOIVWazEZwGs+2R1ylD3AroebZ56gUADS5eaus0t6D9gF4m8N/+AH
1v749CAgkmv8PGW5pY3J6yIJKERV/S6wb3SNW4rtmmccGvHPebZvqkGMcNs2Anao
uWTPoPq0ly5qsPKgGBQ9tMhtmoJVf1cwwqsyZYk1MrtI74pcmTwlfG1N+G0maRhN
Wy8xxm8F+kkDm/G/BS6Pv79zgbJp0KTt9tWnOF+uGjAZjFB69DqC09sw3i1afrPM
9W+L2RX0IlHRYWFV0DijB0maAFCF6FL4CKvJH6VaWhI1CDIaZTSa11HgO2e5CswZ
nLiY2mSjQU9O/y2l7fPNNbfe4NZ+kqf9fbCULXirKhbLuqzRHzWVyQxC5/f+HFCk
kLRIJZ+WD1cs+oCcz/ZrdV1jdcBtnVwfdEkrHv6Q8JSKIQgH9CxBYtP4qus7XYeo
CeIGhjbHTwitqIG9KTfzCajMXiGsAO6KKli+rU2bOycB5N2cprVQcofh00aITa/S
wEpgtJZMaCQ=
=BSDs
-----END PGP SIGNATURE-----

--=-NF7sq4u4n5eSrJkcGYcq--
