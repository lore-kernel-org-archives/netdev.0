From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: adjust skb->truesize in pskb_expand_head()
Date: Fri, 27 Jan 2017 08:14:55 -0800
Message-ID: <1485533695.6360.64.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485476480.5145.194.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DB0270970@AcuExch.aculab.com>
         <1485528261.6360.38.camel@edumazet-glaptop3.roam.corp.google.com>
         <063D6719AE5E284EB5DD2968C1650D6DB0270D8B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Slava Shwartsman <slavash@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32802 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755097AbdA0QoZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 11:44:25 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so25403354pgd.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 08:44:24 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0270D8B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-27 at 15:46 +0000, David Laight wrote:

> Reads code ...
> My confusion is that the call is specifying the number of EXTRA bytes of head/tail
> room rather than the number of bytes needed.

And the fact that @size is changed in existing code (so not visible in
patch diff) to

size = SKB_WITH_OVERHEAD(ksize(data));


> I was thinking that pskb_expand_head(skb, 16, -16, ...) could be implemented
> (mostly) with memmove().

Yes, might worth doing that if one day a caller tries that ;)

In the meantime, not worth adding code that wont be reached.

Thanks.
