From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Tue, 21 May 2013 14:25:37 +1000
Message-ID: <20130521142537.00a9ccb7ca4aa81f553b61cf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__21_May_2013_14_25_37_+1000_czuMkj7p2T1jaBgU"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <dborkman@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Nicolas Schichan <nschichan@freebox.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__21_May_2013_14_25_37_+1000_czuMkj7p2T1jaBgU
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
arch/arm/net/bpf_jit_32.c between commit aafc787e41fd ("arm: bpf_jit: can
call module_free() from any context") from the net-next tree and commit
"ARM: net: bpf_jit: make code generation less dependent on struct
sk_filter" from the akpm tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arm/net/bpf_jit_32.c
index f50d223,2dab3e6..0000000
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@@ -926,8 -926,32 +925,21 @@@ out
  	return;
  }
 =20
+ void bpf_jit_compile(struct sk_filter *fp)
+ {
+ 	struct jit_ctx ctx;
+=20
+ 	memset(&ctx, 0, sizeof(ctx));
+ 	ctx.prog_len =3D fp->len;
+ 	ctx.prog_insns =3D fp->insns;
+=20
+ 	__bpf_jit_compile(&ctx);
+ 	if (ctx.target)
+ 		fp->bpf_func =3D (void *)ctx.target;
+ }
+=20
 -static void bpf_jit_free_worker(struct work_struct *work)
 -{
 -	module_free(NULL, work);
 -}
 -
  void bpf_jit_free(struct sk_filter *fp)
  {
 -	struct work_struct *work;
 -
 -	if (fp->bpf_func !=3D sk_run_filter) {
 -		work =3D (struct work_struct *)fp->bpf_func;
 -
 -		INIT_WORK(work, bpf_jit_free_worker);
 -		schedule_work(work);
 -	}
 +	if (fp->bpf_func !=3D sk_run_filter)
 +		module_free(NULL, fp->bpf_func);
  }

--Signature=_Tue__21_May_2013_14_25_37_+1000_czuMkj7p2T1jaBgU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRmvdBAAoJEECxmPOUX5FEf9gP/jDC3ve/SD4oTq4cNKPIX6Yb
bYGgo3+wTae6WPOmzy5nXj6M8hdBow6YtH3rttxefPlUOBTpIybR0MWpmUmO7I0X
gcqm/XidhrDnYiBZRLoT97B9xnrr1LsC/pJaamy2KTHKqd3sksVp+4z0pFURIACV
lZMF5dwu5BLxtCHFsTMYLNw63saiMikVkieFZQ6lqdlPmY8sVvWNIbMPN+qy3FM9
K6ch+P6ugmioNwWtotnokMMy2TShoq79ub54UdkY2fKEVEaPvEXDzfKU0eGjasG0
L07rJsh6MvWqiI0Rx2dYdWRyzNDb/ntL7TK9jFVhklMDkc1PI9P/jLU8l250Gr0u
HEkPczaiAzTdixusk7I2GOYpoNUP6tXfNfu2R2vo1lciaryPNB+RhmcJnxJ8BDRj
tAjdSCnANRVanJc2vREh5YEtZPwW8QhxzgzBUrUmLy2ZPPCHZ+yHQrGgTxlNvHBj
MX2Jbxik/NSIu50WYOCc0qkO0+xIxqV9qMHI9OkH6GstZRnq0W0g7htw2dS3e5iy
/vJogts94Y3Ng7XVRD3yUC+t9HopAkwoJT73JQQTUuseJe6pXLMWBkQDMpP9i1Ge
FdCqZQ724XNC8mwEQCIpgy9/HH2PytblcQPEL+au0i+OaBjiAArq2O57Vdlzct/w
fuOp6hwLVOuVdah6jzil
=eMNV
-----END PGP SIGNATURE-----

--Signature=_Tue__21_May_2013_14_25_37_+1000_czuMkj7p2T1jaBgU--
