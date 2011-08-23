From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: Re: IPv6 multicast snooping behaviour on 2.6.39-rc2 and later
Date: Tue, 23 Aug 2011 23:04:16 +0900
Message-ID: <4E53B360.8090107@sfc.wide.ad.jp>
References: <4E5367CA.3090005@sfc.wide.ad.jp>  <1314093424.2219.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E539DA8.1070504@sfc.wide.ad.jp> <1314105027.2219.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@web.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:59924 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754879Ab1HWOET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 10:04:19 -0400
In-Reply-To: <1314105027.2219.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tough luck :( Got no love from bridge. It still doesn't work with your =
latest patch. Please keep sending those patches.

On 23/08/11 22:10, Eric Dumazet wrote:
> Le mardi 23 ao=C3=BBt 2011 =C3=A0 21:31 +0900, Ang Way Chuang a =C3=A9=
crit :
>> Sorry for the blurb. I hope I've configured thunderbird properly to
>> send in plain text. Hope you received my reply. I tried your patch o=
n
>> 3.0.3 and it didn't fix the problem.
>
> Thanks for trying !
>
> Ok could you please try following patch then ?
>
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 2d85ca7..e9b32a3 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1497,7 +1497,7 @@ static int br_multicast_ipv6_rcv(struct net_bri=
dge *br,
>   	if (!pskb_may_pull(skb2, offset + sizeof(struct icmp6hdr)))
>   		goto out;
>
> -	len -=3D offset - skb_network_offset(skb2);
> +	len -=3D offset;
>
>   	__skb_pull(skb2, offset);
>   	skb_reset_transport_header(skb2);
> @@ -1520,6 +1520,7 @@ static int br_multicast_ipv6_rcv(struct net_bri=
dge *br,
>   		err =3D pskb_trim_rcsum(skb2, len);
>   		if (err)
>   			goto out;
> +		icmp6h =3D icmp6_hdr(skb2);
>   	}
>
>   	switch (skb2->ip_summed) {
>
>
>

