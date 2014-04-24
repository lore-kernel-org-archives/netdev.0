From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] ipv6_fib limit spinlock hold times for
 /proc/net/ipv6_route
Date: Thu, 24 Apr 2014 07:20:49 -0700
Message-ID: <1398349249.29914.67.camel@edumazet-glaptop2.roam.corp.google.com>
References: <535918BC.5030708@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Mason <clm@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:40020 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbaDXOUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 10:20:50 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so1970335pad.21
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 07:20:50 -0700 (PDT)
In-Reply-To: <535918BC.5030708@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-04-24 at 09:59 -0400, Chris Mason wrote:
> The ipv6 code to dump routes in /proc/net/ipv6_route can hold
> a read lock on the table for a very long time.  This ends up blocking
> writers and triggering softlockups.
> 
> This patch is a simple work around to limit the number of entries
> we'll walk while processing /proc/net/ipv6_route.  It intentionally
> slows down proc file reading to make sure we don't lock out the
> real ipv6 traffic.
> 
> This patch is also horrible, and doesn't actually fix the entire
> problem.  We still have rcu_read_lock held the whole time we cat
> /proc/net/ipv6_route.  On an unpatched machine, I've clocked the
> time required to cat /proc/net/ipv6_route at 14 minutes.
> 
> java cats this proc file on startup to search for local routes, and the
> resulting contention on the table lock makes our boxes fall over.
> 
> So, I'm sending the partial fix to get discussion started.
> 
> Signed-off-by: Chris Mason <clm@fb.com>
> 
> ---

It might be time to convert this to RCU and/or a better data structure.
