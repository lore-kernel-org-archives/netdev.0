From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [TCP] Probable bug in icsk_probes_out handling ?
Date: Thu, 24 Jul 2008 07:22:00 +0200
Message-ID: <48881178.3080901@cosmosbay.com>
References: <48873397.5040409@cosmosbay.com> <20080723.163444.165532483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.48]:21568 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbYGXFWx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 01:22:53 -0400
In-Reply-To: <20080723.163444.165532483.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 23 Jul 2008 15:35:19 +0200
>=20
>> Apparently, we can in some situations reset TCP connections in a cou=
ple of seconds when some frames are lost.
>=20
> I think it is some optimization that went in between 2.2.x and 2.4.x
> which took things a little bit too far.
>=20
> Please try this patch:

Yes, this patch solves the problem.=20
I tried a similar patch yesterday but was not sure about its validity.
Thanks a lot David.
=20
>=20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 1f5e604..75efd24 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3292,6 +3292,7 @@ static int tcp_ack(struct sock *sk, struct sk_b=
uff *skb, int flag)
>  	 * log. Something worked...
>  	 */
>  	sk->sk_err_soft =3D 0;
> +	icsk->icsk_probes_out =3D 0;
>  	tp->rcv_tstamp =3D tcp_time_stamp;
>  	prior_packets =3D tp->packets_out;
>  	if (!prior_packets)
> @@ -3324,8 +3325,6 @@ static int tcp_ack(struct sock *sk, struct sk_b=
uff *skb, int flag)
>  	return 1;
> =20
>  no_queue:
> -	icsk->icsk_probes_out =3D 0;
> -
>  	/* If this ack opens up a zero window, clear backoff.  It was
>  	 * being used to time the probes, and is probably far higher than
>  	 * it needs to be for normal retransmission.




