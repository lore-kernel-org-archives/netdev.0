From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: new kmemleak reports (was: Re: [PATCH 0/5] genetlink improvements)
Date: Wed, 2 Nov 2016 13:30:34 -0700
Message-ID: <CAM_iQpV_0gyrJC0U6Qk9VSSaNOphe_0tq5o2kt8-r0UybLU5FA@mail.gmail.com>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
 <20161101172840.6d7d6278@jkicinski-Precision-T1700> <CAM_iQpVeB+2M1MPxjRx++E=q4mDuo7XQqfQn3-160PqG8bNLdQ@mail.gmail.com>
 <20161101185630.3c7d326f@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes@sipsolutions.net>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34243 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756148AbcKBUaz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 16:30:55 -0400
Received: by mail-oi0-f68.google.com with SMTP id 62so2859851oif.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 13:30:55 -0700 (PDT)
In-Reply-To: <20161101185630.3c7d326f@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 1, 2016 at 11:56 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Tue, 1 Nov 2016 11:32:52 -0700, Cong Wang wrote:
>> On Tue, Nov 1, 2016 at 10:28 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
>> > unreferenced object 0xffff8807389cba28 (size 128):
>> >   comm "swapper/0", pid 1, jiffies 4294898463 (age 781.332s)
>> >   hex dump (first 32 bytes):
>> >     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
>> >     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
>> >   backtrace:
>> >     [<ffffffff85decad8>] kmemleak_alloc+0x28/0x50
>> >     [<ffffffff84771246>] __kmalloc+0x206/0x5a0
>> >     [<ffffffff859e1261>] genl_register_family+0x711/0x11d0
>> >     [<ffffffff888d9524>] netlbl_mgmt_genl_init+0x10/0x12
>> >     [<ffffffff888d91e8>] netlbl_netlink_init+0x9/0x26
>> >     [<ffffffff888d9254>] netlbl_init+0x4f/0x85
>> >     [<ffffffff840022b7>] do_one_initcall+0xb7/0x2a0
>> >     [<ffffffff887f9102>] kernel_init_freeable+0x597/0x636
>> >     [<ffffffff85de7793>] kernel_init+0x13/0x140
>> >     [<ffffffff85e0246a>] ret_from_fork+0x2a/0x40
>>
>> Looks like we are missing a kfree(family->attrbuf); on error path,
>> but it is not related to Johannes' recent patches.
>>
>> Could the attached patch help?
>>
>> Thanks.
>
> Still there:
>
> unreferenced object 0xffff88073fb204e8 (size 64):
>   comm "swapper/0", pid 1, jiffies 4294898455 (age 88.528s)
>   hex dump (first 32 bytes):
>     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
>     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
>   backtrace:
>     [<ffffffff93decbf8>] kmemleak_alloc+0x28/0x50
>     [<ffffffff92771246>] __kmalloc+0x206/0x5a0
>     [<ffffffff939e1471>] genl_register_family+0x921/0x1270
>     [<ffffffff968d0ecf>] genl_init+0x11/0x43
>     [<ffffffff920022b7>] do_one_initcall+0xb7/0x2a0
>     [<ffffffff967f9102>] kernel_init_freeable+0x597/0x636
>     [<ffffffff93de78b3>] kernel_init+0x13/0x140
>     [<ffffffff93e0256a>] ret_from_fork+0x2a/0x40
>     [<ffffffffffffffff>] 0xffffffffffffffff
>
> etc.

Interesting, from the size it does look like we are leaking family->attrbuf,
but I don't see other cases could leak it except the error path I fixed.

Mind doing a quick bisect?

Thanks!
