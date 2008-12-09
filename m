From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [RFC][PATCH 3/3]ipv6:fix the outgoing interface selection order in udpv6_sendmsg()
Date: Tue, 9 Dec 2008 09:32:56 +0200
Message-ID: <200812090932.56865.remi.denis-courmont@nokia.com>
References: <493E1A7B.9070208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: "ext Yang Hongyang" <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:26554 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbYLIHdQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 02:33:16 -0500
In-Reply-To: <493E1A7B.9070208@cn.fujitsu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 09 December 2008 09:12:59 ext Yang Hongyang, you wrote:
> 1.When no interface is specified in an IPV6_PKTINFO ancillary data
>   item, the interface specified in an IPV6_PKTINFO sticky optionis
>   is used.

> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 8b48512..addd856 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -761,6 +761,9 @@ do_udp_sendmsg:
>  	}
>
>  	if (!fl.oif)
> +		fl.oif =3D np->sticky_pktinfo.ipi6_ifindex;
> +
> +	if (!fl.oif)
>  		fl.oif =3D sk->sk_bound_dev_if;
>
>  	if (msg->msg_controllen) {

I believe overriding the outgoing interface is only allowed for link-lo=
cal=20
destinations, _or_ with privileges (as with SO_BINDTODEVICE).

This patch seems to change this, and I am not convinced it's a good ide=
a.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
