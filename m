From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ioctl SIOCSIFADDR minor cleanup
Date: Tue, 15 Nov 2016 22:01:08 -0500 (EST)
Message-ID: <20161115.220108.1225196299725031215.davem@davemloft.net>
References: <1479213899-5952-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linyu.Yuan@alcatel-sbell.com.cn
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35364 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752547AbcKPDBK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 22:01:10 -0500
In-Reply-To: <1479213899-5952-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <cugyly@163.com>
Date: Tue, 15 Nov 2016 20:44:59 +0800

> @@ -1063,10 +1063,7 @@ int devinet_ioctl(struct net *net, unsigned int cmd, void __user *arg)
>  			if (!ifa)
>  				break;
>  			INIT_HLIST_NODE(&ifa->hash);
> -			if (colon)
> -				memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
> -			else
> -				memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
> +			memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);

This is an incorrect and untested change.

If there is a colon character in ifr.ifr_name, earlier in this function
we will:

1) First replace that colon with a NULL character.

2) Perform __dev_get_by_name() on the result.

3) Put the ":" colon character back into ifr.ifr_name

So the two strings ifr.ifr_name and dev->name can in fact be different
here.  Therefore the code has to be left as it is.
