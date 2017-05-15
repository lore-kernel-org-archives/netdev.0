From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] udp: keep the sk_receive_queue held when
 splicing
Date: Mon, 15 May 2017 09:11:28 -0700
Message-ID: <1494864688.6465.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1494837879.git.pabeni@redhat.com>
         <41a898cfb2cf7ee618237a62bc48df1defed8957.1494837879.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34762 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965950AbdEOQLa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 12:11:30 -0400
Received: by mail-pg0-f68.google.com with SMTP id u187so17477912pgb.1
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 09:11:30 -0700 (PDT)
In-Reply-To: <41a898cfb2cf7ee618237a62bc48df1defed8957.1494837879.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-15 at 11:01 +0200, Paolo Abeni wrote:
> On packet reception, when we are forced to splice the
> sk_receive_queue, we can keep the related lock held, so
> that we can avoid re-acquiring it, if fwd memory
> scheduling is required.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---
>  net/ipv4/udp.c | 36 ++++++++++++++++++++++++++----------
>  1 file changed, 26 insertions(+), 10 deletions(-)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 492c76b..d698973 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1164,7 +1164,8 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
>  }
>  
>  /* fully reclaim rmem/fwd memory allocated for skb */
> -static void udp_rmem_release(struct sock *sk, int size, int partial)
> +static void udp_rmem_release(struct sock *sk, int size, int partial,
> +			     int rx_queue_lock_held)

Looks good, but please use a bool rx_queue_lock_held ?

Thanks !
