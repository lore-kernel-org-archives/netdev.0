From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Wed, 15 Oct 2014 10:44:11 +1100
Message-ID: <20141015104411.306b138e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/6dNYcMkOevjJGJJO7vt0dpZ"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/6dNYcMkOevjJGJJO7vt0dpZ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

drivers/built-in.o: In function `.LANCHOR0':
:(.rodata+0x6b764): undefined reference to `sti_gmac_data'
:(.rodata+0x6b828): undefined reference to `sti_gmac_data'
:(.rodata+0x6b8ec): undefined reference to `sti_gmac_data'
:(.rodata+0x6b9b0): undefined reference to `sti_gmac_data'

Caused by commit 53b26b9bc9a5 ("stmmac: dwmac-sti: review the
glue-logic for STi4xx and STiD127 SoCs") which renamed sti_gmac_data to
stih4xx_dwmac_data (or something) without updating all the references
to it (including the one added in the previous commit ...).

I reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/6dNYcMkOevjJGJJO7vt0dpZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUPbVRAAoJEMDTa8Ir7ZwVbsEQAIl2J3gpOAOUTw8NvszPayQa
9DFdf6UwMqkjAQvWqPOhuhkfIdN7QI0glOEM17DjgdKKARVXIXj2fn6EeMTvATj9
olgyPlWs43sbp8k/OVP4EnyqqCkpXBIEnKLi2//hojbwtHfB1SR2mgDF9rvmKtk3
SuASRalp1P9LJPXmbFPH/dnQVteE+IOCbUg+Q8N3felyipUQvuiX7g6K+B+HCNTq
jNjSD+ZbGozJrz5vtbBzPUcfBsapAY083/Yca0oZyK83NA8Z6K0xaBQ1Aj58+w0o
GGnlFCIIAqDGpqkTwrCTQiNWrlF0+EJvV+CR5oHU/TlOR00otTe98DK8Fvljdwk3
pRxEs3wpv1zu3L7Dp7NUst84K8+7n7SpTNitd9OnqsINhH+eBvVB3DekOmg+VnrJ
ZKCOfZ3QXSgSe9S8BLKyP0qUppqjAKxDdkJalHAUFC8p9w/BuYZXpmH+HhQ6ugJs
h/ekgD23Tpqq3mcC4GSZQ+ODFEK9B/+PfxWSgIp7j103djrSkG4jcTho9xqeRpQj
B4kes+C32NWENvUZH9njEjjTqWHxT/4W1LPsHAUedrJWg8gVaIzGcgJrQzIkBHYm
L1B7iT//ZWR1o1AiuUz5JzT3gzH2rqgWiH3TXIJ/bjA0eiejQrwC1w3FtPcz/BC0
0Mr37AuPOfWOK+eYIsnn
=6Xh4
-----END PGP SIGNATURE-----

--Sig_/6dNYcMkOevjJGJJO7vt0dpZ--
