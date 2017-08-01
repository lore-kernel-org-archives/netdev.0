From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v3 net-next 1/4] tcp: ULP infrastructure
Date: Tue, 1 Aug 2017 11:27:20 -0700
Message-ID: <CALx6S364bOwz1pXgjWTLKR_k_So7kHspfSWQC0hkZZV_rA83dQ@mail.gmail.com>
References: <cover.1497465295.git.davejwatson@fb.com> <20170614183714.GA80310@davejwatson-mba.dhcp.thefacebook.com>
 <CALx6S35SmGC1ZSC9EiDH0gCUxGcFOJOTPOR-NzrgafKNC8oMYg@mail.gmail.com> <20170731221614.GB93172@dhcp-172-20-173-153.dhcp.thefacebook.com>
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
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37317 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752033AbdHAS1W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 14:27:22 -0400
Received: by mail-wm0-f41.google.com with SMTP id t201so22361450wmt.0
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 11:27:22 -0700 (PDT)
In-Reply-To: <20170731221614.GB93172@dhcp-172-20-173-153.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 3:16 PM, Dave Watson <davejwatson@fb.com> wrote:
> On 07/29/17 01:12 PM, Tom Herbert wrote:
>> On Wed, Jun 14, 2017 at 11:37 AM, Dave Watson <davejwatson@fb.com> wrote:
>> > Add the infrustructure for attaching Upper Layer Protocols (ULPs) over TCP
>> > sockets. Based on a similar infrastructure in tcp_cong.  The idea is that any
>> > ULP can add its own logic by changing the TCP proto_ops structure to its own
>> > methods.
>> >
>> > Example usage:
>> >
>> > setsockopt(sock, SOL_TCP, TCP_ULP, "tls", sizeof("tls"));
>> >
>> One question: is there a good reason why the ULP infrastructure should
>> just be for TCP sockets. For example, I'd really like to be able
>> something like:
>>
>> setsockopt(sock, SOL_SOCKET, SO_ULP, &ulp_param, sizeof(ulp_param));
>>
>> Where ulp_param is a structure containing the ULP name as well as some
>> ULP specific parameters that are passed to init_ulp. ulp_init could
>> determine whether the socket family is appropriate for the ULP being
>> requested.
>
> Using SOL_SOCKET instead seems reasonable to me.  I can see how
> ulp_params could have some use, perhaps at a slight loss in clarity.
> TLS needs its own setsockopts anyway though, for renegotiate for
> example.

I'll post the changes shortly. The reason to include parameters with
the setsockopt is so that we can push the ULP and start operations in
one shot.

Tom
