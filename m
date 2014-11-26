From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net] net-timestamp: make tcp_recvmsg call ipv6_recv_error
 for AF_INET6 socks
Date: Wed, 26 Nov 2014 15:03:01 -0500
Message-ID: <CA+FuTSdf=3cw7rGhAmPo+hh2qnn_GgPG3Xy8Er259_FxjTur3w@mail.gmail.com>
References: <1417031582-16480-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org,
	Patrick McHardy <kaber@trash.net>,
	Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:36721 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaKZUDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 15:03:32 -0500
Received: by mail-qg0-f51.google.com with SMTP id l89so2524759qgf.38
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 12:03:31 -0800 (PST)
In-Reply-To: <1417031582-16480-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2014 at 2:53 PM, Willem de Bruijn <willemb@google.com> wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> TCP timestamping introduced MSG_ERRQUEUE handling for TCP sockets.
> If the socket is of family AF_INET6, call ipv6_recv_error instead
> of ip_recv_error.
>
> This change is more complex than a single branch due to the loadable
> ipv6 module. It reuses a pre-existing indirect function call from
> ping. The ping code is safe to call, because it is part of the core
> ipv6 module and always present when AF_INET6 sockets are active.

I forgot to add:

Fixes: 4ed2d765 (net-timestamp: TCP timestamping)

> Signed-off-by: Willem de Bruijn <willemb@google.com>
>
> ----
>
> It may also be worthwhile to add WARN_ON_ONCE(sk->family == AF_INET6)
> to ip_recv_error.
