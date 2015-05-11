From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] macvtap add missing ioctls - fix wrapping
Date: Mon, 11 May 2015 13:49:01 -0400 (EDT)
Message-ID: <20150511.134901.959375179450827063.davem@davemloft.net>
References: <20150509.174017.6956415471104971.davem@davemloft.net>
	<1431249359.669.5.camel@myriabit.com>
	<1431262215.3278.2.camel@myriabit.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: justin@myriabit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbbEKRtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:49:03 -0400
In-Reply-To: <1431262215.3278.2.camel@myriabit.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Justin Cormack <justin@myriabit.com>
Date: Sun, 10 May 2015 13:50:15 +0100

> The macvtap driver tries to emulate all the ioctls supported by a normal
> tun/tap driver, however it was missing the generic SIOCGIFHWADDR and
> SIOCSIFHWADDR ioctls to get and set the mac address that are supported
> by tun/tap. This patch adds these.
> 
> Signed-off-by: Justin Cormack <justin@netbsd.org>
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 8c350c5..f37e8f9 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -1101,6 +1101,35 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
>  		rtnl_unlock();
>  		return ret;
>  
> +	case SIOCGIFHWADDR:
> +		rtnl_lock();
> +		vlan = macvtap_get_vlan(q);
> +		if (!vlan) {
> +			rtnl_unlock();
> +			return -ENOLINK;
> +		}
> +		ret = 0;
> +		u = vlan->dev->type;
> +		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
> +			copy_to_user(&ifr->ifr_hwaddr.sa_data, vlan->dev->dev_addr, ETH_ALEN) ||
> +			put_user(u, &ifr->ifr_hwaddr.sa_family))

This is not indented correctly.

When an if() statement spans multiple lines, the second and subsequent lines
should start exactly at the first column following the openning parenthesis
of the first line.  You should use the appropriate number of TAB then
SPACE characters necessary to achieve this.

Thanks.
