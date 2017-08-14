From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] af_key: do not use GFP_KERNEL in atomic contexts
Date: Mon, 14 Aug 2017 17:07:27 -0600
Message-ID: <eed2872e-d214-955a-5103-49b2b72f18ab@gmail.com>
References: <1502731005.4936.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35466 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752916AbdHNXH3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 19:07:29 -0400
Received: by mail-pg0-f67.google.com with SMTP id l64so12813789pge.2
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 16:07:29 -0700 (PDT)
In-Reply-To: <1502731005.4936.29.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/14/17 11:16 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> pfkey_broadcast() might be called from non process contexts,
> we can not use GFP_KERNEL in these cases [1].
> 
> This patch partially reverts commit ba51b6be38c1 ("net: Fix RCU splat in
> af_key"), only keeping the GFP_ATOMIC forcing under rcu_read_lock()
> section.
> 
> [1] : syzkaller reported :
...
> Fixes: ba51b6be38c1 ("net: Fix RCU splat in af_key")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: David Ahern <dsa@cumulusnetworks.com>
> ---
>  net/key/af_key.c |   48 ++++++++++++++++++++++++---------------------
>  1 file changed, 26 insertions(+), 22 deletions(-)
> 

Thanks for the fix, Eric.

Acked-by: David Ahern <dsahern@gmail.com>
