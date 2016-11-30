From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH net-next] sock: reset sk_err for ICMP packets read from
 error queue
Date: Wed, 30 Nov 2016 21:49:38 +0100
Message-ID: <CAHo-OozCXBwsDgQ1hDUP6SOQ6wWBTp7=XRRtTE+oASQPXe5+0A@mail.gmail.com>
References: <1480532468-1610-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Linux NetDev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:35514 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755593AbcK3Uts (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 15:49:48 -0500
Received: by mail-yw0-f195.google.com with SMTP id b66so15540138ywh.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 12:49:39 -0800 (PST)
In-Reply-To: <1480532468-1610-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 8:01 PM, Soheil Hassas Yeganeh
<soheil.kdev@gmail.com> wrote:
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

Acked-by: Maciej =C5=BBenczykowski <maze@google.com>
