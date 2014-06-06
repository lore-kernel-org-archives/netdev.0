From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 6 Jun 2014 13:54:38 +1000
Message-ID: <20140606135438.06d7b7a5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/xGsEp6NUHLEeZz8uk9qM=Ag"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/xGsEp6NUHLEeZz8uk9qM=Ag
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/core/filter.c between commit 0dcceabb0c1b ("net: filter: fix
SKF_AD_PKTTYPE extension on big-endian") from the net tree and commit
9739eef13c92 ("net: filter: make BPF conversion more readable") from
the net-next tree.

I fixed it up (not well, but see below) and can carry the fix as
necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/core/filter.c
index ab3c74e49f07,9de0c25323b4..000000000000
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@@ -685,17 -684,7 +688,14 @@@ static bool convert_bpf_extensions(stru
  		if (insn->off < 0)
  			return false;
  		insn++;
-=20
- 		insn->code =3D BPF_ALU | BPF_AND | BPF_K;
- 		insn->a_reg =3D A_REG;
- 		insn->imm =3D PKT_TYPE_MAX;
+ 		*insn =3D BPF_ALU32_IMM(BPF_AND, BPF_REG_A, PKT_TYPE_MAX);
 +#ifdef __BIG_ENDIAN_BITFIELD
 +		insn++;
 +
 +		insn->code =3D BPF_ALU | BPF_RSH | BPF_K;
 +		insn->a_reg =3D A_REG;
 +		insn->imm =3D 5;
 +#endif
  		break;
 =20
  	case SKF_AD_OFF + SKF_AD_IFINDEX:

--Sig_/xGsEp6NUHLEeZz8uk9qM=Ag
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTkTuHAAoJEMDTa8Ir7ZwV06YP/3Y0xFPyuk+lSkWbdAHtUKT1
Mo372rbFZvmtwZ2jlyS6ql4p0HgGOuv9W/hLsiLjmsI6rxfDPYGMp+n38M6Gobt9
PwYvImST+B5eC6uBB1G0OCQWMbga9sCEozx8jPgSu7U1AzkouYFnhXVlcaZgyiDR
kQEXqO/Rw/ZPSUzEsg4CTs0d2JjYvP5ldmKVKXs7Ed1cERpZXz342z9YxeEYaRYz
temYrvzMo/aT1VtPVj6nC06dmTZn3zo+5IGBFh7pvtMzXe4uXDB7Lc9NI2ccPA24
SwqxWP22mczGFVOki1nNY/7wjjZpe2P8bGm3XHrBNshzzY3RqqcbD4bpkesTGFnn
630io8VOrF8yzHoe0q1HDpeOATyCj2ke1sac+jZUvHxozMniIlI6jSjs7JLh0ERG
vaDpP9mjcHajYRNsLdFCDIqqbbsdAOl3a/6wRTLnHrHnmAbqXVwNUdZY785/z9wb
DibvG5BEYkxY7OP4HvFyjp6E8gxmZ2LXTcOM+yiehNB3fAe5bX6waGGdFbQR1Esu
Xd2CT5ueMsQpW9I/CVjARemROoYk/toWTuGya2c+hePArMz+l1uZWQwmrSz7XU6r
v0EzmyXuUOStuMAFSvwtuPvNpjLwzdzPm+VKSyur5kbHeQhNMzDqS5XdsESPDK7y
KqZ06/LloaMHjGLCd9OP
=Dtsn
-----END PGP SIGNATURE-----

--Sig_/xGsEp6NUHLEeZz8uk9qM=Ag--
