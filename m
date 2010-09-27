From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Mon, 27 Sep 2010 15:44:08 +1000
Message-ID: <20100927154408.55a28127.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__27_Sep_2010_15_44_08_+1000_=FaTB+MmrIvzOgz5"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ohad Ben-Cohen <ohad@wizery.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__27_Sep_2010_15_44_08_+1000_=FaTB+MmrIvzOgz5
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (x86_64
allmodconfig) failed like this:

Assembler messages:
Fatal error: can't create drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_=
data.o: No such file or directory
drivers/net/wireless/wl12xx/wl12xx_platform_data.c: In function 'wl12xx_get=
_platform_data':
drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: error: cannot open d=
rivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.gcno
drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: confused by earlier =
errors, bailing out

Presumably caused by commit 61ee7007a5d61aa066076da578e8e8084e122d7d
("wl12xx: add platform data passing support").

I do my builds with a separate object directory (which may be a reason
you don't see this).

I have reverted that commit for today (and commits
09cecc340b3b4d9960b039c0f576548bbf857f5a ("wl1271: take irq info from
private board data") and 15cea99306ae14ce5f7c3d3989bcc17202e2b0be
("wl1271: make ref_clock configurable by board") which follow it).
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__27_Sep_2010_15_44_08_+1000_=FaTB+MmrIvzOgz5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMoC8oAAoJEDMEi1NhKgbstzUH/RSlxBgO/QqzmyZyWXMGScFq
25EE+9svHn1yLcLrsmGShzigfpHHHFOo1uboQyvsqaKXdubxEA6TsIpjpnc2uhaO
mfMv7P4tev7c1m05Hw/zJZASBPMLxXo7ORL+5guZjNr/KCdRZw4WUHp9l2JdDeIi
ZnsBq68KD5Qs8t+qgn6lYgx1X923t+pTfJUv53Gng0eEoC1IEQwvKqGZ52lAgxaP
vjDLmgBGYnodo0m00Y+4KLROg/n5exae0N24A9QXBtoa6ANtd25VMg9elrkZiPUX
ofFjx8Sq2K3bYQkzguRoyWLKrbZlwprMtWTMPP7spCGBAtqrhC7fjEmFIaUEzk0=
=K7Nw
-----END PGP SIGNATURE-----

--Signature=_Mon__27_Sep_2010_15_44_08_+1000_=FaTB+MmrIvzOgz5--
