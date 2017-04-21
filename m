From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ip6mr: avoid double unregister of pim6reg device
Date: Fri, 21 Apr 2017 13:20:32 -0700
Message-ID: <CAM_iQpXSP5ECw6ZXZXf44xb1Hh-yk4egbR55ZpjQwusBAOcgMw@mail.gmail.com>
References: <1492802839-16851-1-git-send-email-xiyou.wangcong@gmail.com> <db28d88e-ed4d-de81-fea2-c404a5b89af0@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32771 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162389AbdDUUUy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 16:20:54 -0400
Received: by mail-wm0-f67.google.com with SMTP id o81so6793000wmb.0
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 13:20:54 -0700 (PDT)
In-Reply-To: <db28d88e-ed4d-de81-fea2-c404a5b89af0@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 12:34 PM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> On 21/04/17 22:27, Cong Wang wrote:
>> If we unregister the pim6reg device via default_device_exit_batch(),
>> we will receive a notification and ip6mr_device_event() will
>> unregister it again. This causes a kernel BUG at net/core/dev.c:6813.
>>
>> Like commit 7dc00c82cbb0 ("ipv4: Fix ipmr unregister device oops")
>> we should avoid double-unregister in netdevice notifier.
>>
>> Reported-by: Andrey Konovalov <andreyknvl@google.com>
>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>  net/ipv6/ip6mr.c | 11 ++++++-----
>>  1 file changed, 6 insertions(+), 5 deletions(-)
>>
>
> Cong,
> Please read the full thread, I've already provided a fix which is similar.
> https://patchwork.ozlabs.org/patch/753531/

You beat me on that. ;) You should leave a reply to Andrey's report
otherwise people could miss it.
