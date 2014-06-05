From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus' tree
Date: Thu, 5 Jun 2014 13:13:59 +1000
Message-ID: <20140605131359.771694b6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/zo6ckb+r3+m.l5hgW8FNdfH"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stephen hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/zo6ckb+r3+m.l5hgW8FNdfH
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/hv/channel_mgmt.c between commit d3ba720dd58c ("Drivers: hv:
Eliminate the channel spinlock in the callback path") from Linus' tree
and commit 1b9d48f2a579 ("hyper-v: make uuid_le const") from the
net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/hv/channel_mgmt.c
index 6c8b032cacba,90d654556437..000000000000
--- a/drivers/hv/channel_mgmt.c
+++ b/drivers/hv/channel_mgmt.c
@@@ -404,7 -365,7 +404,7 @@@ static u32  next_vp
   * performance critical channels (IDE, SCSI and Network) will be uniformly
   * distributed across all available CPUs.
   */
- static void init_vp_index(struct vmbus_channel *channel, uuid_le *type_gu=
id)
 -static u32 get_vp_index(const uuid_le *type_guid)
++static void init_vp_index(struct vmbus_channel *channel, const uuid_le *t=
ype_guid)
  {
  	u32 cur_cpu;
  	int i;

--Sig_/zo6ckb+r3+m.l5hgW8FNdfH
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTj+B9AAoJEMDTa8Ir7ZwVqCgP/RyZj93in7WGZDp6DlhBSdnb
xS0FZTZVT7ADV5QwaMl2EFrpGL/XoqfWhZK+gjIBprZS++d3m5gP+i4bWMuaS6V0
ZPW60tQH4GHjXB4p1DLgP5Khn1e5z39pbJxRdZh11OZZRQLUEfy8wU0KvDeT0MFI
Mgk8rtC5fYLjLIbAhsidhS3T/0ydQolv70sVjPPNOLz8SzM8QLQ9d3hH0wKiwZDk
SQszOhxvS1LINvznCbJY1XJ+H80CA0s4fZ+TpGaEEdJf+HTEstc6qtjgaUFcQUJU
Vr6EC64gC0vCTjuB3JWaWcHzKcP84q0fh5WCkpImetxcfJ3SFzmEkYtlSfS8Rd1b
7U2ZzSDb3dGChwqLiY4GfAkxF4jJ2o4o1Yl6loa4k6V3T+VZvsX6Y6gqiKREqpc+
j5kSTmbCCoxr+YrPkTdHyNxSbCQ6Q4Ydr9Kl24X9aNANmhR3fq1zAOeVMZZNy13U
GNPFQeI+22+DWKRZM5iCGtnogjYhGdZYqbRVgX/cdG6nYUT0g84Ft9IMpxU0pA5E
BbHPxyeWpUMNelVCI4UgIk728FtdP1aVlsDppZFqvnESKJE4NcbRUEcdxy2Cf7f1
0ck9DjBZjeq5IU4UL1vwjpyHE+V3YjdKadvxco4Jj8cOLrLJY3Tf8BLglAg602/r
0PV88cjvxiQIe01Maq0l
=XqEg
-----END PGP SIGNATURE-----

--Sig_/zo6ckb+r3+m.l5hgW8FNdfH--
