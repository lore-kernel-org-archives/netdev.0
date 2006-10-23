From: Stuffed Crust <pizza@shaftnet.org>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Mon, 23 Oct 2006 09:04:20 -0400
Message-ID: <20061023130420.GA29713@shaftnet.org>
References: <1161335976.21402.11.camel@devlinux-hong> <20061023144028.629dc5d8@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C7zPtVaVf+AK4Oqc"
Cc: Hong Liu <hong.liu@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-73-230-86.se.biz.rr.com ([24.73.230.86]:31878 "EHLO
	shaft.shaftnet.org") by vger.kernel.org with ESMTP id S964792AbWJWNBX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 09:01:23 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20061023144028.629dc5d8@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 23, 2006 at 02:40:28PM +0200, Jiri Benc wrote:
> >  	int icv_len:8; /* Length of the ICV/MIC field in octets */
> >  	int iv_len:8; /* Length of the IV field in octets */
> > +	u8 rc4key[16]; /* generated RC4 key for hw TKIP */
>=20
> I don't like extending ieee80211_tx_control by 16 more bytes. The
> driver is required to store a copy of each ieee80211_tx_control
> (because it's copied to ieee80211_tx_status). I don't have a better
> idea, though. Anybody?

If the key isn't passed directly in via the tx_control structure, there
needs to be a way for the driver to be able to get the key for that
packet.  Many chipsets won't care, but many expect the encryption
key to be passed in with each packet.  (For WEP, TKIP, or AES-CCMP)

Instead of expanding tx_control, adding an API call might suffice.  with
TKIP all you need to do the RC4 mixing is already in the packet
(macaddr, EIV (keynum+PN), and payload.  The stack just needs to be able
to look up the PTK given the macaddr+keyidx, and the chipset driver can=20
then derive whatever key it needs and stuff the hardware with it.

Crypto is the main way where wireless chipsets make life difficult for a=20
common stack..

 - Solomon=20
--=20
Solomon Peachy        		       pizza at shaftnet dot org	=20
Melbourne, FL                          ^^ (mail/jabber/gtalk) ^^
Quidquid latine dictum sit, altum viditur.          ICQ: 1318344


--C7zPtVaVf+AK4Oqc
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.7 (GNU/Linux)

iD8DBQFFPL3UPuLgii2759ARApjEAJ9raMexCeQ+FqzkGZ+Z4yWl8clwDwCglmmt
3Q4ZSo2GuV0bK0aN8gYL+mI=
=cSLU
-----END PGP SIGNATURE-----

--C7zPtVaVf+AK4Oqc--
