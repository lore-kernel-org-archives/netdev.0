From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [GIT PULL] IPv6 Updates
Date: Wed, 14 Feb 2007 14:12:23 -0500
Message-ID: <45D35F17.1090609@hp.com>
References: <20070215.023514.30908786.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	aramoto@linux-ipv6.org, kozakai@linux-ipv6.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelrim03.cce.hp.com ([161.114.21.24]:29439 "EHLO
	ccerelrim03.cce.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932488AbXBNTM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 14:12:28 -0500
In-Reply-To: <20070215.023514.30908786.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yoshifuji-san

I have a question:

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

In this case, ipv6_add_dev will join the all-nodes multicast group on=20
the interface that may be still down.  Is that an issue at all?

It seems that this operation would be better performed when the=20
interface is marked up?

Thanks
-vlad
