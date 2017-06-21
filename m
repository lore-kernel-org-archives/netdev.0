From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] loopback: Force LOOPBACK_IFINDEX for registration
Date: Wed, 21 Jun 2017 11:44:27 -0400 (EDT)
Message-ID: <20170621.114427.948405486092143330.davem@davemloft.net>
References: <20170619.144123.2070662074449196481.davem@davemloft.net>
        <60e546b5-2548-5eef-ebc6-4cf0ca44da27@gmail.com>
        <f79075f1-3c95-8bb3-6600-c6dd2ce7e1ce@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: serhe.popovych@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40464 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752991AbdFUQUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 12:20:48 -0400
In-Reply-To: <f79075f1-3c95-8bb3-6600-c6dd2ce7e1ce@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serhey Popovych <serhe.popovych@gmail.com>
Date: Wed, 21 Jun 2017 12:35:12 +0300

> 
>> 
>>> From: Serhey Popovych <serhe.popovych@gmail.com>
>>> Date: Fri, 16 Jun 2017 15:10:03 +0300
>>>
>>>> Now with commit 9c7dafb (net: Allow to create links with
>>>> given ifindex) support registration of network devices
>>>> with specific ifindex is added.
>>>>
>>>> We can force loopback network device index before call to
>>>> register_netdev() to ensure we always configure it with
>>>> LOOPBACK_IFINDEX.
>>>>
>>>> Kill BUG_ON() since system can continue without network
>>>> namespace failed in loopback init path, unless it is
>>>> init_net namespace where we panic() anyway.
>>>>
>>>> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
>>>
>>> Is the BUG_ON() triggering, if so why?
>>>
>>> It looks to me that unless there is a bug, this assignment
>>> is unnecessary.
>>>
>> Okay, get your position, thanks!
>> 
> 
> Sorry for raising again, but my objectives following:
> 
> BUG_ON() might be compiled out when CONFIG_BUG=n.
> That's open possibility in buggy setups to have
> "lo" with ->ifindex other than LOOPBACK_IFINDEX.
> 
> By forcing register_netdevice() via setting
> ifindex = LOOPBACK_IFINDEX we address CONFIG_BUG=n
> case.
> 
> We can leave BUG_ON(), but add ifindex = LOOPBACK_IFINDEX
> to ensure register_netdevice() operates properly.
> 
> What do you think?

I don't understand what you are trying to achieve.

BUG_ON() is an assertion.

It checks that an invariant holds.

Whether the check is enabled or not has no bearing on the
invariant.

There is no reason to make the assignment if it is supposed
to be set properly already, period.  The assertion states
that it is supposed to be set properly when we get to this
code.
