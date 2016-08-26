From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Thu, 25 Aug 2016 19:34:14 -0700
Message-ID: <1472178854.14381.180.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
         <1471524527-10029-2-git-send-email-fw@strlen.de>
         <1472162771.14381.167.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160825234657.GA13469@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36011 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756473AbcHZCeR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 22:34:17 -0400
Received: by mail-pa0-f46.google.com with SMTP id di2so22331353pad.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 19:34:16 -0700 (PDT)
In-Reply-To: <20160825234657.GA13469@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-08-26 at 01:46 +0200, Florian Westphal wrote:

> Wrt. making randomization optional:
> 
> Would you go for another sysctl or should I just change
> secure_tcpvX_sequence_number to check for tcp_timestamps == 2 mode?
> 
> 	*tsoff  = sysctl_tcp_timestamps == 2 ? hash[1] : 0;

I've not yet look at your "add tcp_timestamps=2 mode to force tsecr
validation on ofo segments" patch.
It looks a bit scary to me :(

I would rather have a separate sysctl, or maybe a per route attribute.

Note that this could be done later.

> 
> Could also use a static key but I don't think its worth it vs. md5 cost.
> What do you think?

A static key wont help a lot I think ;)
