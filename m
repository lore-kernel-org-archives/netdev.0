From: Donatas Abraitis <donatas.abraitis@gmail.com>
Subject: Re: [PATCH net-next v2] net: ipv6: make sure multicast packets are
 not forwarded beyond the different scopes
Date: Wed, 3 May 2017 10:53:56 +0300
Message-ID: <CAPF+HwWJz7kkjzW2g5pzTCnBebeOWh22mqPi8enH6Dcmt6PGKQ@mail.gmail.com>
References: <20170427071202.84403-1-donatas.abraitis@gmail.com> <20170502.145923.66844914584656456.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35702 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbdECHx5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 03:53:57 -0400
In-Reply-To: <20170502.145923.66844914584656456.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like there is this test already:

                if (IPV6_ADDR_MC_SCOPE(&ipv6_hdr(skb)->daddr) <=
                    IPV6_ADDR_SCOPE_NODELOCAL &&
                    !(dev->flags & IFF_LOOPBACK)) {
                        kfree_skb(skb);
                        return 0;
                }

On Tue, May 2, 2017 at 9:59 PM, David Miller <davem@davemloft.net> wrote:
> From: Donatas Abraitis <donatas.abraitis@gmail.com>
> Date: Thu, 27 Apr 2017 10:12:02 +0300
>
>>           RFC4291 2.7 Routers must not forward any multicast packets
>>           beyond of the scope indicated by the scop field in the
>>           destination multicast address.
>>
>> Signed-off-by: Donatas Abraitis <donatas.abraitis@gmail.com>
>
> I think it's a ">=" test which is needed here, not pure equality.
> Scopes are subsets of other scopes and are therefore allowed within
> eachother.
>
> Did you actually see misbehavior due to this issue, or see a real
> bonafide conformance test fail?
>
> If you're just reading the RFC and sticking tests here and there based
> upon what you read, without any testing or real life verification of
> the issue, this is _strongly_ discouraged.
>
> It would even be ok if you merely showed how another open source
> networking stack makes this test.



-- 
Donatas
