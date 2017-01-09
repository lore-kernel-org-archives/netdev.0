From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/3] net: reduce cycles spend on ICMP replies
 that gets rate limited
Date: Mon, 09 Jan 2017 09:44:10 -0800
Message-ID: <1483983850.5846.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170109150246.30215.63371.stgit@firesoul>
         <20170109150409.30215.34612.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34356 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933442AbdAIRoM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:44:12 -0500
Received: by mail-pg0-f66.google.com with SMTP id b1so52218295pgc.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 09:44:12 -0800 (PST)
In-Reply-To: <20170109150409.30215.34612.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-09 at 16:04 +0100, Jesper Dangaard Brouer wrote:
> This patch split the global and per (inet)peer ICMP-reply limiter
> code, and moves the global limit check to earlier in the packet
> processing path.  Thus, avoid spending cycles on ICMP replies that
> gets limited/suppressed anyhow.
> 
> The global ICMP rate limiter icmp_global_allow() is a good solution,
> it just happens too late in the process.  The kernel goes through the
> full route lookup (return path) for the ICMP message, before taking
> the rate limit decision of not sending the ICMP reply.
> 
> Details: The kernels global rate limiter for ICMP messages got added
> in commit 4cdf507d5452 ("icmp: add a global rate limitation").  It is
> a token bucket limiter with a global lock.  It brilliantly avoids
> locking congestion by only updating when 20ms (HZ/50) were elapsed. It
> can then avoids taking lock when credit is exhausted (when under
> pressure) and time constraint for refill is not yet meet.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---


Acked-by: Eric Dumazet <edumazet@google.com>
