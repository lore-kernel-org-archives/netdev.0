From: Patrick McHardy <kaber@trash.net>
Subject: Re: v3 [PATCH net-next 4/7] ipv6: Check return of dev_set_allmulti
Date: Mon, 07 Jul 2008 13:20:28 +0200
Message-ID: <4871FBFC.2050408@trash.net>
References: <48718014.4030009@cn.fujitsu.com> <4871814A.2070707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57190 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752979AbYGGLUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 07:20:31 -0400
In-Reply-To: <4871814A.2070707@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check the positive increment for allmulti to get error return.
> 
> @@ -627,13 +633,14 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
>  		if (!dev)
>  			return -EADDRNOTAVAIL;
>  		dev_put(dev);
> +		err = dev_set_allmulti(dev, 1);
> +		if (err)
> +			return err;

The use of dev after putting it looks wrong, but thats already
present before your patch. So ACK for your patch, but we need
a fix on top.
