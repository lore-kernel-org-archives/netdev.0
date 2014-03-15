From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next 16/16] sfc: Don't receive packets when the napi
 budget == 0
Date: Sat, 15 Mar 2014 15:23:34 +0000
Message-ID: <1394897014.15764.26.camel@deadeye.wl.decadent.org.uk>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	 <20140311.124907.1180556684992271103.davem@davemloft.net>
	 <87wqg0cy9d.fsf@xmission.com>
	 <20140311.160931.1395978386605601765.davem@davemloft.net>
	 <877g808luk.fsf_-_@xmission.com> <871ty41dps.fsf_-_@xmission.com>
	 <87lhwcw9j9.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-uZDuKjxXUMC3t+yoCblM"
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43158 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755091AbaCOPXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2014 11:23:43 -0400
In-Reply-To: <87lhwcw9j9.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uZDuKjxXUMC3t+yoCblM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 18:11 -0700, Eric W. Biederman wrote:
> Processing any incoming packets with a with a napi budget of 0
> is incorrect driver behavior.
>=20
> This matters as netpoll will shortly call drivers with a budget of 0
> to avoid receive packet processing happening in hard irq context.

But this also prevents handling TX completions, at which point you may
as well change efx_netpoll() to a no-op.  And then, does it make sense
to implement ndo_poll_controller at all?

Note that sfc does have a module parameter to enable separate RX and TX
completions so they could be polled separately, but it is disabled by
default.

Ben.

> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/sfc/ef10.c  |    3 +++
>  drivers/net/ethernet/sfc/farch.c |    3 +++
>  2 files changed, 6 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/e=
f10.c
> index eb75675f6e32..651626e133f9 100644
> --- a/drivers/net/ethernet/sfc/ef10.c
> +++ b/drivers/net/ethernet/sfc/ef10.c
> @@ -1955,6 +1955,9 @@ static int efx_ef10_ev_process(struct efx_channel *=
channel, int quota)
>  	int tx_descs =3D 0;
>  	int spent =3D 0;
> =20
> +	if (quota <=3D 0)
> +		return spent;
> +
>  	read_ptr =3D channel->eventq_read_ptr;
> =20
>  	for (;;) {
> diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/=
farch.c
> index aa1b169f45ec..a08761360cdf 100644
> --- a/drivers/net/ethernet/sfc/farch.c
> +++ b/drivers/net/ethernet/sfc/farch.c
> @@ -1248,6 +1248,9 @@ int efx_farch_ev_process(struct efx_channel *channe=
l, int budget)
>  	int tx_packets =3D 0;
>  	int spent =3D 0;
> =20
> +	if (budget <=3D 0)
> +		return spent;
> +
>  	read_ptr =3D channel->eventq_read_ptr;
> =20
>  	for (;;) {

--=20
Ben Hutchings
When you say `I wrote a program that crashed Windows', people just stare ..=
.
and say `Hey, I got those with the system, *for free*'. - Linus Torvalds

--=-uZDuKjxXUMC3t+yoCblM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyRwdue/yOyVhhEJAQom3Q/9Hk5IYtjZhvfltR2FgZPD/9lmteZDFEVS
uncLE1Bxs/6fwqmwojkPP0zxUq6iSVunfCkntZO6hcnlS2TIpi3LMVvridnqzLt9
bIFRVJjMuZpyKM6eSA4QcfkOLUYtRbraJtpNbyp3cBKQ38bhll3rBPV5/sRtKvJz
g9xhEPsGzQIvvztnEUT7OsoYatLd/PzEnx/mJ7oCG6TPJ8P1WmfE1dPh6Zt2iz2T
5QsnItn6i6Z5waYpEA5vTk4pW/iGkJMKfx6rlGMS02RP3Yvac+1BCQ5NnxwVHTs/
nyX/wgNSUi8McDNsxZ3WWtsqxAyhLgvrrpRet7OapRITM8K1vIrIZk+Rvn0/OzlC
8qa5lfBOtUb6nZRUWcbTjc/jlvA4xsqXA3jB0LKXTL3Cg3s53KPN7gknJnY+HLo+
c9x6VkhTNitYx898D5zzSQrFijFuJT9eqjsTqmGjCS3zILOrkBW5bjKXOYJoKH8k
TG8ClEQYhIiWM3xadYL3PqIHS9KSYEue4hk2PJxZ/pzJm1g18Oj4S2Chjr9sgDY/
ycIIaCze3VldKoQmAsmekE9BX7zLBJMwIgdHrh/7lGL4ifvBbVb6w0Tpzzo/gI/4
//sKNovExtsYyKZ2aSQ/lKy0Y8+pOBBIlHwz4QFHQJBGMcmvn+msHN9WF5hI0Gd4
2x7Xrm3FGxg=
=rqun
-----END PGP SIGNATURE-----

--=-uZDuKjxXUMC3t+yoCblM--
