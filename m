From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/3] proto_ops: Add locked held versions of
 sendmsg and sendpage
Date: Thu, 3 Aug 2017 14:07:28 -0700
Message-ID: <CALx6S37kxOgZBE+8jvuLQDXSM+C86DSstfkhX4NjUpiT+-g6eQ@mail.gmail.com>
References: <20170728232243.3040-1-tom@quantonium.net> <20170728232243.3040-2-tom@quantonium.net>
 <598385D4.5050205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:37581 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751746AbdHCVHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 17:07:30 -0400
Received: by mail-wr0-f193.google.com with SMTP id 12so1777161wrb.4
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 14:07:29 -0700 (PDT)
In-Reply-To: <598385D4.5050205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 3, 2017 at 1:21 PM, John Fastabend <john.fastabend@gmail.com> wrote:
> On 07/28/2017 04:22 PM, Tom Herbert wrote:
>> Add new proto_ops sendmsg_locked and sendpage_locked that can be
>> called when the socket lock is already held. Correspondingly, add
>> kernel_sendmsg_locked and kernel_sendpage_locked as front end
>> functions.
>>
>> These functions will be used in zero proxy so that we can take
>> the socket lock in a ULP sendmsg/sendpage and then directly call the
>> backend transport proto_ops functions.
>>
>
> [...]
>
>>
>> +int kernel_sendpage_locked(struct sock *sk, struct page *page, int offset,
>> +                        size_t size, int flags)
>> +{
>> +     struct socket *sock = sk->sk_socket;
>> +
>> +     if (sock->ops->sendpage_locked)
>> +             return sock->ops->sendpage_locked(sk, page, offset, size,
>> +                                               flags);
>> +
>> +     return sock_no_sendpage_locked(sk, page, offset, size, flags);
>> +}
>
> How about just returning EOPNOTSUPP here and force implementations to do both
> sendmsg and sendpage. The only implementation of these callbacks already does
> this. And if its any other socket it will just wind its way through a few
> layers of calls before returning EOPNOTSUPP.
>
Seems reasonable, but we should probably make the same change to
kernel_sendpage to be consistent.

Tom

> .John
