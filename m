From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v3 1/5] net-timestamp: extend SCM_TIMESTAMPING
 ancillary data struct
Date: Tue, 22 Jul 2014 11:45:30 -0400
Message-ID: <CA+FuTScobCk5EFgsht=S0mfF4fVh1fKqAAV8+mZLk9h1O_uwnA@mail.gmail.com>
References: <1405971357-22830-1-git-send-email-willemb@google.com>
 <1405971357-22830-2-git-send-email-willemb@google.com> <20140721.162448.2136956416390069389.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:62496 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753793AbaGVPqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 11:46:01 -0400
Received: by mail-vc0-f176.google.com with SMTP id id10so10565039vcb.21
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 08:46:00 -0700 (PDT)
In-Reply-To: <20140721.162448.2136956416390069389.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> 2) Add support to discern timestamps. When multiple timestamped
>> packets are in flight concurrently, correlating a timestamp with
>> the right send() call is non-trivial. Define previously unused field
>> ee_data to communicate a send() specific key, skb->mark. It is
>> up to the application to optionally set this field to a unique
>> value for each send call.
>
> I'm not so sure about this skb->mark usage, it has other uses for things
> such as classification, it influences route lookups, netfilter behavior,
> etc.
>
> I do not think you therefore want to add another usage, timestamp packet
> keying, which may conflict.

Ok. I will remove that part.

There are a few alternatives, but none as simple, so this is better
left to a separate patch. With skb_shinfo(skb)->syststamp deprecated
for all but the octeon legacy use case, it is possible to repurpose
those bytes for new uses in a union, including for a new u16 ts_key.
The sk would still have to grow by a new field, though, e.g.,
ts_counter. I have to think about this a bit more first.

> This isn't indented correctly, the tx_flags test is part of the sock_flag()
> test expression right before it so either:

Thanks.
