From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v3] net: inet: diag: expose the socket mark to
 privileged processes.
Date: Fri, 9 Sep 2016 14:23:29 +0900
Message-ID: <CAKD1Yr2JovZ=dmNXuDCLT6gzVtC9JZ30bW6ND=10733je60bDw@mail.gmail.com>
References: <1473262945-144932-1-git-send-email-lorenzo@google.com>
 <20160908.161348.297729487225819070.davem@davemloft.net> <CAKD1Yr3p+ZcVbawRW98LCVEW763UYCj4tfHYxadk+dSuxfEy1A@mail.gmail.com>
 <20160908.175703.1354122300312111500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Erik Kline <ek@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35989 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbcIIFXu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 01:23:50 -0400
Received: by mail-oi0-f41.google.com with SMTP id q188so2470549oia.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 22:23:50 -0700 (PDT)
In-Reply-To: <20160908.175703.1354122300312111500.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2016 at 9:57 AM, David Miller <davem@davemloft.net> wrote:
>
> > I'll see if I can send something out to pass in in_skb instead.
>
> The other option is to have a "struct foo_info" object on the callers
> stack that holds all of these values, then pass a pointer to the foo_info
> to inet_sk_diag_fill.

RFC patch sent out as http://patchwork.ozlabs.org/patch/667892/ . This
achieves a fair bit of simplification with no or negligible
performance impact, because there was a lot of redundancy in the
parameters that were passed in.

Further simplification could be achieved by removing the "bool
net_admin" parameter. I didn't do this in this patch because I don't
know the performance impact of calling netlink_ns_capable once per
socket instead of once per dump. My guess is that that's in the noise
given that we're already doing lots of copying; if it is, I can send
out a v2 that removes the net_admin parameter as well.

Didn't try the struct since this seemed a good starting point. It
could be done later, of course.
