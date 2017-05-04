From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv6: initialize route null entry in addrconf_init()
Date: Thu, 4 May 2017 10:19:44 -0700
Message-ID: <CAM_iQpVaOC+db1_MkBCBvPFs+dTdMQ_GNM8QSB9DBag4ermmxA@mail.gmail.com>
References: <1493874452-3050-1-git-send-email-xiyou.wangcong@gmail.com>
 <CAAeHK+zmMUvt4Lz28k3Oyxi1QFmrTMBe34=6xJDBPxkeivnPeA@mail.gmail.com>
 <20170504.125144.78973292337920988.davem@davemloft.net> <896e63a7-d0ad-a4db-21fc-9abdb02dd9df@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Andrey Konovalov <andreyknvl@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33072 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754063AbdEDRUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 13:20:05 -0400
Received: by mail-wm0-f67.google.com with SMTP id y10so4782128wmh.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 10:20:05 -0700 (PDT)
In-Reply-To: <896e63a7-d0ad-a4db-21fc-9abdb02dd9df@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 4, 2017 at 10:12 AM, David Ahern <dsahern@gmail.com> wrote:
> On 5/4/17 10:51 AM, David Miller wrote:
>> From: Andrey Konovalov <andreyknvl@google.com>
>> Date: Thu, 4 May 2017 14:28:37 +0200
>>
>>> On Thu, May 4, 2017 at 7:07 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>> Andrey reported a crash on init_net.ipv6.ip6_null_entry->rt6i_idev
>>>> since it is always NULL.
>>>>
>>>> This is clearly wrong, we have code to initialize it to loopback_dev,
>>>> unfortunately the order is still not correct.
>>>>
>>>> loopback_dev is registered very early during boot, we lose a chance
>>>> to re-initialize it in notifier. addrconf_init() is called after
>>>> ip6_route_init(), which means we have no chance to correct it.
>>>>
>>>> Fix it by moving this initialization explicitly after
>>>> ipv6_add_dev(init_net.loopback_dev) in addrconf_init().
>>>>
>>>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>>
>>> Hi Cong,
>>>
>>> This fixes the bug triggered by my reproducer.
>>>
>>> Thanks!
>>>
>>> Tested-by: Andrey Konovalov <andreyknvl@google.com>
>>
>> Applied and queued up for -stable, thanks.
>>
>
> This is not the complete solution; it only fixes init_net. It still
> blows up when you do:
>
> unshare -n
> ./rt6_device_match
>
>
> same exact stack trace

This is why I sent
[Patch net] ipv6: reorder ip6_route_dev_notifier after ipv6_dev_notf
