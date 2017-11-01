From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SKB Reference Question
Date: Wed, 01 Nov 2017 12:44:25 -0700
Message-ID: <1509565465.3828.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CABGNecw9thLB4XOFdWRghj6E_uMrFroVko-Up6hodS75hmb4sg@mail.gmail.com>
         <1509557611.3828.45.camel@edumazet-glaptop3.roam.corp.google.com>
         <CABGNecySKtpPb2VjqugXYLX4wif=f07nf=F3WZvfc4M0k4CJGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Joe Smith <codesoldier1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:43037 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752797AbdKATo1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 15:44:27 -0400
Received: by mail-io0-f180.google.com with SMTP id 134so8653103ioo.0
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 12:44:26 -0700 (PDT)
In-Reply-To: <CABGNecySKtpPb2VjqugXYLX4wif=f07nf=F3WZvfc4M0k4CJGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-11-01 at 12:22 -0700, Joe Smith wrote:
> On Wed, Nov 1, 2017 at 10:33 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2017-11-01 at 10:27 -0700, Joe Smith wrote:
> >> How strictly are references on the SKB enforced. For example,
> >> tcp_transmit_skb() clones the SKB and adds a TCP header. Can I assume
> >> that in case of re-transmission the header added will be there and can
> >> be reused instead of creating a new one from scratch. Some fields like
> >> time stamp would need to be updated but they should be unmodified.
> >
> >
> > Not sure what you are trying to do, but this seems messy ;)
> 
> As an example, consider reusing options that might be expensive to
> calculate. Assuming no coalescing.
> 
> >
> > At rtx time, there is no guarantee that the master skb has not been
> > changed, so the content of TCP header might be wrong anyway.
> 
> I would have thought that each layer below TCP would only add itś own
> header and would not touch anything else. Is that not the guarantee
> that SKB references provideś, or else the data could be changed.
> 
> Can you give an example why the TCP header could change.

Before rtx, skbs can be split or coalesced.

Depending on ACK received from opposite peer, available cwnd budget,
pacing rate...

Also ECN can play a role.
