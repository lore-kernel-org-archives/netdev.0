From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_tunnel: don't add tunnel twice
Date: Fri, 16 May 2014 16:58:10 -0400 (EDT)
Message-ID: <20140516.165810.1304809993050411212.davem@davemloft.net>
References: <53744B76.3080101@cn.fujitsu.com>
	<20140515.231051.1178432224326720292.davem@davemloft.net>
	<53759CE7.8000207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49317 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbaEPU6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 16:58:12 -0400
In-Reply-To: <53759CE7.8000207@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Fri, 16 May 2014 13:06:47 +0800

> 于 2014年05月16日 11:10, David Miller 写道:
>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> Date: Thu, 15 May 2014 13:07:02 +0800
>> 
>>>
>>> When using command "ip tunnel add" to add a tunnel, the tunnel will be added twice,
>>> through ip_tunnel_create() and ip_tunnel_update().
>>>
>>> Because the second is unnecessary, so we can just break after adding tunnel
>>> through ip_tunnel_create().
>>>
>>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>> 
>> ip_tunnel_update() seems to do some things tha ip_tunnel_create()
>> does not.
>> 
>> For example, setting dev->dev_addr[] and dev->broadcast[] from the
>> ipv4 parms if appropriate.
>> 
>> I think you need to rethink this change.
> 
> When registering tunnel link, function register_netdevice() will call 
> dev->netdev_ops->ndo_init, actually the virtual function ndo_init will
> do some same things  the ip_tunnel_update() does, such as the 
> above you mentioned.
> 
> So i think you don't need to worry about that.

Aha, I see, thanks for explaining.

Patch applied.
