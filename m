From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: gre: provide multicast mappings for ipv4 and ipv6
Date: Tue, 29 Mar 2011 11:11:45 +0200
Message-ID: <1301389905.3161.3.camel@edumazet-laptop>
References: <4D8F6313.60408@iki.fi>
	 <1301388053-6083-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Doug Kehn <rdkehn@yahoo.com>
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39753 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749Ab1C2JLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 05:11:49 -0400
Received: by fxm17 with SMTP id 17so26263fxm.19
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2011 02:11:48 -0700 (PDT)
In-Reply-To: <1301388053-6083-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 mars 2011 =C3=A0 11:40 +0300, Timo Ter=C3=A4s a =C3=A9crit =
:
> My commit 6d55cb91a0020ac0 (gre: fix hard header destination
> address checking) broke multicast.
>=20
> The reason is that ip_gre used to get ipgre_header() calls with
> zero destination if we have NOARP or multicast destination. Instead
> the actual target was decided at ipgre_tunnel_xmit() time based on
> per-protocol dissection.
>=20
> Instead of allowing the "abuse" of ->header() calls with invalid
> destination, this creates multicast mappings for ip_gre. This also
> fixes "ip neigh show nud noarp" to display the proper multicast
> mappings used by the gre device.
>=20
> Reported-by: Doug Kehn <rdkehn@yahoo.com>
> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> ---
> Compile tested only. Doug tested IPv4 side with the earlier patch.


> +static inline int ipv6_ipgre_mc_map(const struct in6_addr *addr,
> +				    const unsigned char *broadcast, char *buf)
> +{
> +	if ((broadcast[0] | broadcast[1] | broadcast[2] | broadcast[3]) !=3D=
 0) {
> +		memcpy(buf, broadcast, 4);
> +	} else {
> +		/* v4mapped? */
> +		if ((addr->s6_addr32[0] | addr->s6_addr32[1] |
> +		     (addr->s6_addr32[2] ^ htonl(0x0000ffff))) !=3D 0)
> +			return -EINVAL;

		if (ipv6_addr_v4mapped(addr))


> +		memcpy(buf, &addr->s6_addr32[3], 4);
> +	}
> +	return 0;
> +}


