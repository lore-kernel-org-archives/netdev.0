From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Thu, 18 Aug 2016 09:18:12 -0700
Message-ID: <1471537092.29842.62.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
         <1471524527-10029-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36005 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754080AbcHSBIR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:08:17 -0400
Received: by mail-pf0-f171.google.com with SMTP id h186so3639687pfg.3
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 18:08:17 -0700 (PDT)
In-Reply-To: <1471524527-10029-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-08-18 at 14:48 +0200, Florian Westphal wrote:
> commit ceaa1fef65a7c2e ("tcp: adding a per-socket timestamp offset")
> added the main infrastructure that is needed for per-connection
> randomization, in particular writing/reading the on-wire tcp header
> format takes the offset into account so rest of stack can use normal
> tcp_time_stamp (jiffies).
> 
> So only two items are left:
>  - add a tsoffset for request sockets
>  - extend the tcp isn generator to also return another 32bit number
>  in addition to the ISN.
> 
> Re-use of ISN generator also means timestamps are still monotonically
> increasing for same connection quadruple.

I like the idea, but the implementation looks a bit complex.

Instead of initializing tsoffset to 0, we could simply use

jhash(src_addr, dst_addr, boot_time_rnd)

This way, even syncookies would be handled, and we do not need to
increase tcp_request_sock size.
