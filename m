From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] ip_tunnel: Move stats update to
 iptunnel_xmit()
Date: Thu, 24 Dec 2015 10:21:27 +0100
Message-ID: <567BB917.9090900@6wind.com>
References: <1450914723-16452-1-git-send-email-pshelar@nicira.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34065 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbbLXJVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 04:21:30 -0500
Received: by mail-wm0-f52.google.com with SMTP id l126so173708104wml.1
        for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 01:21:30 -0800 (PST)
In-Reply-To: <1450914723-16452-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/12/2015 00:52, Pravin B Shelar a =C3=A9crit :
[snip]
> diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
> index 6af78c6..d63a911 100644
> --- a/net/tipc/udp_media.c
> +++ b/net/tipc/udp_media.c
> @@ -182,15 +182,9 @@ static int tipc_udp_send_msg(struct net *net, st=
ruct sk_buff *skb,
>   			goto tx_error;
>   		}
>   		ttl =3D ip4_dst_hoplimit(&rt->dst);
> -		err =3D udp_tunnel_xmit_skb(rt, ub->ubsock->sk, skb,
> -					  src->ipv4.s_addr,
> -					  dst->ipv4.s_addr, 0, ttl, 0,
> -					  src->udp_port, dst->udp_port,
> -					  false, true);
> -		if (err < 0) {
> -			ip_rt_put(rt);
> -			goto tx_error;
> -		}
> +		udp_tunnel_xmit_skb(rt, ub->ubsock->sk, skb, src->ipv4.s_addr,
> +				    dst->ipv4.s_addr, 0, ttl, 0, src->udp_port,
> +				    dst->udp_port, false, true);
I don't know how tipc works, but this change is clearly suspect. What m=
ake the
error path not needed anymore after your patch?
