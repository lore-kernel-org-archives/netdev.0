From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch net-next-2.6 1/4] rtnetlink: implement setting of master
 device
Date: Sun, 13 Feb 2011 20:43:35 +0100
Message-ID: <4D583467.6020803@trash.net>
References: <20110213193105.GD2740@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38920 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751Ab1BMTnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 14:43:40 -0500
In-Reply-To: <20110213193105.GD2740@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 13.02.2011 20:31, schrieb Jiri Pirko:
> This patch allows userspace to enslave/release slave devices via netlink
> interface using IFLA_MASTER. This introduces generic way to add/remove
> underling devices.

Looks good to me, just one question:

> @@ -1301,6 +1337,12 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  			goto errout;
>  	}
>  
> +	if (tb[IFLA_MASTER]) {
> +		err = do_set_master(dev, nla_get_u32(tb[IFLA_MASTER]));
> +		if (err)
> +			goto errout;
> +	}

Any reason why you're not setting "modified" here?

> +
>  	if (tb[IFLA_TXQLEN])
>  		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
>  

