From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP fast retransmit issues
Date: Wed, 26 Jul 2017 16:38:27 +0200
Message-ID: <20170726143827.GD1737@1wt.eu>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
 <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
 <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <fd335e0a0c914b9c42a754da2d24b1c3@vsen.dk>
 <20170726141847.GC1737@1wt.eu>
 <0b60368890bdb9aa1cf1df4bd0bf21cf@vsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Klavs Klavsen <kl@vsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:34242 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751772AbdGZOia (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 10:38:30 -0400
Content-Disposition: inline
In-Reply-To: <0b60368890bdb9aa1cf1df4bd0bf21cf@vsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 04:25:29PM +0200, Klavs Klavsen wrote:
> Thank you very much guys for your insight.. its highly appreciated.
> 
> Next up for me, is waiting till the network guys come back from summer
> vacation, and convince them to sniff on the devices in between to pinpoint
> the culprit :)

That said, Eric, I'm a bit surprized that it completely stalls. Shouldn't
the sender end up retransmitting unacked segments after seeing a certain
number of ACKs not making progress ? Or maybe this is disabled when SACKs
are in use but it seems to me that once invalid SACKs are ignored we should
ideally fall back to the normal way to deal with losses. Here the server
ACKed 3903858556 for the first time at 15:59:54.292743 and repeated this
one 850 times till 16:01:17.296407 but the client kept sending past this
point probably due to a huge window, so this looks suboptimal to me.

Willy
