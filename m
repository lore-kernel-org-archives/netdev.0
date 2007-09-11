From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] include listenq max backlog in /proc/net/tcp and	include
 in tcp_info
Date: Tue, 11 Sep 2007 10:00:21 -0700
Message-ID: <46E6C9A5.8000008@hp.com>
References: <200709102313.QAA01722@tardy.cup.hp.com>	<1189471180.11066.19.camel@w-sridhar2.beaverton.ibm.com> <46E63121.5090607@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:50407 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754311AbXIKRA6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 13:00:58 -0400
In-Reply-To: <46E63121.5090607@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Sridhar Samudrala a =E9crit :
>=20
>> On Mon, 2007-09-10 at 16:13 -0700, Rick Jones wrote:
>>
>>> Return some useful information such as the maximum listen backlog a=
nd
>>> the current listen backlog in the tcp_info structure and have that=20
>>> match what one can see in /proc/net/tcp and /proc/net/tcp6.
>>
>>
>> If we are also exporting max listen backlog, another place to
>> consider adding this is to tcp_diag_get_info() called via INET_DIAG_=
INFO.
>> Current listen backlog is returned in inet_diag_msg->idiag_rqueue.
>> max listen backlog can be returned in inet_diag_msg->idiag_wqueue.
>>
>=20
> I agree, /proc/net/tcp is deprecated nowadays...

What takes its place?

> Rick, could you add this part in your patch, and add my Sign-off-by ?

My pleasure.

I have a small test program for the tcp_info bit - where do I go to fin=
d=20
how the inet diag stuff works?

BTW, what do people think about doing the same thing with the rxqueue=20
and txqueue's of netstat output?

rick jones

>=20
> Thank you
> Eric
>=20
>=20
>=20
>=20
> ---------------------------------------------------------------------=
---
>=20
> diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
> index 57c5f0b..f5b6275 100644
> --- a/net/ipv4/tcp_diag.c
> +++ b/net/ipv4/tcp_diag.c
> @@ -25,11 +25,13 @@ static void tcp_diag_get_info(struct sock *sk, st=
ruct inet_diag_msg *r,
>  	const struct tcp_sock *tp =3D tcp_sk(sk);
>  	struct tcp_info *info =3D _info;
> =20
> -	if (sk->sk_state =3D=3D TCP_LISTEN)
> +	if (sk->sk_state =3D=3D TCP_LISTEN) {
>  		r->idiag_rqueue =3D sk->sk_ack_backlog;
> -	else
> +		r->idiag_wqueue =3D sk->sk_max_ack_backlog;
> +	else {
>  		r->idiag_rqueue =3D tp->rcv_nxt - tp->copied_seq;
> -	r->idiag_wqueue =3D tp->write_seq - tp->snd_una;
> +		r->idiag_wqueue =3D tp->write_seq - tp->snd_una;
> +	}
>  	if (info !=3D NULL)
>  		tcp_get_info(sk, info);
>  }

