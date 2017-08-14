From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Mon, 14 Aug 2017 15:03:16 -0400
Message-ID: <CAF=yD-K4HgOhMMT0tWycZgcqhU5OACQk_roPQEeRems1_Azhgw@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1604496.falisOBPe2@tjmaciei-mobl1>
 <CAF=yD-L_-XrrPTfqYKGShqYdadER_Qo9_0CoAYE0r=NrircDXA@mail.gmail.com> <1756525.aGoekHffaC@tjmaciei-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Thiago Macieira <thiago.macieira@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:36052 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751752AbdHNTD5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 15:03:57 -0400
Received: by mail-oi0-f48.google.com with SMTP id g131so92603491oic.3
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 12:03:57 -0700 (PDT)
In-Reply-To: <1756525.aGoekHffaC@tjmaciei-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 14, 2017 at 2:58 PM, Thiago Macieira
<thiago.macieira@intel.com> wrote:
> On Monday, 14 August 2017 11:46:42 PDT Willem de Bruijn wrote:
>> > By the way, what were the usecases for the peek offset feature?
>>
>> The idea was to be able to peek at application headers of upper
>> layer protocols and multiplex messages among threads. It proved
>> so complex even for UDP that we did not attempt the same feature
>> for TCP. Also, KCM implements demultiplexing using eBPF today.
>
> Interesting, but how would userspace coordinate like that? Suppose multiple
> threads are woken up by a datagram being received

This assumes a separate listener thread and worker threadpool.
