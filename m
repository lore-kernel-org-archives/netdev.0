From: Erik Mouw <mouw@nl.linux.org>
Subject: Re: Lots of "BUG eth1 code -5 qlen 0" messages in 2.6.24
Date: Fri, 1 Feb 2008 15:54:47 +0100
Message-ID: <20080201145446.GA3661@gateway.home>
References: <20080129184726.GA29300@gateway.home> <D5C1322C3E673F459512FB59E0DDC329046C6CC7@orsmsx414.amr.corp.intel.com> <1201640243.4431.29.camel@localhost> <20080129214555.GC29300@gateway.home> <1201648108.4425.15.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d6Gm4EdcadzBjdND"
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr15.xs4all.nl ([194.109.24.35]:4200 "EHLO
	smtp-vbr15.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606AbYBAOzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 09:55:00 -0500
Content-Disposition: inline
In-Reply-To: <1201648108.4425.15.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--d6Gm4EdcadzBjdND
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 29, 2008 at 06:08:28PM -0500, jamal wrote:
> On Tue, 2008-29-01 at 22:45 +0100, Erik Mouw wrote:
>=20
> > > The driver seems buggy. Make it return NETDEV_TX_BUSY instead of -EIO
> > > in xircom_start_xmit() and the messages will go away.
> >=20
> > Like this?
> >=20
>=20
> Indeed.=20

I've changed the -EIO into NETDEV_TX_BUSY and so far I can't trigger
the bug anymore. It was quite easy to trigger within minutes with
rsync, but I can't trigger it anymore. Should I send a patch, and if
so: to who? The tulip/xircom_cb driver seems to be orphaned.

> Peter, I suspect that driver is just buggy in some other way as opposed
> to being re-entered; couldnt tell by inspection. It is possible it may
> be too eager to open up before it really has space.
> It will be easy to check your theory by having the driver just check if
> it is netif_stopped just before it returns NETDEV_TX_BUSY.

No need to test that, it *is* netif_stopped before the return:

        /* Uh oh... no free descriptor... drop the packet */
        netif_stop_queue(dev);
        spin_unlock_irqrestore(&card->lock,flags);
        trigger_transmit(card);

        return NETDEV_TX_BUSY;

trigger_transmit() is a simple function that just writes a single
register on the card to trigger a transmit.


Erik

--=20
They're all fools. Don't worry. Darwin may be slow, but he'll
eventually get them. -- Matthew Lammers in alt.sysadmin.recovery

--d6Gm4EdcadzBjdND
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHozK2/PlVHJtIto0RAgOfAJ9RN0I1HXNM2U34F4HOoNFDfPFBrQCfcyVU
5jWPFQheDhAIDmxFWOzc098=
=Jowt
-----END PGP SIGNATURE-----

--d6Gm4EdcadzBjdND--
