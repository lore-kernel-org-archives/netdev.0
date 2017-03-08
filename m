From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net/socket: use per af lockdep classes for sk
 queues
Date: Wed, 08 Mar 2017 09:02:29 -0800
Message-ID: <1488992549.28631.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <8a8c8226f5b728166e94f794eb9a5b9012e706c5.1488989373.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Florian Westphal <fw@strlen.de>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35356 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753674AbdCHRL0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 12:11:26 -0500
Received: by mail-pf0-f195.google.com with SMTP id 67so4373770pfg.2
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 09:11:25 -0800 (PST)
In-Reply-To: <8a8c8226f5b728166e94f794eb9a5b9012e706c5.1488989373.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-08 at 17:25 +0100, Paolo Abeni wrote:

>  - no changes, tested with several different workload
> 
> Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/core/sock.c | 96 ++++++++++++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 78 insertions(+), 18 deletions(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index f6fd79f..b7a3359 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -258,12 +258,66 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
>    "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_KCM"      ,
>    "clock-AF_QIPCRTR", "clock-AF_SMC"     , "clock-AF_MAX"
>  };


>  
> +static void sk_init_locks(struct sock *sk)
> +{
> +	skb_queue_head_init(&sk->sk_receive_queue);
> +	skb_queue_head_init(&sk->sk_write_queue);
> +	skb_queue_head_init(&sk->sk_error_queue);
> +
> +	rwlock_init(&sk->sk_callback_lock);
> +	lockdep_set_class_and_name(&sk->sk_receive_queue.lock,
...
> +}

This is minor, but the function name does not really reflect what it
does.

Thanks !
