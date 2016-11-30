From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sock: reset sk_err for ICMP packets read from
 error queue
Date: Wed, 30 Nov 2016 11:27:00 -0800
Message-ID: <1480534020.18162.200.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480532468-1610-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com,
        willemb@google.com, maze@google.com, hannes@stressinduktion.org,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33414 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755249AbcK3T2C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:28:02 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so2146781pgd.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 11:28:02 -0800 (PST)
In-Reply-To: <1480532468-1610-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 14:01 -0500, Soheil Hassas Yeganeh wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> Only when ICMP packets are enqueued onto the error queue,
> sk_err is also set. Before f5f99309fa74 (sock: do not set sk_err
> in sock_dequeue_err_skb), a subsequent error queue read
> would set sk_err to the next error on the queue, or 0 if empty.
> As no error types other than ICMP set this field, sk_err should
> not be modified upon dequeuing them.
> 
> Only for ICMP errors, reset the (racy) sk_err. Some applications,
> like traceroute, rely on it and go into a futile busy POLLERR
> loop otherwise.
> 
> In principle, sk_err has to be set while an ICMP error is queued.
> Testing is_icmp_err_skb(skb_next) approximates this without
> requiring a full queue walk. Applications that receive both ICMP
> and other errors cannot rely on this legacy behavior, as other
> errors do not set sk_err in the first place.
> 
> Fixes: f5f99309fa74 (sock: do not set sk_err in sock_dequeue_err_skb)
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---


Acked-by: Eric Dumazet <edumazet@google.com>
