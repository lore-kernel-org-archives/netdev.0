From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Thu, 25 Aug 2016 07:15:41 -0700
Message-ID: <1472134541.14381.126.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
         <1471524527-10029-2-git-send-email-fw@strlen.de>
         <1471537092.29842.62.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160825090602.GA30509@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33837 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759249AbcHYOVX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 10:21:23 -0400
Received: by mail-pf0-f173.google.com with SMTP id p64so18319308pfb.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 07:21:22 -0700 (PDT)
In-Reply-To: <20160825090602.GA30509@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-25 at 11:06 +0200, Florian Westphal wrote:
> So I gave this a try and it does avoid this tcp_request_sock increase,
> but I feel that getting boot_time_rnd is too easy.

Fair enough, I didn't think very hard about it.

> 
> I tried a few other ideas but nothing satisfying/simpler came out of it
> (e.g. i tried to also hash the isn but that gets scaled w. current
>  clock so it doesn't work).
> 
> Are you more concerned wrt. complexity or the reqsk increase?
> 

No, a reqsk increase is really fine.

I guess I was simply worrying your work would make my future submission
more tricky.

Here at Google we have been using usec resolution in TCP timestamps for
a while for all our DC traffic, and we have to upstream this at some
point.

It would be nice if the randomization was optional, because having usec
timestamps with a common base (ie no per flow random base) helps a lot
to understand the host delays at transmit time, and receive time.

I will review your patch more in depth today, thanks.
