From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net] netfilter: xt_TCPMSS: handle CHECKSUM_COMPLETE in tcpmss_tg6()
Date: Fri, 15 Jan 2016 09:25:40 -0800
Message-ID: <CALx6S341pXBgh9DJBfzOao_DVm5VMB6AC5dvV2Krju=f+PMkNQ@mail.gmail.com>
References: <1452874892.1223.175.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S348Td5ZHVDTOn+DudAjs9pNjhs6kkEbn-CgYCqXEh0BQg@mail.gmail.com>
	<1452878324.1223.188.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35427 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924AbcAORZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 12:25:40 -0500
Received: by mail-io0-f176.google.com with SMTP id 77so461868959ioc.2
        for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 09:25:40 -0800 (PST)
In-Reply-To: <1452878324.1223.188.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 15, 2016 at 9:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-01-15 at 08:43 -0800, Tom Herbert wrote:
>
>> Probably should have a utility function do this. Maybe something like
>> update_hdr_field(skb, old, new)? Could return new value so above could
>> just be:
>>
>> ipv6h->payload_len = update_hdr_field(skb, ipv6h->payload_len,
>> htons(ntohs(oldlen) + ret);
>
> Well, oldlen would still need to be ipv6h->payload_len
>
That comes from the second argument.

> Not sure a helper will be nice for a stable submission.
>
> Probably better for net-next ?
>
I think this would apply to ipv6: update skb->csum when CE mark is
propagated also, maybe others? Seems safer to implement the logic only
in one place if possible... No big deal though.

>
