From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH 2/2] ixgbe: restrict synchronization
 of	link_up and speed
Date: Tue, 29 Dec 2015 19:17:33 +0000
Message-ID: <53C6554C-8692-4EF3-BF5D-7217D2C9FDA0@intel.com>
References: <1450926752-11392-1-git-send-email-zyjzyj2000@gmail.com>
 <1451356326-2919-1-git-send-email-zyjzyj2000@gmail.com>
 <1451356326-2919-3-git-send-email-zyjzyj2000@gmail.com>
 <87618083B2453E4A8714035B62D67992504FB5FF@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_D8CCDAD2-140D-428A-A74C-1992CD5E7472";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "zyjzyj2000@gmail.com" <zyjzyj2000@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Viswanathan, Ven (Wind River)" <venkat.viswanathan@windriver.com>,
	"Shteinbock, Boris (Wind River)" <boris.shteinbock@windriver.com>,
	"Bourg, Vincent (Wind River)" <vincent.bourg@windriver.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5489 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753613AbbL2TRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 14:17:35 -0500
In-Reply-To: <87618083B2453E4A8714035B62D67992504FB5FF@FMSMSX105.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_D8CCDAD2-140D-428A-A74C-1992CD5E7472
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Emil S <emil.s.tantilov@intel.com> wrote:

>>  */
>> -	if (hw->mac.type =3D=3D ixgbe_mac_X540)
>> +	if ((hw->mac.type =3D=3D ixgbe_mac_X540) &&
>> +	    (netdev->flags & IFF_SLAVE))
>> 		if (link_speed =3D=3D IXGBE_LINK_SPEED_UNKNOWN)
>> 			return;
>=20
> If you were to enter ixgbe_watchdog_link_is_up() with unknown speed, =
then I would
> assume that you also have a dmesg that shows:
> "NIC Link is Up unknown speed"
>=20
> by the interface you use in the bond?

It seems odd to be checking the MAC type for this. Is this behavior =
perhaps more related to the copper phy? If so, then the check should be =
changed. Or would the check for unknown link speed be sufficient? It =
seems like an interface as a slave would not work with an unknown link =
speed, so it may as well wait in all cases, not just for X540.

--
Mark Rustad, Networking Division, Intel Corporation

--Apple-Mail=_D8CCDAD2-140D-428A-A74C-1992CD5E7472
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJWgtxMAAoJEDwO/+eO4+5u8L4P/AhJeEM+PRoI1X/w6DQr+FbR
Dy06cxmpGWK2MLi7gJhaAvlHUBhD5QuiRVgzekZbqkzpi7dKsGAXl9Wn4cLpGxeM
xJTAKBONUxRvdUQufWtDsFn0/YJ/DAcB183ofCg/jXCjvQnI5ppKR+GDdc9wApOp
uPiF375+GEj0qUKkeQcszSNmcnRHm6X/AsahbuFqZHu/F5NUP3KeZdTyi39hgzNh
N54x59ggVW3N7tQLg3C7MOujjRe+g3YpfeTvsvUxF3YO3e8g7KAyfd95aTuEpaES
f5jeIR5/LA9qKKee7jS1nyaExGyS8Rk2uMH0kuOKcF/gmhcpGI6ZARacvneS+/hz
sZJ41HYSI2S2OHreb8Q1GnqB2fVElZDu+EvSPj+Z8564dSTUetFZTQh1yR9phHWO
pwrC8Y08XDjF3eMPK2REb5Jk5zXzyMX/0gIkEOBDSnwqtzy4uo4REUpVcUEJ8E5A
f6G3s7awIbNEzHm2WssBNkOHTfO5XABGdZyhkhzyp85sZQ/4YR4lGz3C4mtD6kCE
ID8EmFfw5OroE5TY707nHG602Nn2dO3DvWdKJW3HC3Rv8Aj7GNUAvtRmF5LXTAnF
ZwgoI6AFLwTs/IcmMoIFcrovQUR86mBvSVH1yt92HLxFRtFaoNyzP694KWa8i5qI
5Gheb+dR9O5Qwh+zF9vd
=/tA+
-----END PGP SIGNATURE-----

--Apple-Mail=_D8CCDAD2-140D-428A-A74C-1992CD5E7472--
