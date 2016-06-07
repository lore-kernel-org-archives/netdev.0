From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: fix configuration passed to
 setup_udp_tunnel_sock()
Date: Tue, 07 Jun 2016 16:20:17 -0700 (PDT)
Message-ID: <20160607.162017.1294730894994990373.davem@davemloft.net>
References: <a8f79b662219b6fdeef7556899051108b9294a15.1465213131.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbcFGXUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:20:23 -0400
In-Reply-To: <a8f79b662219b6fdeef7556899051108b9294a15.1465213131.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Mon, 6 Jun 2016 13:48:02 +0200

> @@ -1581,7 +1581,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
>  	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
>  	tunnel->encap = encap;
>  	if (encap == L2TP_ENCAPTYPE_UDP) {
> -		struct udp_tunnel_sock_cfg udp_cfg;
> +		struct udp_tunnel_sock_cfg udp_cfg = { NULL };

This assumes that the first member of udp_tunnel_sock_cfg is, and will always
be, a pointer.

You could use a named initializer to make this better, but the cleanest way to
deal with this is to use an empty initializer "{ }", or just plain memset()
the thing to zero.

Thanks.
