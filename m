From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next 1/2] tcp: remove per-destination timestamp cache
Date: Thu, 16 Mar 2017 11:40:52 -0400
Message-ID: <CADVnQy=Bxs-e-KxQsA8nPSfm9fVtogouxCRdgmrR0WyBkMS=Xw@mail.gmail.com>
References: <20170315203046.158791-1-soheil.kdev@gmail.com>
 <20170315.154044.170788541865531834.davem@davemloft.net> <20170315225508.GB14761@1wt.eu>
 <58CA778D.9020208@5t9.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Florian Westphal <fw@strlen.de>
To: Lutz Vieweg <lvml@5t9.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f179.google.com ([74.125.82.179]:34922 "EHLO
        mail-ot0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753229AbdCPPle (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 11:41:34 -0400
Received: by mail-ot0-f179.google.com with SMTP id x37so59948290ota.2
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 08:41:34 -0700 (PDT)
In-Reply-To: <58CA778D.9020208@5t9.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 16, 2017 at 7:31 AM, Lutz Vieweg <lvml@5t9.de> wrote:
>
> On 03/15/2017 11:55 PM, Willy Tarreau wrote:
>>
>> At least I can say I've seen many people enable it without understanding its impact, confusing it
>> with tcp_tw_reuse, and copy-pasting it from random blogs and complaining about issues in
>> production.
>
>
> I currently wonder: What it the correct advise to an operator who needs
> to run one server instance that is meant to accept thousands of new,
> short-lived TCP connections per minute?

Note that for this to be a problem there would have to be thousands of
new, short-lived TCP connections per minute from a single source IP
address to a single destination IP address. Normal client software
should not be doing this. AFAIK this is pretty rare, unless someone is
running a load test or has an overly-aggressive monitoring system. NAT
boxes or proxies with that kind of traffic should be running with
multiple public source IPs.

But if/when the problem occurs, then the feasible solutions I'm aware
of, in approximate descending order of preference, are:

(1) use longer connections from the client side (browsers and RPC libraries are
    usually pretty good about keeping connections open for a long time, so this
    is usually sufficient)

(2) have the client do the close(), so the client is the side to carry the
    TIME_WAIT state

(3) have the server use SO_LINGER with a timeout of 0, so that
    the connection is closed with a RST and the server carries no
    TIME_WAIT state

neal
