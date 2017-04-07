From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 12:22:23 -0700 (PDT)
Message-ID: <20170407.122223.385211483743191711.davem@davemloft.net>
References: <1491591552.5800.1.camel@sipsolutions.net>
        <20170407190601.GA22991@salvia>
        <1491592185.5800.7.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59684 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756124AbdDGTWY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 15:22:24 -0400
In-Reply-To: <1491592185.5800.7.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 07 Apr 2017 21:09:45 +0200

> On Fri, 2017-04-07 at 21:06 +0200, Pablo Neira Ayuso wrote:
>> On Fri, Apr 07, 2017 at 08:59:12PM +0200, Johannes Berg wrote:
>> [...]
>> > Heh. I think I really want to solve - at least partially -
>> > nla_parse()
>> > to see that it can be done this way. It'd be nice to even transform
>> > all
>> > the callers (I generated half of these patches with spatch anyway)
>> > to
>> > have at least that.
>> 
>> We can just have a modified version of nla_parse that deals with
>> this.
> 
> Yes, but we need to figure out a good way to have the offset.
> 
> We also need to see if we want to *force* having the offset. In some
> sense that'd be useful, in another it might be very complicated to fill
> it in at all times, if for example errors come from lower layers like
> drivers.

It has to be optional, some kinds of errors don't have an exact
context per-se.

Also another way to look at this is that we're providing a lot of
new power and expressability.  So even if only one aspect of the
new error reporting is used it's a positive step forward.

So allow offset "0" meaning "unspecified".
