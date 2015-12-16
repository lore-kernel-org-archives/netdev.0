From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ipv6: add IPV6_HDRINCL option for raw sockets
Date: Wed, 16 Dec 2015 11:01:55 -0800
Message-ID: <1450292515.23587.6.camel@perches.com>
References: <1450282967-3184-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0220.hostedemail.com ([216.40.44.220]:54905 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752692AbbLPTCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 14:02:05 -0500
In-Reply-To: <1450282967-3184-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-16 at 17:22 +0100, Hannes Frederic Sowa wrote:
> Same as in Windows, we miss IPV6_HDRINCL for SOL_IPV6 and SOL_RAW.
> The SOL_IP/IP_HDRINCL is not available for IPv6 sockets.
[]
> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
[]
> @@ -972,6 +972,11 @@ static int do_rawv6_setsockopt(struct sock *sk,
> int level, int optname,
> =A0		return -EFAULT;
> =A0
> =A0	switch (optname) {
> +	case IPV6_HDRINCL:
> +		if (sk->sk_type !=3D SOCK_RAW)
> +			return -EINVAL;
> +		inet_sk(sk)->hdrincl =3D !!val;

trivia:

ipv4/sockglue.c uses the ternary '? 1 : 0' convention for this.
It might be nicer to be consistent.

Then again sockglue.c is inconsistent about that too.

net/ipv4/ip_sockglue.c:736:		inet->hdrincl =3D val ? 1 : 0;
net/ipv4/ip_sockglue.c:743:		inet->nodefrag =3D val ? 1 : 0;
net/ipv4/ip_sockglue.c:746:		inet->bind_address_no_port =3D val ? 1 : 0=
;
net/ipv4/ip_sockglue.c:754:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0inet-=
>recverr =3D !!val;
net/ipv4/ip_sockglue.c:772:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0inet-=
>mc_loop =3D !!val;
net/ipv4/ip_sockglue.c:1123:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0inet->f=
reebind =3D !!val;

There's no change to object code either way.
