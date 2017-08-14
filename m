From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Mon, 14 Aug 2017 12:33:48 -0400
Message-ID: <CAF=yD-+k79=fykYs5x5-7AvE85+JPXv=NcfDy8X-4AGP8P85Pw@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1846443.VTclhqQinN@ring00>
 <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com> <2828157.5Eig1SAfYW@tjmaciei-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Thiago Macieira <thiago.macieira@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33664 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752219AbdHNQe3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 12:34:29 -0400
Received: by mail-oi0-f49.google.com with SMTP id f11so88821312oic.0
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 09:34:29 -0700 (PDT)
In-Reply-To: <2828157.5Eig1SAfYW@tjmaciei-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 14, 2017 at 12:06 PM, Thiago Macieira
<thiago.macieira@intel.com> wrote:
> On Monday, 14 August 2017 08:03:50 PDT Willem de Bruijn wrote:
>> > I'm actually surprised that only unix sockets can have negative values.
>> > Is
>> > there a reason for that?  I had assumed that sk_set_peek_off would allow
>> > negative values as the code already has to support negative values due to
>> > what the initial value is.
>>
>> A negative initial value indicates that PEEK_OFF is disabled. It only
>> makes sense to peek from a positive offset from the start of the data.
>
> But here's a question: if the peek offset is equal to the length, should the
> reading return an empty datagram? This would indicate to the caller that there
> was a datagram there, which was skipped over.

In the general case, no, it should read at the offset, which is the next skb.

Zero length packets are a special case. This did come up before and
we chose to signal their existence in the queue by returning 0 for each
once, even in the offset-enabled mode.

Since we only need to change no-offset semantics to fix this bug,
I would not change this behavior, which is also expected by some
applications by now.

>
> That's how we deal with empty datagrams anyway.

What is? With no-offset and a zero payload skb at the head, peek
or recv returns 0, right?
