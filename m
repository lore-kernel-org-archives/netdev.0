From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2 2/7] tcp: use limited socket backlog
Date: Wed, 03 Mar 2010 09:53:53 +0100
Message-ID: <1267606433.2997.4.camel@edumazet-laptop>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
	 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:47472 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426Ab0CCIx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 03:53:57 -0500
Received: by bwz4 with SMTP id 4so842378bwz.28
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 00:53:56 -0800 (PST)
In-Reply-To: <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 mars 2010 =C3=A0 16:36 +0800, Zhu Yi a =C3=A9crit :
> Make tcp adapt to the limited socket backlog change.
>=20
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> ---
>  net/ipv4/tcp_ipv4.c |    6 ++++--
>  net/ipv6/tcp_ipv6.c |    6 ++++--
>  2 files changed, 8 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index c3588b4..4baf194 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1682,8 +1682,10 @@ process:
>  			if (!tcp_prequeue(sk, skb))
>  				ret =3D tcp_v4_do_rcv(sk, skb);
>  		}
> -	} else
> -		sk_add_backlog(sk, skb);
> +	} else if (sk_add_backlog_limited(sk, skb)) {
> +		bh_unlock_sock(sk);
> +		goto discard_and_relse;
> +	}
>  	bh_unlock_sock(sk);
> =20
>  	sock_put(sk);

So no counter is incremented to reflect this loss, sk->sk_drops (local
counter) or SNMP ?


