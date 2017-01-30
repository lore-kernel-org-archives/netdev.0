From: Dimitris Michailidis <dmichail@google.com>
Subject: Re: [PATCH] ipv6: fix flow labels when the traffic class is non-0
Date: Mon, 30 Jan 2017 15:51:10 -0800
Message-ID: <CAG76Sjb7J+pCZ4MhMYC-_L9_c587xA2XPqORGUFSZ9ESsouP5w@mail.gmail.com>
References: <20170130220942.19105-1-dmichail@google.com> <CALx6S375e127OSj9cHk4JuJLdee6tUmnBz7gSrsWTSLFP84JaA@mail.gmail.com>
 <CANn89iLCyo8RgjHAg7YsQJCpS-P=76M5ZN1Ps3HhAzm-gZJpGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35739 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753582AbdAaAAE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 19:00:04 -0500
Received: by mail-io0-f177.google.com with SMTP id j18so120139119ioe.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 15:58:42 -0800 (PST)
In-Reply-To: <CANn89iLCyo8RgjHAg7YsQJCpS-P=76M5ZN1Ps3HhAzm-gZJpGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 3:45 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Mon, Jan 30, 2017 at 3:40 PM, Tom Herbert <tom@herbertland.com> wrote:
>
>> Thanks for pointing out the issue, but I don't think this fix is quite
>> right. This would be discarding traffic class from being in the return
>> value. I can try to fix that.
>
> Fix looks fine to me.
>
> ip6_make_flowlabel() is usually used in an enclosing ip6_flow_hdr(),
> which gives the tclass.
>
> ip6_flow_hdr(hdr, tclass, ip6_make_flowlabel(net, skb, fl6->flowlabel,
>
>   np->autoflowlabel, fl6));

Yes, all the callers of ip6_make_flowlabel() I've seen feed the result
to ip6_flow_hdr().
