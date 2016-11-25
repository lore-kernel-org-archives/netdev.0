From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: Re: Large performance regression with 6in4 tunnel (sit)
Date: Fri, 25 Nov 2016 05:06:53 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1611250503250.22094@aurora.sdinet.de>
References: <20161125120947.142c3af5@canb.auug.org.au>        <cf2fff0a-7d41-1416-0056-3718ea50a5bd@gmx.com> <20161125134520.68ca0969@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eli Cooper <elicooper@gmx.com>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.sdinet.de ([136.243.3.21]:59862 "EHLO mail.sdinet.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751500AbcKYEQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 23:16:16 -0500
In-Reply-To: <20161125134520.68ca0969@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Nov 2016, Stephen Rothwell wrote:

> On Fri, 25 Nov 2016 10:18:12 +0800 Eli Cooper <elicooper@gmx.com> wrote:
> >
> > Sounds like TSO/GSO packets are not properly segmented and therefore
> > dropped.
> > 
> > Could you first try turning off segmentation offloading for the tunnel
> > interface?
> >     ethtool -K sit0 tso off gso off
> 
> On Thu, 24 Nov 2016 18:30:14 -0800 Eric Dumazet <eric.dumazet@gmail.com>
> >
> > You also could try to disable TSO and see if this makes a difference
> > 
> > ethtool -K sixtofour0 tso off
> 
> So turning off tso brings performance up to IPv4 levels ...
> 
> Thanks for that, it solves my immediate problem.

Somehow this problem description really reminds me of a report on 
netdev a bit ago, which the following patch fixed:

commit 9ee6c5dc816aa8256257f2cd4008a9291ec7e985
Author: Lance Richardson <lrichard@redhat.com>
Date:   Wed Nov 2 16:36:17 2016 -0400

    ipv4: allow local fragmentation in ip_finish_output_gso()
    
    Some configurations (e.g. geneve interface with default
    MTU of 1500 over an ethernet interface with 1500 MTU) result
    in the transmission of packets that exceed the configured MTU.
    While this should be considered to be a "bad" configuration,
    it is still allowed and should not result in the sending
    of packets that exceed the configured MTU.

Could this be related?

I suppose it would be difficult to test this patch on this machine?

c'ya
sven-haegar

-- 
Three may keep a secret, if two of them are dead.
- Ben F.
