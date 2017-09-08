From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Fri, 8 Sep 2017 09:12:09 -0700
Message-ID: <CAM_iQpV--V9ROSd61CWVbcpCHonMUubLeyEKVSvEUTTW3gh5hA@mail.gmail.com>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org> <20170908025620.47d0ad2e@elisabeth>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: Stefano Brivio <sbrivio@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35356 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbdIHQMa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 12:12:30 -0400
Received: by mail-pg0-f65.google.com with SMTP id q68so1499042pgq.2
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 09:12:30 -0700 (PDT)
In-Reply-To: <20170908025620.47d0ad2e@elisabeth>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 7, 2017 at 5:56 PM, Stefano Brivio <sbrivio@redhat.com> wrote:
> On Thu, 07 Sep 2017 18:52:02 -0600
> Subash Abhinov Kasiviswanathan <subashab@codeaurora.org> wrote:
>
>> We are seeing a possible use after free in ip6_dst_destroy.
>>
>> It appears as if memory of the __DST_METRICS_PTR(old) was freed in some
>> path and allocated
>> to ion driver. ion driver has also freed it. Finally the memory is freed
>> by the
>> fib gc and crashes since it is already deallocated.
>>
>> Target is running an ARM64 Android based 4.9 kernel.
>> Issue was seen once on a regression rack (sorry, no reproducer).
>> Any pointers to debug this is highly appreciated.
>>
>> [ 3489.470581] [<ffffff83c0a289c0>] object_err+0x4c/0x5c
>> [ 3489.470586] [<ffffff83c0a2b284>] free_debug_processing+0x2e0/0x398
>> [ 3489.470589] [<ffffff83c0a2b63c>] __slab_free+0x300/0x3e0
>> [ 3489.470593] [<ffffff83c0a2bfc8>] kfree+0x28c/0x290
>> [ 3489.470601] [<ffffff83c16b9580>]
>> __dst_destroy_metrics_generic+0x6c/0x78
>> [ 3489.470609] [<ffffff83c17d3408>] ip6_dst_destroy+0xb0/0xb4
>
> Should be fixed by:
>
> commit ad65a2f05695aced349e308193c6e2a6b1d87112
> Author: Wei Wang <weiwan@google.com>
> Date:   Sat Jun 17 10:42:35 2017 -0700
>
>     ipv6: call dst_hold_safe() properly


Obviously it should not. One is dst metric, the other is dst.
