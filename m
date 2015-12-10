From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v2] r8169: Don't claim WoL works if LanWake flag is not
 set
Date: Thu, 10 Dec 2015 23:02:55 +0100
Message-ID: <20151210220255.GB3507@calimero.vinschen.de>
References: <1449655730-3328-1-git-send-email-vinschen@redhat.com>
 <1449657826-4461-1-git-send-email-vinschen@redhat.com>
 <20151209224306.GA5082@electric-eye.fr.zoreil.com>
 <20151210095135.GA21583@calimero.vinschen.de>
 <20151210204054.GA30391@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="61jdw2sOBCFtR2d/"
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Chun-Hao Lin <hau@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Corinna Vinschen <vinschen@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:50965 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbbLJWC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 17:02:58 -0500
Content-Disposition: inline
In-Reply-To: <20151210204054.GA30391@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--61jdw2sOBCFtR2d/
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Dec 10 21:40, Francois Romieu wrote:
> Corinna Vinschen <vinschen@redhat.com> :
> [...]
> > I could do this (after I could lay my hands on such a board, that is),
> > but I'm not convinced that this makes a lot of sense for two reasons.
>=20
> Ok, let's get this change applied. Whatever happens should not be
> hard to manage (I'm thinking about other boards or BIOSes relying on the
> current - broken as it can be - behavior to work correctly).
>=20
> [...]
> > 1.  There is no global change in behaviour.  The usual way to handle the
> >     WoL flags is to set the affected method flags and additionally set
> >     LanWake if any of the method flags is set.  The fact that the method
> >     flags don't enable WoL without also settting the LanWake flag is
> >     documented.
>=20
> I see no such thing in "7.5 Power Management Function" of the 8168c
> registers datasheet. While Config3 states Magic Packet and Link Up
> dependencies on Config1.PMEn, it says nothing about Config5.LanWake.
>=20
> On old 8169 chipsets LanWake is autoloaded from EEPROM.
>=20
> Plausible for Config5.{B, M, U}WF ? Ok.
>=20
> Documented ? I am genuinely curious to know where.

Ok, I reread the documentation I have, and I got that wrong it seems.
Apparently the LanWake flag enables or disables the LANWAKE/LANWAKEB pin
only but not the other possible PM events.

So, self-NACKed.

It's still a bit weird.  On the machines I tested this on, if I disable
LanWake and shutdown the machine, I can send, e.g., MagicPackets as much
as I like, the machined don't come up.  Isn't it a bit misleading then
if ethtool reports that some WoL method is enabled but it doesn't work?


Corinna

--61jdw2sOBCFtR2d/
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWafaPAAoJEPU2Bp2uRE+gDSMQAJfsRIIEqFyf34WJvgI59Aoe
rWCGPSiXEBDSXhloiBPtmsAFHkqQIrA1pxmMYmEOUUiWD8PT5i06xCeKDC8qDSl8
f9StbJVetAqvQ+5siLMJdWQsp2FlBKFIm1EXrcjRhRDTe8raVeYfyDoxSYl7rvTz
7NiXXwJY2iX0YEq05GRAR91AAt0GYg68cPZ4uYDI9IOujlVAdxh7GKIIL3zvaXQI
VNULVx+8DF94d3ZmhJCz1ixuorcDPDCMZzPs/TMoVhgATTA0HwiCNdM+ZPqnzlxA
AbDZ5d9O1JhXvEez6MWkAAIUA2aGVfkskZLvZnHJNC1+/aVGhcN/STHw0YybOe25
nAoe+K+y12nZHA1nMcFdixdqU7Vis5IzKw5iZfZxDTvNO9pmQCzzi87x2BxJoJs6
qkjc/VscNajrjhU82qbHMCiyT+o79cLq7am/CbzFleCZ84Yk3wF4DRobqVzeIsKz
d9RlJR/HqgPdH+WaDnQzUGrRhFusACjClZwQleNp8bvVzSehC7sfWTXUEdK2XDar
q43ytHalVmyaWSkwxO3lOb8KOk7FChYqu3IQo+PPx7HouQA6vLUU28UXfg0ryZ2F
RUvNcHtaBsnAn0yGMADI1FQBhnCfd5DeNeiaigtkh88cCskJleK5jUF6TK+sz6S7
Zp6+B7XH5rdCrbsOOyfK
=0v8n
-----END PGP SIGNATURE-----

--61jdw2sOBCFtR2d/--
