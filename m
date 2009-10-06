From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: arp_notify address list bug
Date: Tue, 06 Oct 2009 05:13:00 +0200
Message-ID: <4ACAB5BC.1020307@gmail.com>
References: <20091005191505.75c929a6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41656 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754766AbZJFDNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 23:13:42 -0400
In-Reply-To: <20091005191505.75c929a6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> This fixes a bug with arp_notify and also adds a small enhancement.
>=20
> If arp_notify is enabled, kernel will crash if address is changed
> and no IP address is assigned.
>   http://bugzilla.kernel.org/show_bug.cgi?id=3D14330
>=20
> The fix is to walk the (possibly empty) list when sending
> the gratuitous ARP's.

>=20
> -				 NULL, dev->dev_addr, NULL);
> +		/* Send gratitious ARP to notify of link change */

	/* gratuitous */

> +		if (IN_DEV_ARP_NOTIFY(in_dev)) {
> +			struct in_ifaddr *ifa;
> +			for (ifa =3D in_dev->ifa_list; ifa; ifa =3D ifa->ifa_next)
> +				arp_send(ARPOP_REQUEST, ETH_P_ARP,
> +					 ifa->ifa_address, dev,
> +					 ifa->ifa_address, NULL,
> +					 dev->dev_addr, NULL);
> +		}

This sends a broadcast storm if device has a long address list.

Maybe we should change arp_notify to an INTEGER to be able to give a li=
mit.

If people used to set arp_notify to 1, they wont be surprised too much.

I suggest splitting patch in two parts, one to fix the bug for linux-2.=
6 and stable,
and another one for net-next-2.6 for the enhancement ?

Thanks

