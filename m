From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] net: core: add IFLA_STATS64 support
Date: Thu, 11 Mar 2010 21:19:58 +0100
Message-ID: <1268338798.2845.3.camel@edumazet-laptop>
References: <1268337450-6749-1-git-send-email-jengelh@medozas.de>
	 <1268337450-6749-4-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:32915 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404Ab0CKUUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 15:20:04 -0500
Received: by bwz1 with SMTP id 1so439773bwz.21
        for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 12:20:02 -0800 (PST)
In-Reply-To: <1268337450-6749-4-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 mars 2010 =C3=A0 20:57 +0100, Jan Engelhardt a =C3=A9crit :
> `ip -s link` shows interface counters truncated to 32 bit. This is
> because interface statistics are transported only in 32-bit quantity
> to userspace. This commit adds a new IFLA_STATS64 attribute that
> exports them in full 64 bit.
>=20
> References: http://lkml.indiana.edu/hypermail/linux/kernel/0307.3/021=
5.html

oh oh, back to  2003 :)

> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
> ---
> =20
>  static inline int rtnl_vfinfo_size(const struct net_device *dev)
>  {
> @@ -698,6 +730,14 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb,=
 struct net_device *dev,
>  	stats =3D dev_get_stats(dev);

OK, stats is up2date with device stats

>  	copy_rtnl_link_stats(nla_data(attr), stats);
> =20
> +	attr =3D nla_reserve(skb, IFLA_STATS64,
> +			sizeof(struct rtnl_link_stats64));
> +	if (attr =3D=3D NULL)
> +		goto nla_put_failure;
> +
> +	stats =3D dev_get_stats(dev);

Why calling dev_get_stats(dev) a second time ?
Its can be pretty expensive on some devices.

> +	copy_rtnl_link_stats64(nla_data(attr), stats);
> +
>  	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent) {
>  		int i;
>  		struct ifla_vf_info ivi;
> --=20


