From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: [GIT PULL] IPv6 Updates
Date: Wed, 14 Feb 2007 21:19:10 +0200
Message-ID: <200702142119.11304.hasso@estpak.ee>
References: <20070215.023514.30908786.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	aramoto@linux-ipv6.org, kozakai@linux-ipv6.org
To: YOSHIFUJI Hideaki /
	 =?utf-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hax.kala.ee ([194.126.124.39]:41565 "HELO hax.kala.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932436AbXBNTTd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 14:19:33 -0500
In-Reply-To: <20070215.023514.30908786.yoshfuji@linux-ipv6.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> commit bd292ad1ccbf15c72351f79d4a130dd50da81613
> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date:   Thu Feb 15 02:07:27 2007 +0900
>=20
>     [IPV6] ADDRCONF: Register inet6_dev earlier.
>    =20
>     Allocate inet6_dev earlier to allow users to set up per-interface=
 variables.
>    =20
>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index c6683ea..42b5cc5 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2246,6 +2246,14 @@ static int addrconf_notify(struct notifier_blo=
ck *this, unsigned long event,
>  	int run_pending =3D 0;
> =20
>  	switch(event) {
> +	case NETDEV_REGISTER:
> +		if (!idev) {
> +			idev =3D ipv6_add_dev(dev);
> +			if (!idev)
> +				printk(KERN_WARNING "IPv6: add_dev failed for %s\n",
> +					dev->name);
> +		}
> +		break;
>  	case NETDEV_UP:
>  	case NETDEV_CHANGE:
>  		if (event =3D=3D NETDEV_UP) {
>=20
> ---

Many thanks. Now if only IPv4 would be fixed in similar fashion as well=
=2E

Also, this reminds me related issue - "ADDRCONF(NETDEV_UP): <ifname>: l=
ink
is not ready" and "ADDRCONF(NETDEV_CHANGE): <ifname>: link becomes read=
y"
messages. While it may look informational, it's extremely annoying in
systems with hundreds and even thousands vlan interfaces.


regards,

--=20
Hasso Tepper
