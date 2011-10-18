From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] route:ip_rt_frag_needed always return unzero
Date: Tue, 18 Oct 2011 11:23:17 +0200
Message-ID: <1318929797.2657.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:57810 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460Ab1JRJW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 05:22:58 -0400
Received: by yxp4 with SMTP id 4so377165yxp.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 02:22:57 -0700 (PDT)
In-Reply-To: <1318921469-25599-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 15:04 +0800, Gao feng a =C3=A9crit :
> int function ip_rt_frag_need,if peer is null,
> there is no need to do ipprot->err_handler.
> I am right?
>=20
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/ipv4/route.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 075212e..6cde0fa 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1574,7 +1574,7 @@ unsigned short ip_rt_frag_needed(struct net *ne=
t, const struct iphdr *iph,
> =20
>  		atomic_inc(&__rt_peer_genid);
>  	}
> -	return est_mtu ? : new_mtu;
> +	return est_mtu;
>  }
> =20
>  static void check_peer_pmtu(struct dst_entry *dst, struct inet_peer =
*peer)

No idea why you want this, your changelog is a bit cryptic :)

Wont this bypass the raw_icmp_error(skb, protocol, info);
call in icmp_unreach() as well ?
