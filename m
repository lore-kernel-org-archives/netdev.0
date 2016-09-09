From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v3] net: inet: diag: expose the socket mark to
 privileged processes.
Date: Fri, 9 Sep 2016 09:48:27 +0900
Message-ID: <CAKD1Yr3p+ZcVbawRW98LCVEW763UYCj4tfHYxadk+dSuxfEy1A@mail.gmail.com>
References: <1473262945-144932-1-git-send-email-lorenzo@google.com> <20160908.161348.297729487225819070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Erik Kline <ek@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:36099 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750974AbcIIAss (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:48:48 -0400
Received: by mail-oi0-f47.google.com with SMTP id x125so49632377oia.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 17:48:48 -0700 (PDT)
In-Reply-To: <20160908.161348.297729487225819070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2016 at 8:13 AM, David Miller <davem@davemloft.net> wrote:
>> This adds the capability for a process that has CAP_NET_ADMIN on
>> a socket to see the socket mark in socket dumps.
>
> Applied, but the argument list of inet_sk_diag_fill is starting to get out
> of control.

I think a lot of the parameters it takes are just a couple of pointer
lookups away from in_skb. I assumed it did not take in_skb directly
for performance reasons: this way the calling functions can calculate
many of these arguments just once per dump instead of once per socket.
But thinking about it some more the cost of those pointer lookups is
negligible compared to the cost of iterating over the hashtables,
marshalling the attributes, etc.

I'll see if I can send something out to pass in in_skb instead.
