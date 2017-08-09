From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] rtnetlink: allow to run selected handlers
 without rtnl
Date: Wed, 09 Aug 2017 09:41:25 -0700 (PDT)
Message-ID: <20170809.094125.134674528726147241.davem@davemloft.net>
References: <20170808.213329.522107918983433411.davem@davemloft.net>
        <20170809081928.GA26899@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753071AbdHIQl2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 12:41:28 -0400
In-Reply-To: <20170809081928.GA26899@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 9 Aug 2017 10:19:28 +0200

> David Miller <davem@davemloft.net> wrote:
>> From: Florian Westphal <fw@strlen.de>
>> Date: Tue,  8 Aug 2017 18:02:29 +0200
>> 
>> > Unfortunately RTNL mutex is a performance issue, e.g. a cpu adding
>> > an ip address prevents other cpus from seemingly unrelated tasks
>> > such as dumping tc classifiers.
>> 
>> It is related if somehow the TC entries refer to IP addresses.
>>
>> Someone could create something like that.
> 
> Actually I am not following.  Why would read-only accesses need rtnl
> locking wrt. any other operation (provided of course rtnl lock doesn't
> protect the data structure)?

If the validity of change X depends upon another value Y meeting some
criteria, we test Y and then must be sure that Y doesn't change while
we go about making the change to X.

For example if I need to make sure a path to an IPV4 address exists
configured to an interface when adding a route, I must be sure that
someone can't remove that IPV4 address while I'm adding the route,
after I've checked that it does in fact exist.

This is the kind of stuff that the RTNL mutex ensures.
