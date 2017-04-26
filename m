From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/tcp: warning in tcp_try_coalesce/skb_try_coalesce
Date: Wed, 26 Apr 2017 07:16:13 -0700
Message-ID: <CANn89i+w0Ydc+i0vykneT55L=83KE9OvuLbk4H9Y7wG89UZ+Tg@mail.gmail.com>
References: <CAAeHK+xaFar2pj1xkbkhfjN+3ucLsfMpoHWFAKcHq3-F_Zm+mw@mail.gmail.com>
 <CAAeHK+yQJUuuv2XM6tQuaE12Zo1htujz6A7Qd_h+E9qCVEwDSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:33814 "EHLO
        mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1433592AbdDZOQP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 10:16:15 -0400
Received: by mail-yw0-f177.google.com with SMTP id k11so924496ywb.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 07:16:15 -0700 (PDT)
In-Reply-To: <CAAeHK+yQJUuuv2XM6tQuaE12Zo1htujz6A7Qd_h+E9qCVEwDSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 5:08 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Tue, Jan 31, 2017 at 2:17 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> Hi,
>>
>> I've got the following error report while running the syzkaller fuzzer.
>>
>> On commit 566cf877a1fcb6d6dc0126b076aad062054c2637 (4.10-rc6).
>>
>> The fuzzer hits this issue quite often, but I don't have a working reproducer.
>
> I still see this on 5a7ad1146caa895ad718a534399e38bd2ba721b7 (4.11-rc8).
>
> I also have a reproducer now, attached.
>
> It takes around 10 seconds for the warning to trigger.
>

It does not trigger for me, but seeing that you use SO_ATTACH_FILTER,
I have a pretty good idea how to remove this splat.

A call to skb_condense() from ___pskb_trim() will likely help, I will
post a patch after my commute.

Thanks.
