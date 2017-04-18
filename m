From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/3] bpf/wireless: add wifimon program type
Date: Tue, 18 Apr 2017 13:35:15 +0200
Message-ID: <1492515315.2472.24.camel@sipsolutions.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
         <1492007254.2855.10.camel@sipsolutions.net>
         <20170412.111913.497795978751789475.davem@davemloft.net>
         <1492011040.2855.18.camel@sipsolutions.net>
         <20170414185144.GB41922@ast-mbp.thefacebook.com>
         (sfid-20170414_205150_417889_20631AEB) <1492509349.2472.15.camel@sipsolutions.net>
         <58F5F148.1090700@iogearbox.net>
         <1492514882.2472.22.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, ast@kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48790 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756368AbdDRLfW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 07:35:22 -0400
In-Reply-To: <1492514882.2472.22.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So actually, come to think of it ...

> > The mapping in samples/bpf/bpf_helpers.h, for example, for
> > mentioned
> > bpf_skb_load_bytes() would also work out of the box, since it takes
> > a
> > void *ctx as an argument, so you can just pass the __wifi_sk_buff
> > pointer as ctx there from program side.
> 
> Hah. That's what I was missing - I always assumed the argument was
> "struct __sk_buff *" without ever checking that assumption.

Given this, I think I'll actually make a __wifi_sk_buff.

> The thing is that __wifi_sk_buff doesn't have much information that's
> generally useful available

Because I just realized that this isn't true. To make sense of the SKB
beyond the 802.11 header, which may not be possible at all though due
to encryption happening in software later, it will have to know a few
things like whether or not it was encrypted and if the IV was stripped
etc.

Actually, perhaps we should just restrict it to just look at the header
;-)

johannes
