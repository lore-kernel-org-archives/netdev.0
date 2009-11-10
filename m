From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 10/10] CAN: use dev_get_by_index_rcu
Date: Tue, 10 Nov 2009 19:34:06 +0100
Message-ID: <4AF9B21E.50805@gmail.com>
References: <20091110175446.280423729@vyatta.com> <20091110175647.824581805@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Lothar Wassmann <LW@KARO-electronics.de>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37759 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbZKJSeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:34:11 -0500
In-Reply-To: <20091110175647.824581805@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> Use new function to avoid doing read_lock().
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> --- a/net/can/bcm.c	2009-11-10 09:45:16.301376272 -0800
> +++ b/net/can/bcm.c	2009-11-10 09:46:30.125005956 -0800
> @@ -139,13 +139,13 @@ static char *bcm_proc_getifname(char *re
>  	if (!ifindex)
>  		return "any";
> =20
> -	read_lock(&dev_base_lock);
> -	dev =3D __dev_get_by_index(&init_net, ifindex);
> +	rcu_read_lock();
> +	dev =3D dev_get_by_index_rcu(&init_net, ifindex);
>  	if (dev)
>  		strcpy(result, dev->name);
>  	else
>  		strcpy(result, "???");
> -	read_unlock(&dev_base_lock);
> +	rcu_read_unlock();
> =20
>  	return result;
>  }
>=20

I was pretty sure I had already done this one...

Ah yes, that was planned after a bugfix for net-2.6.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

