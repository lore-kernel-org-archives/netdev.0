From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Sun, 6 Sep 2015 12:19:54 +0200
Message-ID: <20150906101954.GE30539@calimero.vinschen.de>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
 <20150904205904.GA32346@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="VV4b6MQE+OnNyhkM"
Cc: David Miller <davem@davemloft.net>, pomidorabelisima@gmail.com,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:47265 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbbIFKT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 06:19:58 -0400
Content-Disposition: inline
In-Reply-To: <20150904205904.GA32346@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--VV4b6MQE+OnNyhkM
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  4 22:59, Francois Romieu wrote:
> net/core/net-sysfs.c::netstat_show fetches statistics under dev_base_lock.
>=20
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=3D104031
> Fixes: 6e85d5ad36a2 ("r8169: Add values missing in @get_stats64 from HW c=
ounters")
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Corinna Vinschen <vinschen@redhat.com>
> ---
>=20
>  Applies against davem's net as of f1ccbfce2fc787981d1182d09c1f6b67766783=
a8.
>=20
>  drivers/net/ethernet/realtek/r8169.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/=
realtek/r8169.c
> index 24dcbe6..56829ea 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -2200,7 +2200,7 @@ static struct rtl8169_counters *rtl8169_map_counter=
s(struct net_device *dev,
>  	struct rtl8169_counters *counters;
>  	u32 cmd;
> =20
> -	counters =3D dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_KERNEL=
);
> +	counters =3D dma_alloc_coherent(d, sizeof(*counters), paddr, GFP_ATOMIC=
);
>  	if (counters) {
>  		RTL_W32(CounterAddrHigh, (u64)*paddr >> 32);
>  		cmd =3D (u64)*paddr & DMA_BIT_MASK(32);
> --=20
> 2.4.3

I'll have a look tomorrow what I'm back to work, but for the time
being, two questions.

- The code worked for me in local testing without problem, so I'm rather
  puzzled.  How can I reproduce the problem?

- I'm pretty new to this stuff, so I don't understand this:

  The dma_alloc_coherent(...,GFP_KERNEL) call is not new in the code,
  it's there since at least 2010.  It appears to work fine in the
  context of @get_ethtool_stats.  Why does this not work in the context
  of @ndo_get_stats64?


Thanks,
Corinna

--VV4b6MQE+OnNyhkM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV7BNKAAoJEPU2Bp2uRE+gdR4P/2QSlSX/uocbQFVF/A1PN/4g
K2zi3y7evFk8QQmdqfPZ+MtlGO7QCv2YVGBo1xLiNRdllt/dG7It2VvthLSd5l/A
pGb9KOMPmBJUpUVyUyLgvb0VDHraNu6hO8aq2vkJ/2KEJo+xFwp/1PrbTMS+ivxZ
JJXquZc8qHLIY6e51mR9sB4indHpf7tnUlJ7D9TNzjld6EleSL0aKiO8KjFz8BmR
3wL9VMIqJ1y3yu/qC8W5WI4e/OerK8f+dJmt+GirVVCIVWcfmdWFjUGw5nJo6F6N
aEZ9+fG2XSsnA5f/Uljw9haLU1sxIghlblEeuRUYpYBcq8o7dAGHpRjbqT/mv29b
f3l+Q/A2mhQfCdEVCXL7Bkw2NEkD5gPlmOs+4dKCvQiVWTzWt4W7z64DYZl33fRG
9hV7GwUspnDDg0rXLZBRrCPlEk6pjfLITcoU+1mF8auCvqOooK33/yXro6bhD5mH
Tfggx/IivmP4DTBlFMJ04JvZaxWN8GBu0rzyRZRZyawNxc50fdO7w8fI6KCuDObw
4Xx8OoAJOGRReK8mpHpYE0hHbby4hsEAfqq74dSmJoMovArY6uIcrhD2ouQSMnmU
KIN8XCMkzjjyLjc1uAMIBUOOiG89nmxnIVvdydtwo8GhUOhev9KTTjD6TqmJKUei
PjqXGXbhx+GDTC5I21Vm
=LokG
-----END PGP SIGNATURE-----

--VV4b6MQE+OnNyhkM--
