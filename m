From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next v2]netdevice: 82596: Convert netdev->priv to
 netdev_priv
Date: Mon, 17 Nov 2008 22:42:16 +0800
Message-ID: <492182C8.6060704@cn.fujitsu.com>
References: <4921095D.9010109@cn.fujitsu.com>	<20081116.223637.108010315.davem@davemloft.net>	<49213856.6040802@cn.fujitsu.com> <20081117.012939.72047312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58762 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750783AbYKQOms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 09:42:48 -0500
In-Reply-To: <20081117.012939.72047312.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-11-17 17:29:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Mon, 17 Nov 2008 17:24:38 +0800
> 
>> The memory, which pointed by netdev->priv, can be allocated by alloc_etherdev().
>> We don't need to use __get_free_pages() to get memory.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> I don't think this is right either.
> 
> There might be device imposed alignment constraints, for example.
> 
> And a whole page is also being allocated so that this cache mode
> change doesn't have an effect on unrelated kernel memory.  That could
> kill performance if some critical other data structure sits in the
> same page and now has it's cacheability disabled.
> 

On this situation, I think that keeping mem_start and using ml_priv
is the only way to remove directly reference of netdev->priv.

I will send v3 tomorrow.


