From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v3 net-next 1/4] tcp: ULP infrastructure
Date: Sat, 29 Jul 2017 13:12:27 -0700
Message-ID: <CALx6S35SmGC1ZSC9EiDH0gCUxGcFOJOTPOR-NzrgafKNC8oMYg@mail.gmail.com>
References: <cover.1497465295.git.davejwatson@fb.com> <20170614183714.GA80310@davejwatson-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Nikos Mavrogiannopoulos <nmav@gnutls.org>,
        =?UTF-8?B?RnJpZG9sw61uIFBva29ybsO9?= <fridolin.pokorny@gmail.com>
To: Dave Watson <davejwatson@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:37623 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdG2UM2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 16:12:28 -0400
Received: by mail-wr0-f174.google.com with SMTP id 33so109175580wrz.4
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 13:12:28 -0700 (PDT)
In-Reply-To: <20170614183714.GA80310@davejwatson-mba.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 14, 2017 at 11:37 AM, Dave Watson <davejwatson@fb.com> wrote:
> Add the infrustructure for attaching Upper Layer Protocols (ULPs) over TCP
> sockets. Based on a similar infrastructure in tcp_cong.  The idea is that any
> ULP can add its own logic by changing the TCP proto_ops structure to its own
> methods.
>
> Example usage:
>
> setsockopt(sock, SOL_TCP, TCP_ULP, "tls", sizeof("tls"));
>
Hi Dave,

Thanks for this work. I think this functionality is going to have many uses!

One question: is there a good reason why the ULP infrastructure should
just be for TCP sockets. For example, I'd really like to be able
something like:

setsockopt(sock, SOL_SOCKET, SO_ULP, &ulp_param, sizeof(ulp_param));

Where ulp_param is a structure containing the ULP name as well as some
ULP specific parameters that are passed to init_ulp. ulp_init could
determine whether the socket family is appropriate for the ULP being
requested.

Thanks,
Tom
