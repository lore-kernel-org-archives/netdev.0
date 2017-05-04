From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] ipv6: initialize route null entry in
 addrconf_init()
Date: Thu, 04 May 2017 12:51:44 -0400 (EDT)
Message-ID: <20170504.125144.78973292337920988.davem@davemloft.net>
References: <1493874452-3050-1-git-send-email-xiyou.wangcong@gmail.com>
        <CAAeHK+zmMUvt4Lz28k3Oyxi1QFmrTMBe34=6xJDBPxkeivnPeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, dsahern@gmail.com
To: andreyknvl@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57886 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755361AbdEDQvp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 12:51:45 -0400
In-Reply-To: <CAAeHK+zmMUvt4Lz28k3Oyxi1QFmrTMBe34=6xJDBPxkeivnPeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 4 May 2017 14:28:37 +0200

> On Thu, May 4, 2017 at 7:07 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> Andrey reported a crash on init_net.ipv6.ip6_null_entry->rt6i_idev
>> since it is always NULL.
>>
>> This is clearly wrong, we have code to initialize it to loopback_dev,
>> unfortunately the order is still not correct.
>>
>> loopback_dev is registered very early during boot, we lose a chance
>> to re-initialize it in notifier. addrconf_init() is called after
>> ip6_route_init(), which means we have no chance to correct it.
>>
>> Fix it by moving this initialization explicitly after
>> ipv6_add_dev(init_net.loopback_dev) in addrconf_init().
>>
>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> Hi Cong,
> 
> This fixes the bug triggered by my reproducer.
> 
> Thanks!
> 
> Tested-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks.
