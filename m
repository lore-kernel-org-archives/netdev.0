From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 -next 1/2] tcp: syncookies: reduce cookie lifetime to
 128 seconds
Date: Wed, 19 Mar 2014 13:38:44 -0700
Message-ID: <1395261524.9114.60.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1379709176-1625-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:42197 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753166AbaCSUi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 16:38:56 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so9137976pdi.21
        for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 13:38:55 -0700 (PDT)
In-Reply-To: <1379709176-1625-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-20 at 22:32 +0200, Florian Westphal wrote:
> We currently accept cookies that were created less than 4 minutes ago
> (ie, cookies with counter delta 0-3).  Combined with the 8 mss table
> values, this yields 32 possible values (out of 2**32) that will be valid.
> 
> Reducing the lifetime to < 2 minutes halves the guessing chance while
> still providing a large enough period.
> 
> While at it, get rid of jiffies value -- they overflow too quickly on
> 32 bit platforms.
> 
> getnstimeofday is used to create a counter that increments every 64s.
> perf shows getnstimeofday cost is negible compared to sha_transform;
> normal tcp initial sequence number generation uses getnstimeofday, too.

The getnstimeofday() cost is about 40 cycles if TSC is used, but if this
source is not available and hpet is used, it is more 1600 cycles ...

I'll send a patch to use local_clock() instead (26 to 30 cycles)
