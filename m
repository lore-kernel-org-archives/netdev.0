From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Replace time wait bucket msg by counter.
Date: Sat, 04 Dec 2010 22:52:48 +0100
Message-ID: <1291499568.2806.100.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1012041331220.6278@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51151 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753491Ab0LDVwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 16:52:53 -0500
Received: by wyb28 with SMTP id 28so10739097wyb.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 13:52:52 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1012041331220.6278@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 d=C3=A9cembre 2010 =C3=A0 13:35 -0800, Tom Herbert a =C3=A9=
crit :
> Rather than printing the message to the log, use a mib counter to kee=
p
> track of the count of occurences of time wait bucket overflow.  Reduc=
es
> spam in logs.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

> =20
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index 43cf901..3052a2b 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -347,7 +347,7 @@ void tcp_time_wait(struct sock *sk, int state, in=
t timeo)
>  		 * socket up.  We've got bigger problems than
>  		 * non-graceful socket closings.
>  		 */
> -		LIMIT_NETDEBUG(KERN_INFO "TCP: time wait bucket table overflow\n")=
;
> +		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPTIMEWAITOVERFLOW);
>  	}
> =20
>  	tcp_update_metrics(sk);

NET_INC_STATS_BH() should be more appropriate, since we are in a
softirq ?





