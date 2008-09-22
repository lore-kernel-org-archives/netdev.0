From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [V#2 PATCH 0/18] netdevice: Fix directly reference of netdev->priv
Date: Mon, 22 Sep 2008 15:04:01 +0800
Message-ID: <48D74361.7010603@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>	<48D4B1B0.2030803@cn.fujitsu.com> <20080920.033700.257291582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com, dcbw@redhat.com
To: David Miller <davem@davemloft.net>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63418 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751166AbYIVHGy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 03:06:54 -0400
In-Reply-To: <20080920.033700.257291582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-9-20 18:37:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Sat, 20 Sep 2008 16:17:52 +0800
> 
>> Dave said:
>>> I'll see what I can do.
>>>
>>> I know this is going to create conflicts in a few places, including sparc-next-2.6
>>> where I already made this fix while cleaning up all of the SBUS device drivers.
>>>
>>> So I guess I'm saying that I'm being lazy. :)
>>>
>>> I'll try to look into this next week as I'm going to be busy and also away for
>>> a few days.
>>>
>> Dave, seems nobody give any opposite comments.
> 
> Actually, I did see such comments which is why I totally dropped this set from
> my inbox. 
> 

Dave, do you mean these comments?

------
John W. Linville:
However, I do not understand why you didn't
simply replace netdev->priv with netdev_priv()?  Can you explain?

Dan Williams:
Yeah, that would have been my first choice too...
------

I think I have answered their question as:
------
1. Why I don't use netdev_priv() to replace netdev->priv here?
Because, netdev->priv was changed here, but it shouldn't, 
the memory was allocated when alloc_netdev and
netdev->priv should always pointed to that memory.

2. Why I use netdev->ml_priv here to replace netdev->priv?
In this driver, netdev->priv are shared by multi wifidevs, that means wifidevs need
mid-layer private data, which are all same as their parent netdev.
This usage is same as Dave's commit "syncppp: Fix crashes."
------

After my answer, their didn't give feedback, so I think there is no opposite comments.

> Besides, it's Jeff's territory technically :-)
> 

OK. Jeff, will you look at my patch?

