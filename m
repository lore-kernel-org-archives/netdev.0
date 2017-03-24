From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: add module param to set max-rss-queues.
Date: Fri, 24 Mar 2017 14:40:17 -0700 (PDT)
Message-ID: <20170324.144017.1545614773504954414.davem@davemloft.net>
References: <1490389127-23171-1-git-send-email-greearb@candelatech.com>
        <20170324.141237.1992801159655201421.davem@davemloft.net>
        <255aaae0-8634-c6b5-f4aa-545d2f717aed@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44966 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933123AbdCXVtA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:49:00 -0400
In-Reply-To: <255aaae0-8634-c6b5-f4aa-545d2f717aed@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 24 Mar 2017 14:20:56 -0700

> On 03/24/2017 02:12 PM, David Miller wrote:
>> From: greearb@candelatech.com
>> Date: Fri, 24 Mar 2017 13:58:47 -0700
>>
>>> From: Ben Greear <greearb@candelatech.com>
>>>
>>> In systems where you may have a very large number of network
>>> adapters, certain drivers may consume an unfair amount of
>>> IRQ resources.  So, allow a module param that will limit the
>>> number of IRQs at driver load time.  This way, other drivers
>>> (40G Ethernet, for instance), which probably will need the
>>> multiple IRQs more, will not be starved of IRQ resources.
>>>
>>> Signed-off-by: Ben Greear <greearb@candelatech.com>
>>
>> Sorry, no module params.
>>
>> Use generic run-time facilities such as ethtool to configure
>> such things.
> 
> You cannot call ethtool before module load time, and that is when
> the IRQs are first acquired.  It may be way more useful to give each
> of 20 network adapters 2 irqs than have the first few grab 16 and the
> rest
> get lumped into legacy crap.

Sorry, you'll have to find a way to fix this without a module
parameter.  I understand it might not be easy, but that's not
a reason to add countless driver private module parameters all
over the tree which is the worst user experience possible.
