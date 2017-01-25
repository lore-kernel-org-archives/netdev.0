From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: correct memory barrier usage in
 tcp_check_space()
Date: Tue, 24 Jan 2017 20:53:37 -0800
Message-ID: <1485320017.16328.386.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485312581-13041-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Oleg Nesterov <oleg@redhat.com>
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34650 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751137AbdAYExk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 23:53:40 -0500
Received: by mail-pg0-f68.google.com with SMTP id 3so765905pgj.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 20:53:40 -0800 (PST)
In-Reply-To: <1485312581-13041-1-git-send-email-jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-24 at 21:49 -0500, Jason Baron wrote:
> From: Jason Baron <jbaron@akamai.com>
> 
> sock_reset_flag() maps to __clear_bit() not the atomic version clear_bit().
> Thus, we need smp_mb(), smp_mb__after_atomic() is not sufficient.
> 
> Fixes: 3c7151275c0c ("tcp: add memory barriers to write space paths")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Jason Baron <jbaron@akamai.com>
> ---
>  net/ipv4/tcp_input.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>

I believe this would need also this for proper attribution.

Reported-by: Oleg Nesterov <oleg@redhat.com>
