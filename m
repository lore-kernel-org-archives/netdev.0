From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2 v2] net: Add function to get SW rxhash
Date: Tue, 24 Sep 2013 15:16:36 -0700
Message-ID: <CA+mtBx94yRWRNkfcbkOmFhMcspdyb-Q=jn0=dkAVTZrj-XFCDQ@mail.gmail.com>
References: <alpine.DEB.2.02.1309241335380.23856@tomh.mtv.corp.google.com>
	<1380058203.3165.121.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35475 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991Ab3IXWQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 18:16:37 -0400
Received: by mail-ie0-f174.google.com with SMTP id u16so9632801iet.5
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 15:16:36 -0700 (PDT)
In-Reply-To: <1380058203.3165.121.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 2:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-09-24 at 13:42 -0700, Tom Herbert wrote:
>> Some uses of skb_get_rxhash expect that the function will return
>> a consistent value whether it is called on RX or TX paths. On RX
>> path, we will use the rxhash if provided by the NIC, so this
>> would not normally be the same result computed in TX path would be
>> a software calculation.
>>
>> This patch adds skb_get_sw_rxhash to explicitly request a hash
>> calculated by the stack, disregarding the hash provided by NIC.
>
> As I said, I think this is overhead in network fast path.
>
The overhead is setting one in additional bit in skb_get_rxhash.
Alternatively, we could just take out the symmetric hashing code in
get_rps_code which is two or three conditionals and have tun do its
own hash as you mention.  Since skb_get_rxhash tries to use HW value
anyway, it's pretty non deterministic as to how often we'd set the
symmetric hash, much less be able advantage of the symmetric property.
 If it's a big win for conntrack to process packets on same CPUs for
both directions, we should program the RFS table to accomplish that.

> This can be done without adding a new skb field.
>
> I suspect tun should not use rxhash but a proper hash, as conntrack or
> tcp...
>
>
>
