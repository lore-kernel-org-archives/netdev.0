From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warnings after merge of the net-next tree
Date: Sat, 20 Jun 2015 23:12:55 +1000
Message-ID: <20150620231255.320ed133@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/3Y30uONJHUyOT8BM8n=cysH"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/3Y30uONJHUyOT8BM8n=cysH
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (i386 defconfig)
produced these warnings:

In file included from include/net/netfilter/nf_conntrack_tuple.h:13:0,
                 from include/linux/netfilter/nf_conntrack_dccp.h:28,
                 from include/net/netfilter/nf_conntrack.h:22,
                 from net/netfilter/nf_conntrack_core.c:37:
include/linux/netfilter/x_tables.h: In function 'xt_percpu_counter_alloc':
include/linux/netfilter/x_tables.h:373:10: warning: cast from pointer to in=
teger of different size [-Wpointer-to-int-cast]
   return (__force u64) res;
          ^
include/linux/netfilter/x_tables.h: In function 'xt_percpu_counter_free':
include/linux/netfilter/x_tables.h:381:15: warning: cast to pointer from in=
teger of different size [-Wint-to-pointer-cast]
   free_percpu((void __percpu *) pcnt);
               ^
In file included from include/asm-generic/percpu.h:6:0,
                 from arch/x86/include/asm/percpu.h:551,
                 from arch/x86/include/asm/preempt.h:5,
                 from include/linux/preempt.h:64,
                 from include/linux/spinlock.h:50,
                 from include/linux/mm_types.h:8,
                 from include/linux/kmemcheck.h:4,
                 from include/linux/skbuff.h:18,
                 from include/linux/netfilter.h:5,
                 from net/netfilter/nf_conntrack_core.c:16:
include/linux/netfilter/x_tables.h: In function 'xt_get_this_cpu_counter':
include/linux/netfilter/x_tables.h:388:23: warning: cast to pointer from in=
teger of different size [-Wint-to-pointer-cast]
   return this_cpu_ptr((void __percpu *) cnt->pcnt);
                       ^
include/linux/percpu-defs.h:206:47: note: in definition of macro '__verify_=
pcpu_ptr'
  const void __percpu *__vpp_verify =3D (typeof((ptr) + 0))NULL; \
                                               ^
include/linux/percpu-defs.h:239:27: note: in expansion of macro 'raw_cpu_pt=
r'
 #define this_cpu_ptr(ptr) raw_cpu_ptr(ptr)
                           ^
include/linux/netfilter/x_tables.h:388:10: note: in expansion of macro 'thi=
s_cpu_ptr'
   return this_cpu_ptr((void __percpu *) cnt->pcnt);
          ^

and many more.

Introduced by commit:

  71ae0dff02d7 ("netfilter: xtables: use percpu rule counters")

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/3Y30uONJHUyOT8BM8n=cysH
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVhWbdAAoJEMDTa8Ir7ZwVIF4P+QGzBqSFmPdovvINko2rpLF1
l1/bQ/+vh+IqVlG453Gl+xhcjG7ENjvJ97/11Yo7kd2WFg10cCEmS0x5WzXxrvpF
8Lj729cEcFGv8CDf6nYMC/QWwkOe4Ee5mDpgeTcnt/6lEsdBy0IHAbi7X+Plle4p
QZ2X8jceQkFJb1gG+YmUX4MDrPV2OlPDZ7CdACSB52UvdCwASK3D2akE/9B9cACe
aFVt5nbGY2Liap+uEk4sR3N8sceCSY5xnyd9zW0/9JILaCrX2O0wKhSdEM0WCQXW
8vO2BwWXzKvsYUVwt8RnuSzdde59nQCZJPFwzLy0OOf2TR9PHwHlC6xUQ6Mz4TB/
1Wwd2tBkFcN0nj4hyZQJbN2ZoHEL9IInSNXNHxg+B2S0CLoTy1qWM+6QdKhWcUV2
CfZ81xkBZHuK1l/YXSdDT3vlR4Vvh+XWlm2OWic6JbPs4s1qRBEar0QVI6wi3DLB
zu2Xs4WnYrntEt7yV9JuuYggGsyNroFJUvYva24tT8J9SqgFFixCD+deVz2j7AyC
tMRKKzudqSfiF0w1jhrFGApMzzy3MMhyKH6EgDZemQ+3EpcDAoz8kR9dU+x9yvyn
Q4Ap5UWL0XpGWzCmah0pMWaJGwIp4a6oEHKgyZHtj7opr0b5pb7+iTaDrthEV6rt
/VGPxo6LusTI4zrQbGEP
=SrfA
-----END PGP SIGNATURE-----

--Sig_/3Y30uONJHUyOT8BM8n=cysH--
