From: David Ahern <dsahern@gmail.com>
Subject: Re: [Patch net] ipv6: initialize route null entry in addrconf_init()
Date: Thu, 4 May 2017 11:12:45 -0600
Message-ID: <896e63a7-d0ad-a4db-21fc-9abdb02dd9df@gmail.com>
References: <1493874452-3050-1-git-send-email-xiyou.wangcong@gmail.com>
 <CAAeHK+zmMUvt4Lz28k3Oyxi1QFmrTMBe34=6xJDBPxkeivnPeA@mail.gmail.com>
 <20170504.125144.78973292337920988.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, andreyknvl@google.com,
        xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33271 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751474AbdEDRMt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 13:12:49 -0400
Received: by mail-pf0-f176.google.com with SMTP id q20so10631846pfg.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 10:12:49 -0700 (PDT)
In-Reply-To: <20170504.125144.78973292337920988.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/17 10:51 AM, David Miller wrote:
> From: Andrey Konovalov <andreyknvl@google.com>
> Date: Thu, 4 May 2017 14:28:37 +0200
> 
>> On Thu, May 4, 2017 at 7:07 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>> Andrey reported a crash on init_net.ipv6.ip6_null_entry->rt6i_idev
>>> since it is always NULL.
>>>
>>> This is clearly wrong, we have code to initialize it to loopback_dev,
>>> unfortunately the order is still not correct.
>>>
>>> loopback_dev is registered very early during boot, we lose a chance
>>> to re-initialize it in notifier. addrconf_init() is called after
>>> ip6_route_init(), which means we have no chance to correct it.
>>>
>>> Fix it by moving this initialization explicitly after
>>> ipv6_add_dev(init_net.loopback_dev) in addrconf_init().
>>>
>>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>
>> Hi Cong,
>>
>> This fixes the bug triggered by my reproducer.
>>
>> Thanks!
>>
>> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> 
> Applied and queued up for -stable, thanks.
> 

This is not the complete solution; it only fixes init_net. It still
blows up when you do:

unshare -n
./rt6_device_match


same exact stack trace
