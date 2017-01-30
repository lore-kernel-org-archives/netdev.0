From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] ipv6: fix flow labels when the traffic class is non-0
Date: Mon, 30 Jan 2017 15:45:35 -0800
Message-ID: <CANn89iLCyo8RgjHAg7YsQJCpS-P=76M5ZN1Ps3HhAzm-gZJpGw@mail.gmail.com>
References: <20170130220942.19105-1-dmichail@google.com> <CALx6S375e127OSj9cHk4JuJLdee6tUmnBz7gSrsWTSLFP84JaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dimitris Michailidis <dmichail@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:34415 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752802AbdA3Xq1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 18:46:27 -0500
Received: by mail-io0-f174.google.com with SMTP id l66so120203265ioi.1
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 15:45:36 -0800 (PST)
In-Reply-To: <CALx6S375e127OSj9cHk4JuJLdee6tUmnBz7gSrsWTSLFP84JaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 3:40 PM, Tom Herbert <tom@herbertland.com> wrote:

> Thanks for pointing out the issue, but I don't think this fix is quite
> right. This would be discarding traffic class from being in the return
> value. I can try to fix that.

Fix looks fine to me.

ip6_make_flowlabel() is usually used in an enclosing ip6_flow_hdr(),
which gives the tclass.

ip6_flow_hdr(hdr, tclass, ip6_make_flowlabel(net, skb, fl6->flowlabel,

  np->autoflowlabel, fl6));
