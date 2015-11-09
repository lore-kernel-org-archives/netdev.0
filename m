From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next ] net: ipv4: memset addr before calling
 copy_to_user()
Date: Mon, 09 Nov 2015 11:09:06 +0100
Message-ID: <1447063746.377490.433562497.7B532277@webmail.messagingengine.com>
References: <20151109065236.GA2271@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Loganaden Velvindron <logan@elandsys.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:48354 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753220AbbKIKJK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2015 05:09:10 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 28FAD203F4
	for <netdev@vger.kernel.org>; Mon,  9 Nov 2015 05:09:07 -0500 (EST)
In-Reply-To: <20151109065236.GA2271@mx.elandsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Nov 9, 2015, at 07:52, Loganaden Velvindron wrote:
> zero addr before calling copy_to_user()
> =20
> Signed-off-by: Loganaden Velvindron <logan@elandsys.com>
> ---
>  net/ipv4/ip_sockglue.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index c3c359a..d7a5a8b 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -1373,6 +1373,7 @@ static int do_ip_getsockopt(struct sock *sk, in=
t
> level, int optname,
>  	case IP_MULTICAST_IF:
>  	{
>  		struct in_addr addr;
> +               memset(&addr, 0, sizeof(addr));
>  		len =3D min_t(unsigned int, len, sizeof(struct in_addr));
>  		addr.s_addr =3D inet->mc_addr;
>  		release_sock(sk);

There is no possibility we leak any unwanted data to user space here.

If you are not sure if sizeof(addr) > sizeof(addr.s_addr) use a
designated initializer:

addr =3D { .s_addr =3D inet->mc_addr };

which clears all other non-initialized elements. But here we are very
certain.

We do not do defensive programming, we try to do logical things, and
only logical things.
=E2=80=94 Eric Dumazet (Thanks to Dan Carpenter.)

Bye,
Hannes
