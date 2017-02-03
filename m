From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Fix lack of reference count on PHY driver
Date: Thu, 02 Feb 2017 23:00:13 -0500 (EST)
Message-ID: <20170202.230013.627103966507584854.davem@davemloft.net>
References: <20170201024643.2050-1-f.fainelli@gmail.com>
        <20170202.215407.606581158337251076.davem@davemloft.net>
        <26bbf22a-8d2b-00a0-d509-0c1651e3b1f3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        maowenan@huawei.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40194 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752095AbdBCEAS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 23:00:18 -0500
In-Reply-To: <26bbf22a-8d2b-00a0-d509-0c1651e3b1f3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 2 Feb 2017 19:47:43 -0800

> Le 02/02/17 à 18:54, David Miller a écrit :
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Tue, 31 Jan 2017 18:46:43 -0800
>> 
>>> From: Mao Wenan <maowenan@huawei.com>
>>>
>>> There is currently no reference count being held on the PHY driver,
>>> which makes it possible to remove the PHY driver module while the PHY
>>> state machine is running and polling the PHY. This could cause crashes
>>> similar to this one to show up:
>>  ...
>>> Keep references on the PHY driver module right before we are going to
>>> utilize it in phy_attach_direct(), and conversely when we don't use it
>>> anymore in phy_detach().
>>>
>>> Signed-off-by: Mao Wenan <maowenan@huawei.com>
>>> [florian: rebase, rework commit message]
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> 
>> I think grabbing the module reference is the only easy fix we
>> can do for now.
>> 
>> Hot plugging PHYs and notifications and all of that business is
>> net-next material.
>> 
>> Florian, do you need to respin this with the workqueue or whatever
>> suggestion Russell made?
> 
> That seems to deserve a separate fix of its own it seems, because it
> becomes tangential to this particular problem.

Ok, patch applied then.

Thanks!
