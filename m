From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] selftests/net: Add a test to validate
 behavior of rx timestamps
Date: Tue, 22 Aug 2017 17:39:14 -0400
Message-ID: <CAF=yD-+_6s=ePCvn6i7+a+DETSmqtLE23mt6rUtXhfWnCKz7og@mail.gmail.com>
References: <20170822210849.23162-1-maloneykernel@gmail.com> <20170822210849.23162-3-maloneykernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Mike Maloney <maloney@google.com>
To: Mike Maloney <maloneykernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36017 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752247AbdHVVj4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:39:56 -0400
Received: by mail-oi0-f53.google.com with SMTP id g131so199154207oic.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 14:39:56 -0700 (PDT)
In-Reply-To: <20170822210849.23162-3-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 5:08 PM, Mike Maloney <maloneykernel@gmail.com> wrote:
> From: Mike Maloney <maloney@google.com>
>
> Validate the behavior of the combination of various timestamp socket
> options, and ensure consistency across ip, udp, and tcp.
>
> Signed-off-by: Mike Maloney <maloney@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>

Thanks for adding these tests.

For tcp, it may be useful to eventually also add packetdrill tests
to validate the more subtle semantics, such as that the timestamp is
returned only when reading the last byte of the skb.

> +       do_send(src);
> +
> +       if (s.type == SOCK_RAW)
> +               read_size += 20;  /* for IP header */

No need to revise just for this, but if submitting a v3:

please use sizeof(struct iphdr). And maybe test PF_INET6, too.
