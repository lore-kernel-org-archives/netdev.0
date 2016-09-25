From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "net: ethernet: bcmgenet: use phydev from
 struct net_device"
Date: Sun, 25 Sep 2016 05:35:06 -0400 (EDT)
Message-ID: <20160925.053506.2140883650540997409.davem@davemloft.net>
References: <1474747110-6496-1-git-send-email-f.fainelli@gmail.com>
        <20160924.201054.1736819083455070537.davem@davemloft.net>
        <9fa471d4-a179-519b-005f-5b52f31c5903@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tremyfr@gmail.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46354 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753897AbcIYJfK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 05:35:10 -0400
In-Reply-To: <9fa471d4-a179-519b-005f-5b52f31c5903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat, 24 Sep 2016 19:51:49 -0700

> 
> 
> On 09/24/2016 05:10 PM, David Miller wrote:
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Sat, 24 Sep 2016 12:58:30 -0700
>> 
>>> There is already a commit:
>>>
>>> Revert "net: ethernet: bcmgenet: use phy_ethtool_{get|set}_link_ksettings"
>>>
>>> which should make this apply cleanly to "net" now.
>> 
>> But look at net-next, it got re-added there.
>> 
>> This is going to be a bit of a merge hassle, and this is why I pushed
>> back on the other attempt to revert this thing.
> 
> OK, so how about this:
> 
> - this patch applies to net which should be okay for now
> - to avoid future conflicts when you merge net into net-next, I submit a
> revert of "net: ethernet: bcmgenet: use
> phy_ethtool_{get|set}_link_ksettings" against net-next
> 
> Does that work for you?

The ksettings patch will still be in net-next and thus the driver
will be broken in a different way than the problem being fixed
by the revert.

If you revert this phydev patch you must also revert the ksettings
patch.  The ksettings patch depends upon it.  This is what I've
been trying to explain all along.

What I really hoped someone would try, would be to make this phydev
change work properly instead of just straight up reverting it.

In that way all of these merge hassles would be eliminated entirely.
