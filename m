From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Tue, 15 Aug 2017 13:00:14 -0400
Message-ID: <CAF=yD-+jBim==ktwYUNAFkn-N4eabqgNME8NXM77v9-U_bfWPg@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502702846.8411.25.camel@redhat.com>
 <1846443.VTclhqQinN@ring00> <CAF=yD-L9CpW-DRtKfWWWKcNKcPSWvXOkTGZoKBq6=fQMrcKVWQ@mail.gmail.com>
 <1502724662.8411.53.camel@redhat.com> <CAF=yD-+ZNPtF1h1OT=_4yuE7=XtireP_OtbyBefHGdwtJ_ontQ@mail.gmail.com>
 <1502811641.3475.7.camel@redhat.com> <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36162 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751598AbdHORAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 13:00:55 -0400
Received: by mail-oi0-f49.google.com with SMTP id g131so12703675oic.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 10:00:55 -0700 (PDT)
In-Reply-To: <CAF=yD-Lacw9T7G0XZBdHZwEb6HgRuaBoyUN1oTvWixu4a0Fy6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There is another difference between reading sk_peek_offset in the
> caller or in __skb_try_recv_from_queue. The latter is called repeatedly
> when it returns NULL. Each call can modify *off. I believe that it needs
> to restart with _off at sk->sk_peek_off each time, as it restarts from the
> head of the queue each time.

I made a mistake here. *off is not updated when returning NULL.

In that case, it is better to read sk_peek_offset once, than to read
it each time __skb_try_recv_from_queue is entered.
