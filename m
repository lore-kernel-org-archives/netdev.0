From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: dsa: Unregister slave_dev in error path
Date: Wed, 17 Feb 2016 18:28:22 -0800
Message-ID: <56C52C46.6070203@gmail.com>
References: <1455761951-26408-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, andrew@lunn.ch, opendmb@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:35155 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423366AbcBRC2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 21:28:24 -0500
Received: by mail-ob0-f180.google.com with SMTP id xk3so45873320obc.2
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 18:28:24 -0800 (PST)
In-Reply-To: <1455761951-26408-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/02/2016 18:19, Florian Fainelli a =C3=A9crit :
> With commit 0071f56e46da ("dsa: Register netdev before phy"), we are =
now trying
> to unregister

s/unregister/free/...

 a network device that has been previously registered, and in case
> of errors, this will make us hit the BUG_ON(dev->reg_state !=3D
> NETREG_UNREGISTERED) condition.
>=20
> Fix this by adding a missing unregister_netdev() before free_netdev()=
=2E
>=20
> Fixes: 0071f56e46da ("dsa: Register netdev before phy")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  net/dsa/slave.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 40b9ca7..e685042 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -1205,6 +1205,7 @@ int dsa_slave_create(struct dsa_switch *ds, str=
uct device *parent,
>  	ret =3D dsa_slave_phy_setup(p, slave_dev);
>  	if (ret) {
>  		netdev_err(master, "error %d setting up slave phy\n", ret);
> +		unregister_netdev(slave_dev);
>  		free_netdev(slave_dev);
>  		return ret;
>  	}
>=20


--=20
=46lorian
