From: Patrick McHardy <kaber@trash.net>
Subject: Re: v3 [PATCH net-next 4/7] ipv6: Check return of dev_set_allmulti
Date: Mon, 07 Jul 2008 15:26:28 +0200
Message-ID: <48721984.8060202@trash.net>
References: <48718014.4030009@cn.fujitsu.com> <4871814A.2070707@cn.fujitsu.com> <4871FBFC.2050408@trash.net> <48721780.9060103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60590 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078AbYGGN0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 09:26:32 -0400
In-Reply-To: <48721780.9060103@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> Patrick McHardy said the following on 2008-7-7 19:20:
>>> @@ -627,13 +633,14 @@ static int mif6_add(struct mif6ctl *vifc, int
>>> mrtsock)
>>>          if (!dev)
>>>              return -EADDRNOTAVAIL;
>>>          dev_put(dev);
>>> +        err = dev_set_allmulti(dev, 1);
>>> +        if (err)
>>> +            return err;
>> The use of dev after putting it looks wrong, but thats already
>> present before your patch. So ACK for your patch, but we need
>> a fix on top.
>>
> 
> Wait a moment :)
> ---
> 	case 0:
> 		dev = dev_get_by_index(&init_net, vifc->mif6c_pifi);
> 		if (!dev)
> 			return -EADDRNOTAVAIL;
> 		dev_put(dev);
> ---
> dev_get_by_index() holds the dev, so I think dev_put() just for hold/put
> balance.

Sure, but its used after dropping the reference again.
