From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vlan: Fix lockdep warning when vlan dev handle
 notification
Date: Thu, 27 Mar 2014 13:06:04 -0400 (EDT)
Message-ID: <20140327.130604.103963458048959251.davem@davemloft.net>
References: <5321165A.1000208@huawei.com>
	<20140314.220253.2108022241165181233.davem@davemloft.net>
	<53266735.8050607@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, john.r.fastabend@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, f.fainelli@gmail.com
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902AbaC0RGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 13:06:09 -0400
In-Reply-To: <53266735.8050607@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Mon, 17 Mar 2014 11:08:37 +0800

> On 2014/3/15 10:02, David Miller wrote:
>> From: Ding Tianhong <dingtianhong@huawei.com>
>> Date: Thu, 13 Mar 2014 10:22:18 +0800
>> 
>>> When I open the LOCKDEP config and run these steps:
>> 
>> This doesn't work?
>> 
> 
> It make no sense, I have try it before, the class check only focus on the lock_class_key,
> not the lockdep_subclass_key.

I think the issue is that not all of the addrlist locking uses _nested() variants,
I think if we do that, this will all work.

I do not want to add a huge array of locking keys to fix this, it's a waste of
static kernel memory and inelegant.
