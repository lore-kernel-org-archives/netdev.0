From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: inet: diag: expose the socket mark to
 privileged processes.
Date: Thu, 08 Sep 2016 17:57:03 -0700 (PDT)
Message-ID: <20160908.175703.1354122300312111500.davem@davemloft.net>
References: <1473262945-144932-1-git-send-email-lorenzo@google.com>
        <20160908.161348.297729487225819070.davem@davemloft.net>
        <CAKD1Yr3p+ZcVbawRW98LCVEW763UYCj4tfHYxadk+dSuxfEy1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        dsa@cumulusnetworks.com, ek@google.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43400 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbcIIA5E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:57:04 -0400
In-Reply-To: <CAKD1Yr3p+ZcVbawRW98LCVEW763UYCj4tfHYxadk+dSuxfEy1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Fri, 9 Sep 2016 09:48:27 +0900

> On Fri, Sep 9, 2016 at 8:13 AM, David Miller <davem@davemloft.net> wrote:
>>> This adds the capability for a process that has CAP_NET_ADMIN on
>>> a socket to see the socket mark in socket dumps.
>>
>> Applied, but the argument list of inet_sk_diag_fill is starting to get out
>> of control.
> 
> I think a lot of the parameters it takes are just a couple of pointer
> lookups away from in_skb. I assumed it did not take in_skb directly
> for performance reasons: this way the calling functions can calculate
> many of these arguments just once per dump instead of once per socket.
> But thinking about it some more the cost of those pointer lookups is
> negligible compared to the cost of iterating over the hashtables,
> marshalling the attributes, etc.
> 
> I'll see if I can send something out to pass in in_skb instead.

The other option is to have a "struct foo_info" object on the callers
stack that holds all of these values, then pass a pointer to the foo_info
to inet_sk_diag_fill.
