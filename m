From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Thu, 16 Feb 2012 12:37:46 +1100
Message-ID: <20120216123746.f59cf69ebaefc6d28c90703c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__16_Feb_2012_12_37_46_+1100_dfhJj1CH36ESJ3mo"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__16_Feb_2012_12_37_46_+1100_dfhJj1CH36ESJ3mo
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/mac80211/debugfs_sta.c between commit 4b5a433ae534 ("mac80211: call
rate control only after init") from the wireless tree and commit
83d5cc012441 ("mac80211: station state transition error handling") from
the net-next tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/mac80211/debugfs_sta.c
index d86217d,c838371..0000000
--- a/net/mac80211/debugfs_sta.c
+++ b/net/mac80211/debugfs_sta.c
@@@ -63,14 -63,15 +63,15 @@@ static ssize_t sta_flags_read(struct fi
  	test_sta_flag(sta, WLAN_STA_##flg) ? #flg "\n" : ""
 =20
  	int res =3D scnprintf(buf, sizeof(buf),
- 			    "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
 -			    "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
++			    "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
  			    TEST(AUTH), TEST(ASSOC), TEST(PS_STA),
  			    TEST(PS_DRIVER), TEST(AUTHORIZED),
  			    TEST(SHORT_PREAMBLE),
  			    TEST(WME), TEST(WDS), TEST(CLEAR_PS_FILT),
  			    TEST(MFP), TEST(BLOCK_BA), TEST(PSPOLL),
  			    TEST(UAPSD), TEST(SP), TEST(TDLS_PEER),
- 			    TEST(TDLS_PEER_AUTH), TEST(RATE_CONTROL));
 -			    TEST(TDLS_PEER_AUTH), TEST(4ADDR_EVENT),
 -			    TEST(INSERTED));
++			    TEST(TDLS_PEER_AUTH), TEST(RATE_CONTROL),
++			    TEST(4ADDR_EVENT), TEST(INSERTED));
  #undef TEST
  	return simple_read_from_buffer(userbuf, count, ppos, buf, res);
  }

--Signature=_Thu__16_Feb_2012_12_37_46_+1100_dfhJj1CH36ESJ3mo
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJPPF3qAAoJEECxmPOUX5FEs2cP/0heT8szvwQzx93At5loYWq+
NT7nIHkASeug61dz7SEkkJcBPkUZBUj+3LQz8wryW5zQg9c0j5dkHdYdXqthHk+T
gmYYt9UpbctgN8oo0kBg8WuRjuUF1Tm6arOjPqm7IOXA2PijE4vMfkIdqx3ug3kq
2pFiaeQUcMKzIZb7PgXtstXG0BKPg4eXtAQWvVsuPY/Dl4JPCZJkNcwUIgFrRgIz
Rr1HGq/bOL/mvHljnmH6V2oqcaz1F7zklDGZymB9cxbpqEDVT0WScpywqic3+eru
syB711oDLPRS4wyX+xVxVMvW8e9z0smYPYhgZLE/Eh3+z3D3WPRKQ7KSqvo8lj+9
67Nada57y0H2iWzNS1X5vuRy6YYiVVL4TzSrEu8BG+jlZXSnUtaFVyXFZ9G00mOl
dIKnzE6L8w8LdFF9kcoy7GuIqyF0JN4MSRFT1K3zhaSb2WVUpw892vsBPItFya+G
ql4hJismTd2hKe3CaoCjF5eBd0A6rGqy0cHAk/xE54Qv8UVjxxwhLiQp95VuYEBc
eUChPCXGugIKryRyOMXQa6mxuEfdyLbRn8KLPVMGMBTcpBmkzqyCoRrtTx7RpNHB
Oz5Cf57uidyn7U96y9UYIax2NaGDiSQIdMBOGkeBdz6horXmet118+XQmSYE1am0
A/QLAx/6u0R9OcBO7UoC
=zrch
-----END PGP SIGNATURE-----

--Signature=_Thu__16_Feb_2012_12_37_46_+1100_dfhJj1CH36ESJ3mo--
