From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] doc: document MSG_ZEROCOPY
Date: Thu, 31 Aug 2017 23:04:41 -0400
Message-ID: <CAF=yD-+HaGUYYitWYxVvYUyQUBerw-1YhTnKBdz+_qYJ_T=fdA@mail.gmail.com>
References: <20170831210013.85220-1-willemdebruijn.kernel@gmail.com> <20170901021007.pkbb2gsipbprf4w7@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35344 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbdIADFW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 23:05:22 -0400
Received: by mail-oi0-f66.google.com with SMTP id n18so865522oig.2
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 20:05:22 -0700 (PDT)
In-Reply-To: <20170901021007.pkbb2gsipbprf4w7@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 10:10 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Aug 31, 2017 at 05:00:13PM -0400, Willem de Bruijn wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Documentation for this feature was missing from the patchset.
>> Copied a lot from the netdev 2.1 paper, addressing some small
>> interface changes since then.
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ...
>> +Notification Batching
>> +~~~~~~~~~~~~~~~~~~~~~
>> +
>> +Multiple outstanding packets can be read at once using the recvmmsg
>> +call. This is often not needed. In each message the kernel returns not
>> +a single value, but a range. It coalesces consecutive notifications
>> +while one is outstanding for reception on the error queue.
>> +
>> +When a new notification is about to be queued, it checks whether the
>> +new value extends the range of the notification at the tail of the
>> +queue. If so, it drops the new notification packet and instead increases
>> +the range upper value of the outstanding notification.
>
> Would it make sense to mention that max notification range is 32-bit?
> So each 4Gbyte of xmit bytes there will be a notification.
> In modern 40Gbps NICs it's not a lot. Means that there will be
> at least one notification every second.
> Or I misread the code?

You're right. The doc does mention that the counter and range
are 32-bit. I can state more explicitly that that bounds the working
set size to 4GB. Do you expect this to be problematic? Processing
a single notification per 4GB of data should not be a significant
cost in itself.

> Thanks for the doc!

Thanks for reviewing :)

>
> Acked-by: Alexei Starovoitov <ast@kernel.org>
>
