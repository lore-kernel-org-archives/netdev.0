From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: sk_buff rbnode reorg
Date: Tue, 19 Sep 2017 05:04:55 -0700
Message-ID: <1505822695.29839.48.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1505797616.29839.40.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36192 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdISME6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:04:58 -0400
Received: by mail-io0-f193.google.com with SMTP id n69so2823523ioi.3
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 05:04:57 -0700 (PDT)
In-Reply-To: <1505797616.29839.40.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-09-18 at 22:06 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>

...

> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -797,11 +797,6 @@ struct tcp_skb_cb {
>  			u16	tcp_gso_segs;
>  			u16	tcp_gso_size;
>  		};
> -
> -		/* Used to stash the receive timestamp while this skb is in the
> -		 * out of order queue, as skb->tstamp is overwritten by the
> -		 * rbnode.
> -		 */
>  		ktime_t		swtstamp;
>  	};


I forgot that in upstream kernels, swtstamp can also be removed.

It is used in our kernels to store the time at which the skb was moved
into socket receive queue (after a possible stay in out of order queue)

Will send a V2, removing this field from net-next, before we add it
again later if we upstream our instrumentation code.
