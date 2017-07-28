From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP fast retransmit issues
Date: Fri, 28 Jul 2017 09:27:50 +0200
Message-ID: <20170728072750.GA6437@1wt.eu>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
 <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
 <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <fd335e0a0c914b9c42a754da2d24b1c3@vsen.dk>
 <20170726141847.GC1737@1wt.eu>
 <0b60368890bdb9aa1cf1df4bd0bf21cf@vsen.dk>
 <20170726143827.GD1737@1wt.eu>
 <0d41553d-69ac-651c-9c41-743391619a40@vsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Klavs Klavsen <kl@vsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:34329 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751740AbdG1H1x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Jul 2017 03:27:53 -0400
Content-Disposition: inline
In-Reply-To: <0d41553d-69ac-651c-9c41-743391619a40@vsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 08:36:49AM +0200, Klavs Klavsen wrote:
> The network guys know what caused it.
> 
> Appearently on (atleast some) Cisco equipment the feature:
> 
> TCP Sequence Number Randomization
> 
> is enabled by default.

I didn't want to suggest names but since you did it first ;-) Indeed it's
mostly on the same device that I've been bothered a lot by their annoying
randomization. I used to know by memory the exact command to type to disable
it, but I don't anymore (something along "no randomization"). The other
trouble it causes is retransmits of the first SYN when your source ports
wrap too fast (ie when installed after a proxy). The SYNs reaching the
other end find a session in TIME_WAIT, but the SYN sometimes lands in
the previous window and leads to an ACK instead of a SYN-ACK, which the
firewall blocks. This was easily worked around using timestamps on both
sides thanks to PAWS. But disabling the broken feature is better. And no,
"more secure" is not an excuse for "broken".

> It would most definetely be beneficial if Linux handled SACK "not working"
> better than it does - but then I might never have found the culprit who
> destroyed SACK :)

Yep ;-)

Willy
