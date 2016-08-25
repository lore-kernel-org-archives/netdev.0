From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Thu, 25 Aug 2016 09:05:47 -0700
Message-ID: <1472141147.14381.136.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
         <1471524527-10029-2-git-send-email-fw@strlen.de>
         <1471537092.29842.62.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160825090602.GA30509@breakpoint.cc>
         <1472134541.14381.126.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160825144958.GA5248@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36289 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755410AbcHYQgZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:36:25 -0400
Received: by mail-pa0-f54.google.com with SMTP id di2so18326939pad.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:36:25 -0700 (PDT)
In-Reply-To: <20160825144958.GA5248@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-25 at 16:49 +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Here at Google we have been using usec resolution in TCP timestamps for
> > a while for all our DC traffic, and we have to upstream this at some
> > point.
> > 
> > It would be nice if the randomization was optional, because having usec
> > timestamps with a common base (ie no per flow random base) helps a lot
> > to understand the host delays at transmit time, and receive time.
> 
> Would it help to make it per-host instead of per-flow?

Not really.

By looking at tcpdump, and TS val of xmit packets of multiple flows, we
can deduct the relative qdisc delays (think of fq pacing).
This should work even if we have one flow per remote peer.

> 
> > I will review your patch more in depth today, thanks.
> 
> Great, thanks a lot!
