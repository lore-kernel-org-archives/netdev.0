From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Thu, 17 Aug 2017 10:37:31 -0400
Message-ID: <CAF=yD-KnjmCkqZuphj4yJdpB0j6NuBXGHUev4Z1zecN8+95d-Q@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502702846.8411.25.camel@redhat.com>
 <1846443.VTclhqQinN@ring00> <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
 <1502724662.8411.53.camel@redhat.com> <CAF=yD-+ZNPtF1h1OT=_4yuE7=XtireP_OtbyBefHGdwtJ_ontQ@mail.gmail.com>
 <1502811641.3475.7.camel@redhat.com> <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
 <CAF=yD-+jBim==ktwYUNAFkn-N4eabqgNME8NXM77v9-U_bfWPg@mail.gmail.com>
 <1502875722.3548.11.camel@redhat.com> <CAF=yD-K8FMicoSS6u-0r_J0p0fTyn4GNwhXn7_gRSSMYmAzw5g@mail.gmail.com>
 <1502914822.2796.6.camel@redhat.com> <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0058EDB@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Paolo Abeni <pabeni@redhat.com>,
        Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35488 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750991AbdHQOiN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 10:38:13 -0400
Received: by mail-oi0-f68.google.com with SMTP id q70so6606557oic.2
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 07:38:13 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0058EDB@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 5:15 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Willem de Bruijn
>> Sent: 17 August 2017 00:27
>> Actually, it is safe even without the check. Overflow of the signed integer
>> is benign here.
>
> IIRC the C language states that 'signed integer overflow' is undefined.
> So 'MAXINT + 1' doesn't have to equal '-MAXINT - 1' (as one would
> expect on a 2's compliment system).
>
> While the linux kernel probably won't run on systems where this isn't true
> (eg where signed arithmetic saturates) gcc will assume it can't happen
> and optimise code with that assumption.

Ah, of course. Thanks. The last patch does not rely on such tricks, indeed.

On rereading, it is actually very similar to Matthew's original. The
main difference is handling the negative offset case inside
__skb_try_recv_from_queue instead of in each caller.
