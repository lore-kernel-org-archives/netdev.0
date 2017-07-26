From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP fast retransmit issues
Date: Wed, 26 Jul 2017 07:32:12 -0700
Message-ID: <1501079532.12695.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
         <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
         <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
         <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170726134242.GB1737@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Klavs Klavsen <kl@vsen.dk>, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35546 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752059AbdGZOcR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 10:32:17 -0400
Received: by mail-wm0-f51.google.com with SMTP id c184so80460793wmd.0
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 07:32:16 -0700 (PDT)
In-Reply-To: <20170726134242.GB1737@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-07-26 at 15:42 +0200, Willy Tarreau wrote:
> On Wed, Jul 26, 2017 at 06:31:21AM -0700, Eric Dumazet wrote:
> > On Wed, 2017-07-26 at 14:18 +0200, Klavs Klavsen wrote:
> > > the 192.168.32.44 is a Centos 7 box.
> > 
> > Could you grab a capture on this box, to see if the bogus packets are
> > sent by it, or later mangled by a middle box ?
> 
> Given the huge difference between the window and the ranges of the
> values in the SACK field, I'm pretty sure there's a firewall doing
> some sequence numbers randomization in the middle, not aware of SACK
> and not converting these ones. I've had to disable such broken
> features more than once in field after similar observations! Probably
> that the Mac doesn't advertise SACK support and doesn't experience the
> problem.

We need to check RFC if such invalid SACK blocks should be ignored (DUP
ACK would be processed and trigger fast retransmit anyway), or strongly
validated (as I suspect we currently do), leading to a total freeze.
