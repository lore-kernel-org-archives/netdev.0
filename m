From: Eric Dumazet <edumazet@google.com>
Subject: Re: [RFC PATCH] sock: add SO_RCVQUEUE_SIZE getsockopt
Date: Mon, 13 Mar 2017 09:12:32 -0700
Message-ID: <CANn89iJ21dhirFW2OdNqHWfOgq-EieVMm5ou9pZ7g2oUz=+bfA@mail.gmail.com>
References: <1489420786-19547-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Arnd Bergmann <arnd@arndb.de>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Paolo Abeni <pabeni@redhat.com>, linux-arch@vger.kernel.org,
        netdev <netdev@vger.kernel.org>
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:37622 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753991AbdCMQMo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 12:12:44 -0400
Received: by mail-it0-f52.google.com with SMTP id g138so34548125itb.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 09:12:38 -0700 (PDT)
In-Reply-To: <1489420786-19547-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 8:59 AM, Josh Hunt <johunt@akamai.com> wrote:
> Allows application to read the amount of data sitting in the receive
> queue.
>
> Signed-off-by: Josh Hunt <johunt@akamai.com>
> ---
>
> A team here is looking for a way to get the amount of data in a UDP socket's
> receive queue. It seems like this should be SIOCINQ, but for UDP sockets that
> returns the size of the next pending datagram. I implemented the patch below,
> but am wondering if this is the right place for this change? I was debating
> between this or a new UDP ioctl.

But what is the 'amount of data' exactly ?
Number of packets, amount of bytes to read from these packets ?

You chose to report kernel memory usage, which is not guaranteed to be
the same among kernels versions (or kernel configs)

If we export these internals, I would export the whole thing, like we
did with netlink

ie tweak sock_diag_put_meminfo() and export the SK_MEMINFO_VARS

So that we avoid adding other options in the future.
