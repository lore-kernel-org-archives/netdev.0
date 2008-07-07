From: Patrick McHardy <kaber@trash.net>
Subject: Re: v3 [PATCH net-next 5/7] ipv4: Check return of dev_set_allmulti
Date: Mon, 07 Jul 2008 13:22:04 +0200
Message-ID: <4871FC5C.9030106@trash.net>
References: <48718014.4030009@cn.fujitsu.com> <48718172.8070404@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57244 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbYGGLWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 07:22:06 -0400
In-Reply-To: <48718172.8070404@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
>  	case VIFF_TUNNEL:
>  		dev = ipmr_new_tunnel(vifc);
>  		if (!dev)
>  			return -ENOBUFS;
> +		err = dev_set_allmulti(dev, 1);
> +		if (err) {
> +			dev_close(dev);
> +			return err;
> +		}

ipmr_new_tunnel creates a new tunnel device that you're not removing.

>  		break;
>  	case 0:
>  		dev = ip_dev_find(&init_net, vifc->vifc_lcl_addr.s_addr);
>  		if (!dev)
>  			return -EADDRNOTAVAIL;
>  		dev_put(dev);
> +		err = dev_set_allmulti(dev, 1);
> +		if (err)
> +			return err;

Also looks like a use after free, but again, one that is
already present without your patch.
