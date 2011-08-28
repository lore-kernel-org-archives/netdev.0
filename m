From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: relax PKTINFO non local ipv6 udp xmit check
Date: Sun, 28 Aug 2011 17:11:54 -0400 (EDT)
Message-ID: <20110828.171154.1746224796788156557.davem@davemloft.net>
References: <1314395788-20179-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	ek@google.com, lorenzo@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab1H1VNA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2011 17:13:00 -0400
In-Reply-To: <1314395788-20179-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Fri, 26 Aug 2011 14:56:28 -0700

> diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
> index f3caf1b..a896987 100644
> --- a/net/ipv6/ip6_flowlabel.c
> +++ b/net/ipv6/ip6_flowlabel.c
> @@ -360,7 +360,7 @@ fl_create(struct net *net, struct in6_flowlabel_r=
eq *freq, char __user *optval,
>  		msg.msg_control =3D (void*)(fl->opt+1);
>  		memset(&flowi6, 0, sizeof(flowi6));
> =20
> -		err =3D datagram_send_ctl(net, &msg, &flowi6, fl->opt, &junk,
> +		err =3D datagram_send_ctl(net, NULL, &msg, &flowi6, fl->opt, &junk=
,
>  					&junk, &junk);
>  		if (err)
>  			goto done;

There is a socket associated with this fl_create() request, please
pass it into fl_create() from it's caller, and thus down into
datagram_send_ctl(), instead of just passing NULL.

Then, since a valid sk is always passed in, you can elide the NULL
check on 'sk' down at the bottom of these code paths.

Thanks.
