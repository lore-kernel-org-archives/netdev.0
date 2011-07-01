From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] Disable router anycast address for /127 prefixes
Date: Fri, 01 Jul 2011 10:45:57 -0400
Message-ID: <4E0DDDA5.20401@hp.com>
References: <20110630104713.52e085dd@nehalam.ftrdhcpuser.net> <1309519330-16649-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:20309 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756621Ab1GAOp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 10:45:59 -0400
In-Reply-To: <1309519330-16649-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2011 07:22 AM, Bj=C3=B8rn Mork wrote:
> RFC 6164 requires that routers MUST disable Subnet-Router anycast
> for the prefix when /127 prefixes are used.
>=20
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---

> @@ -1479,6 +1481,8 @@ static void addrconf_join_anycast(struct inet6_=
ifaddr *ifp)
>  static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
>  {
>  	struct in6_addr addr;
> +	if (ifp->prefix_len =3D=3D 127) /* RFC 6164 */
> +		return;
>  	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
>  	if (ipv6_addr_any(&addr))
>  		return;

I'm not sure you'd need this part as there shouldn't be a /127 in the l=
ist to remove.

-Brian
