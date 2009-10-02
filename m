From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: export device speed and duplex via sysfs
Date: Fri, 02 Oct 2009 20:15:08 +0200
Message-ID: <4AC6432C.1020202@gmail.com>
References: <20091002180742.GH4436@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60784 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758027AbZJBSPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 14:15:17 -0400
In-Reply-To: <20091002180742.GH4436@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek a =E9crit :
> +static ssize_t show_speed(struct device *dev,
> +			  struct device_attribute *attr, char *buf)
> +{
> +	struct net_device *netdev =3D to_net_dev(dev);
> +	int ret =3D -EINVAL;
> +
> +	if (!rtnl_trylock())
> +		return restart_syscall();
> +
> +	if (netif_running(netdev) && netdev->ethtool_ops->get_settings) {
> +		struct ethtool_cmd cmd =3D { ETHTOOL_GSET };
> +
> +		if (netdev->ethtool_ops->get_settings(netdev, &cmd) < 0)

		rtnl lock leak ?


> +			return -EINVAL;
> +		ret =3D sprintf(buf, fmt_dec, cmd.speed);
> +	}
> +	rtnl_unlock();
> +	return ret;
> +}
> +
> +static ssize_t show_duplex(struct device *dev,
> +			   struct device_attribute *attr, char *buf)
> +{
> +	struct net_device *netdev =3D to_net_dev(dev);
> +	int ret =3D -EINVAL;
> +
> +	if (!rtnl_trylock())
> +		return restart_syscall();
> +
> +	if (netif_running(netdev) && netdev->ethtool_ops->get_settings) {
> +		struct ethtool_cmd cmd =3D { ETHTOOL_GSET };
> +
> +		if (netdev->ethtool_ops->get_settings(netdev, &cmd) < 0)

		rtnl lock leak ?

> +			return -EINVAL;
> +		ret =3D sprintf(buf, "%s\n", cmd.duplex ? "full" : "half");
> +	}
> +	rtnl_unlock();
> +	return ret;
> +}
> +

