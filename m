From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH] The kernel gets no IP from some DHCP servers, 2.6.24
Date: Fri, 22 Feb 2008 00:41:22 +0100
Message-ID: <E1JSL2Y-0001fc-DK@faramir.fjphome.nl>
References: <83116F0A4FF67A4F97BA0B6E408C48E301C5C723@zuerich.BC-Int.NET>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Wappler Marcel <Marcel.Wappler@bridgeco.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpsmtp-eml11.KPNXCHANGE.COM ([213.75.38.111]:23261 "EHLO
	hpsmtp-eml11.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933873AbYBUXl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 18:41:27 -0500
In-reply-To: <83116F0A4FF67A4F97BA0B6E408C48E301C5C723@zuerich.BC-Int.NET>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding netdev list.
Original patch can be found at: http://lkml.org/lkml/2008/2/21/171

Wappler Marcel wrote:
> This patch fixes a DHCP issue of the kernel: some DHCP servers
> (i.e. in the Linksys WRT54Gv5) are very strict about the contents
> of the DHCPDISCOVER packet they receive from clients. Table 5 in RFC2=
131
> page 36 requests the fields 'ciaddr' and 'siaddr' MUST be set to '0'.
> These DHCP servers ignore Linux kernel's DHCP discovery packets with =
these
> two fields set to '255.255.255.255' (in contrast to popular DHCP clie=
nts,
> such as 'dhclient' or 'udhcpc'). This leads to a not booting system.
> I tested this on a ARM embedded device mounting rootfs over NFS obtai=
ning
> its IP from a Linksys WRT54Gv5 Router running VxWorks and a PC based
> Server running a Linux. Changing the two fields to '0.0.0.0' worked.
>=20
> Please CC me personaly when answering this message.
>=20
> Thanks,
> Marcel
>=20
> --- linux-2.6.24.2/net/ipv4/ipconfig.c	2008-02-21 15:27:47.250890963 =
+0100
> +++ linux/net/ipv4/ipconfig.c	2008-02-21 15:36:12.686735925 +0100
> @@ -29,6 +29,10 @@
>   *
>   *  Multiple Nameservers in /proc/net/pnp
>   *              --  Josef Siemes <jsiemes@web.de>, Aug 2002
> + *
> + *  Bugfix: Not getting an IP from some DHCP servers: RFC2131 page 3=
6
> + *  Table 5 requests DHCPDISCOVER fields ciaddr and siaddr MUST be '=
0'.
> + *              -- marcel.wappler@bridgeco.net
>   */
> =20
>  #include <linux/types.h>
> @@ -103,6 +107,7 @@
>  - '3' from resolv.h */
> =20
>  #define NONE __constant_htonl(INADDR_NONE)
> +#define ZERO __constant_htonl(((unsigned long int) 0x00000000))
> =20
>  /*
>   * Public IP configuration
> @@ -740,8 +745,8 @@
>  b->htype =3D dev->type; /* can cause undefined behavior */
>  }
>  b->hlen =3D dev->addr_len;
> -	b->your_ip =3D NONE;
> -	b->server_ip =3D NONE;
> +	b->your_ip =3D ZERO;
> +	b->server_ip =3D ZERO;
>  memcpy(b->hw_addr, dev->dev_addr, dev->addr_len);
>  b->secs =3D htons(jiffies_diff / HZ);
>  b->xid =3D d->xid;
>=20
> --
> Marcel Wappler
> Bridgeco AG
> CH-8600 D=C3=BCbendorf
> Switzerland
