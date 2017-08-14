From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Mon, 14 Aug 2017 14:46:42 -0400
Message-ID: <CAF=yD-L_-XrrPTfqYKGShqYdadER_Qo9_0CoAYE0r=NrircDXA@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <13347366.nbnduK6AMs@tjmaciei-mobl1>
 <CAF=yD-JwAidB+Hc+sH9woBMR=3JUnbneB3fCRiJ3wmt3gzTcMg@mail.gmail.com> <1604496.falisOBPe2@tjmaciei-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Thiago Macieira <thiago.macieira@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:32843 "EHLO
        mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751472AbdHNSrX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 14:47:23 -0400
Received: by mail-oi0-f46.google.com with SMTP id f11so92254631oic.0
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 11:47:23 -0700 (PDT)
In-Reply-To: <1604496.falisOBPe2@tjmaciei-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 14, 2017 at 2:33 PM, Thiago Macieira
<thiago.macieira@intel.com> wrote:
> On Monday, 14 August 2017 11:25:23 PDT Willem de Bruijn wrote:
>> > Do applications using SOCK_DGRAM rely on the behaviour of skipping over
>> > datagrams that are too short?
>>
>> It is established behavior. It cannot be ruled out that an application
>> somewhere depends on it.
>
> Understood.
>
> By the way, what were the usecases for the peek offset feature?

The idea was to be able to peek at application headers of upper
layer protocols and multiplex messages among threads. It proved
so complex even for UDP that we did not attempt the same feature
for TCP. Also, KCM implements demultiplexing using eBPF today.

> Also, do they apply to non-peeking recv?

Reading at an offset is not implemented. Especially for RPC over
TCP, reading at an offset could make sense. Say, if a message
is received completely, but it is head-of-line blocked behind
another that has a hole. Here, too, KCM is an alternative.
