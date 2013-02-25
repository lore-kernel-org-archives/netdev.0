From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove the unnecessary list_del
Date: Mon, 25 Feb 2013 00:39:31 -0500 (EST)
Message-ID: <20130225.003931.1364384031279092217.davem@davemloft.net>
References: <1361767316-28583-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20130224.235411.1871885689914104471.davem@davemloft.net>
	<512AF088.5040206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743Ab3BYFje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 00:39:34 -0500
In-Reply-To: <512AF088.5040206@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>
Date: Mon, 25 Feb 2013 13:03:04 +0800

> On 2013/02/25 12:54, David Miller wrote:
>> From: Gao feng <gaofeng@cn.fujitsu.com>
>> Date: Mon, 25 Feb 2013 12:41:56 +0800
>> 
>>> These lists are used by unregister_netdevice_many,
>>> they are local variables,will not be seen by others.
>>> there is no need to delete them.
>>>
>>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> 
>> What about the devices on the list?  The ones at the front and the
>> rear of the list will have list pointers that point into no longer
>> valid stack frame locations.
> 
> These lists are only used by unregister_netdevice_many,
> we don't access these lists again after unregister_netdevice_many,
> so I think it doesn't have invalid stack frame locations problems.

I do not see unregister_netdevice_many() list_del()'ing the devices
on the list, therefore those netdevice objects have pointers into
the stale stack frame.

You cannot make this change.
