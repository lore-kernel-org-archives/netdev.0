From: Neal Cardwell <ncardwell@google.com>
Subject: Re: TCP fast retransmit issues
Date: Fri, 28 Jul 2017 18:54:41 -0400
Message-ID: <CADVnQym9JpC+vDVPVjP0ibhPQu3NhxsynRYA--FNzAgKJUJQSg@mail.gmail.com>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk> <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk> <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170726134242.GB1737@1wt.eu> <1501079532.12695.17.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170726145059.GE1737@1wt.eu> <CADVnQymKZAc+SFD7X-FoP9UwHgB2MBCY48=dL8mH6XuKumkx4g@mail.gmail.com>
 <CADVnQykEX-LzhsqyfHNmV6fF9-d_2R0v+mOX-PnyagUhC1qQzQ@mail.gmail.com>
 <CADVnQynR8dUuUBDfeFR2xpL-wKzd+7TgbMv-CXe3TT-T0_PXyQ@mail.gmail.com> <CADVnQynVfm0V=16sr+rHsJhtHx9b+kM7Vn2edW2GJ7qMaAtDJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Klavs Klavsen <kl@vsen.dk>,
        Netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:34582 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752763AbdG1WzM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 18:55:12 -0400
Received: by mail-oi0-f43.google.com with SMTP id x3so140491009oia.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 15:55:12 -0700 (PDT)
In-Reply-To: <CADVnQynVfm0V=16sr+rHsJhtHx9b+kM7Vn2edW2GJ7qMaAtDJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 3:02 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Wed, Jul 26, 2017 at 2:38 PM, Neal Cardwell <ncardwell@google.com> wrote:
>> Yeah, it looks like I can reproduce this issue with (1) bad sacks
>> causing repeated TLPs, and (2) TLPs timers being pushed out to later
>> times due to incoming data. Scripts are attached.
>
> I'm testing a fix of only scheduling a TLP if (flag & FLAG_DATA_ACKED)
> is true...

An update for the TLP aspect of this thread: our team has a proposed
fix for this RTO/TLP reschedule issue that we have reviewed internally
and tested with our packetdrill test suite, including some new tests.
The basic approach in the fix is as follows:

a) only reschedule the xmit timer once per ACK

b) only reschedule the xmit timer if tcp_clean_rtx_queue() deems this
is safe (a packet was cumulatively ACKed, or we got a SACK for a
packet that was sent before the most recent retransmit of the write
queue head).

After further review and testing we will post it. Hopefully next week.

thanks,
neal
