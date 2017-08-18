From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] about net: Fix inconsistent teardown and release of
 private netdev state.
Date: Fri, 18 Aug 2017 15:58:35 -0700 (PDT)
Message-ID: <20170818.155835.2053259542629638150.davem@davemloft.net>
References: <1503009040.4936.161.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170817.222131.548007722474107806.davem@davemloft.net>
        <1503062029.4936.173.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34414 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751625AbdHRW6h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:58:37 -0400
In-Reply-To: <1503062029.4936.173.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Aug 2017 06:13:49 -0700

> On Thu, 2017-08-17 at 22:21 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 17 Aug 2017 15:30:40 -0700
>> 
>> > So we do not really know if we need to clean up or not.
>> 
>> We always know, the answer is that whenever register_netdev() fails we
>> never need to perform any cleanup which is done by priv_destructor.
>> 
>> > Any idea how to fix the issue ?
>> 
>> Your patch is exactly how we should fix this, but without the comment.
>> The logic is straightforward.
>> 
>> If register_netdevice() fails any resources handled by priv_destructor
>> are cleaned up, it is guaranteed.
> 
> Not in current code.
> 
> There are some failures which do a "goto out;" 
> 
> out:
> 	return ret;
> 
> 
> In these cases, priv_destructor is not called.
> 
> So we need multiple fixes I think :/

I don't think so.

The cases that "goto out;" in register_netdevce() are those that
execute before ->ndo_init() succeeds.

Only if ->ndo_succeeds() runs successfully should ->priv_destructor()
need execute.

So everything is fine as far as I can see.
