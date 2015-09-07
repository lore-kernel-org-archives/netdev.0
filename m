From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Mon, 7 Sep 2015 10:50:23 +0200
Message-ID: <20150907085023.GA17511@calimero.vinschen.de>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
 <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de>
 <55ED391C.2090906@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="gBBFr7Ir9EOA20Yy"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Benedikt Meurer <benedikt.meurer@unix-ag.uni-siegen.de>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:55281 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753966AbbIGIu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 04:50:27 -0400
Content-Disposition: inline
In-Reply-To: <55ED391C.2090906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  7 09:13, poma wrote:
> On 06.09.2015 12:19, Corinna Vinschen wrote:
> > On Sep  4 22:59, Francois Romieu wrote:
> >>  Applies against davem's net as of f1ccbfce2fc787981d1182d09c1f6b67766=
783a8.
> >>
> >>  drivers/net/ethernet/realtek/r8169.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethern=
et/realtek/r8169.c
> >> index 24dcbe6..56829ea 100644
> >> --- a/drivers/net/ethernet/realtek/r8169.c
> >> +++ b/drivers/net/ethernet/realtek/r8169.c
> >> @@ -2200,7 +2200,7 @@ static struct rtl8169_counters *rtl8169_map_coun=
ters(struct net_device *dev,
> >>  	struct rtl8169_counters *counters;
> >>  	u32 cmd;
> >> =20
> >> -	counters =3D dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_KER=
NEL);
> >> +	counters =3D dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_ATO=
MIC);
> >>  	if (counters) {
> >>  		RTL_W32(CounterAddrHigh, (u64)*paddr >> 32);
> >>  		cmd =3D (u64)*paddr & DMA_BIT_MASK(32);
> >> --=20
> >> 2.4.3
> > [...]
> 1. Reverted to r8169.c?id=3Deb78139
>    - the noise is still present
> 2. Patches applied - Francois Romieu (3):
>    r8169: decouple the counters data and the device private area.
>    r8169: move rtl_reset_counters_cond before the hardware counters helpe=
rs.
>    r8169: increase the lifespan of the hardware counters dump area.
>    - the noise is still present

Sure you tested the right code?  I'm just asking because...

> [   70.016445]  [<ffffffff81847841>] dump_stack+0x4b/0x63
> [   70.016456]  [<ffffffff811008c7>] lockdep_rcu_suspicious+0xd7/0x110
> [   70.016465]  [<ffffffff810d5297>] ___might_sleep+0xa7/0x230
> [   70.016472]  [<ffffffff810d5469>] __might_sleep+0x49/0x80
> [   70.016481]  [<ffffffff811e54ce>] __alloc_pages_nodemask+0x2fe/0xb90
> [   70.016490]  [<ffffffff8112197d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
> [   70.016499]  [<ffffffff81024ab9>] ? sched_clock+0x9/0x10
> [   70.016507]  [<ffffffff810e24ac>] ? local_clock+0x1c/0x20
> [   70.016514]  [<ffffffff8112197d>] ? debug_lockdep_rcu_enabled+0x1d/0x20
> [   70.016524]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
> [   70.016534]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
> [   70.016541]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
> [   70.016555]  [<ffffffffa003525e>] rtl8169_map_counters+0x3e/0x70 [r816=
9]

=2E..rtl8169_map_counters only exists before Francois patch.  The patch
removes this function.


Corinna

--gBBFr7Ir9EOA20Yy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV7U/PAAoJEPU2Bp2uRE+gv6YP/RSm4cQQcttKxofMqZeNcroH
JjhukUdYczgKR6kFnFIYmwCbuRaUOkkxMjfzjn+lRwGonpB1sDvLa3ZDG0kiALZt
jekjYMohlLmYgdUirH04afZjqJE48ldyP9mSojz8cg2REg8GEvZi0sY39TLkoPmD
GqdyaW0j+GWy/TiFOCc0HhjhQCjsKPEvelSRFLPKYO70RCy7mbsVgkWNENfZMWtI
tASp60WKmsI6ti957pHdgXq6zMmxOOln4+P1ifW8qfOwU6GcOB/h673wBiiUq/Oh
PXx1Yl3Vskp7CRKVXTro9c76nuTCGLfxS3hcupx6iVGPTooiD6MCNiShk4NvlInQ
/AMpSQ9FecG40LWT9hSFs5Ei6MXyKuB5ZOY9gozl9ePsN1oKrm7d7i4RuvIkIr91
ew+TOrkcKH2VEX5Coe99MwNen9TeiGzrBlOT7d+O9hJl2cYpjquRBMtpYD5lI8H/
r0aGcEodJVdstLyECd0BhFdDTD9OX9lSNDiGZuO4p5j9O8culcnmLKBP/xtCy3GS
8IetbT1YwFM0mp8kIgDbKGKmlobmUa7xYCW24E0rZWBLIIsbp/f2rM8AnUU8k8fQ
J9nsN/CVHNHXjGXMa7O8aLQwpq7wwm29vpkOq8GKXmBHp7JW7vlFhMUbimK5M0zS
5XWvswNA/PsooxlHk94p
=UVPs
-----END PGP SIGNATURE-----

--gBBFr7Ir9EOA20Yy--
