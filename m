From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Mon, 14 Aug 2017 14:25:23 -0400
Message-ID: <CAF=yD-JwAidB+Hc+sH9woBMR=3JUnbneB3fCRiJ3wmt3gzTcMg@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <2828157.5Eig1SAfYW@tjmaciei-mobl1>
 <CAF=yD-+k79=fykYs5x5-7AvE85+JPXv=NcfDy8X-4AGP8P85Pw@mail.gmail.com> <13347366.nbnduK6AMs@tjmaciei-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Thiago Macieira <thiago.macieira@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35916 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751160AbdHNS0E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 14:26:04 -0400
Received: by mail-oi0-f53.google.com with SMTP id g131so91661154oic.3
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 11:26:04 -0700 (PDT)
In-Reply-To: <13347366.nbnduK6AMs@tjmaciei-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 14, 2017 at 1:02 PM, Thiago Macieira
<thiago.macieira@intel.com> wrote:
> On Monday, 14 August 2017 09:33:48 PDT Willem de Bruijn wrote:
>> > But here's a question: if the peek offset is equal to the length, should
>> > the reading return an empty datagram? This would indicate to the caller
>> > that there was a datagram there, which was skipped over.
>>
>> In the general case, no, it should read at the offset, which is the next
>> skb.
>
> I beg to differ. In this particular case, we are talking about datagrams. If
> it were stream sockets, I would agree with you: just skip to the next. But in
> datagrams, the same way you do return zero-sized ones, I would return an empty
> one if you peeked at or past the end.

It can be argued either way. I would not change it in the scope of
this bug.

>
>> Since we only need to change no-offset semantics to fix this bug,
>> I would not change this behavior, which is also expected by some
>> applications by now.
>
> Do applications using SOCK_DGRAM rely on the behaviour of skipping over
> datagrams that are too short?

It is established behavior. It cannot be ruled out that an application
somewhere depends on it.
