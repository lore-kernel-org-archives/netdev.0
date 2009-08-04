From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: 2.6.31-rc5-git2 crash [net/core/flow.c:flow_cache_new_hashrnd]
Date: Wed, 05 Aug 2009 00:15:50 +1000
Message-ID: <1249395350.8016.5.camel@concordia>
References: <4A78292A.5000607@in.ibm.com>  <4A783B1F.7000602@in.ibm.com>
Reply-To: michael@ellerman.id.au
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5678333960662027060=="
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	linuxppc-dev@ozlabs.org
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <4A783B1F.7000602@in.ibm.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org


--===============5678333960662027060==
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-c/6DjyA9naNp3wCGmgoS"


--=-c/6DjyA9naNp3wCGmgoS
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-08-04 at 19:13 +0530, Sachin Sant wrote:
> Forgot to copy netdev in my original message. Forwarding ..
>=20
> I have a power6 blade [IBM,7998-61X] running 2.6.31-rc5-git2
> kernel (a33a052f19a21d727847391c8c1aff3fb221c472). After some
> period of inactivity the machine drops into xmon with following
> traces.
>=20
> cpu 0x0: Vector: 700 (Program Check) at [c00000000ffffa90]
>    pc: c000000000600000: .flow_cache_new_hashrnd+0x3c/0xcc
>    lr: c0000000000c6038: .run_timer_softirq+0x20c/0x2f4
>    sp: c00000000ffffd10
>   msr: 8000000000089032
>  current =3D 0xc000000000f58b70
>  paca    =3D 0xc0000000010b2400
>    pid   =3D 0, comm =3D swapper
> enter ? for help
> [c00000000ffffda0] c0000000000c6038 .run_timer_softirq+0x20c/0x2f4
> [c00000000ffffea0] c0000000000be8a0 .__do_softirq+0x174/0x2c8
> [c00000000fffff90] c0000000000307b0 .call_do_softirq+0x14/0x24
> [c000000001013870] c00000000000ecf8 .do_softirq+0xa0/0x104
> [c000000001013910] c0000000000be1d0 .irq_exit+0x74/0xd4
> [c000000001013990] c00000000002ce20 .timer_interrupt+0x1cc/0x200
> [c000000001013a30] c000000000003728 decrementer_common+0x128/0x180
> --- Exception: 901 (Decrementer) at c00000000000ec3c .raw_local_irq_resto=
re+0xc0/0xdc
> [c000000001013dc0] c000000000015824 .cpu_idle+0x13c/0x1e0
> [c000000001013e60] c000000000009fe8 .rest_init+0x94/0xcc
> [c000000001013ee0] c000000000990cf4 .start_kernel+0x484/0x4a8
> [c000000001013f90] c000000000008408 .start_here_common+0x2c/0xa4
> 0:mon> di $.flow_cache_new_hashrnd
> c0000000005fffc4  7c0802a6      mflr    r0
> c0000000005fffc8  f8010010      std     r0,16(r1)
> c0000000005fffcc  fb81ffe0      std     r28,-32(r1)
> c0000000005fffd0  fba1ffe8      std     r29,-24(r1)
> c0000000005fffd4  fbc1fff0      std     r30,-16(r1)
> c0000000005fffd8  fbe1fff8      std     r31,-8(r1)
> c0000000005fffdc  f821ff71      stdu    r1,-144(r1)
> c0000000005fffe0  7c3f0b78      mr      r31,r1
> c0000000005fffe4  ebc2dc90      ld      r30,-9072(r2)
> c0000000005fffe8  3b800001      li      r28,1
> c0000000005fffec  60000000      nop
> ...
> c0000000005ffff4  e93e8048      ld      r9,-32696(r30)
> c0000000005ffff8  38a0ffff      li      r5,-1
> c0000000005ffffc  eba90000      ld      r29,0(r9)
> c000000000600000  00001010      .long 0x1010
> 0:mon>
> c000000000600004  00000008      .long 0x8
> c000000000600008  00001013      .long 0x1013
> c00000000060000c  0000000f      .long 0xf
> c000000000600010  7961626f      rldimi. r1,r11,44,41
> c000000000600014  6f740000      xoris   r20,r27,0
> c000000000600018  00101600      .long 0x101600
> c00000000060001c  00000c00      .long 0xc00
> c000000000600020  00000400      .long 0x400
> c000000000600024  00101100      .long 0x101100
> c000000000600028  000008e9      .long 0x8e9

What's going on here? How does the above disassembly compare with an
objdump -d of your vmlinux?

It looks like either:
      * gcc is generating some weird code sequences
      * xmon doesn't know how to disassemble those instructions
      * someone crapped on your kernel text

cheers


--=-c/6DjyA9naNp3wCGmgoS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkp4QpIACgkQdSjSd0sB4dKbJQCgxLmN1soiVk76X3gG07D06zC0
2g8AmgPkbKRWvfwRjItJns6GQqXUpLb8
=3aqg
-----END PGP SIGNATURE-----

--=-c/6DjyA9naNp3wCGmgoS--


--===============5678333960662027060==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-dev mailing list
Linuxppc-dev@lists.ozlabs.org
https://lists.ozlabs.org/listinfo/linuxppc-dev
--===============5678333960662027060==--
