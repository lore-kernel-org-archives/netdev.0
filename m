From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: fix bogus cast in skb_pagelen() and use unsigned variables
Date: Wed, 23 Nov 2016 18:35:43 +0300
Message-ID: <CACVxJT90bUVFFZkCS1uxRLbptGFRUDYdtoXiXg8xufeucSsa=g@mail.gmail.com>
References: <20161119010808.GF1200@avx2> <063D6719AE5E284EB5DD2968C1650D6DB02265B3@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:36132 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965352AbcKWPfp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 10:35:45 -0500
Received: by mail-wj0-f193.google.com with SMTP id jb2so1298430wjb.3
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 07:35:45 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB02265B3@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 3:49 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Alexey Dobriyan
>> Sent: 19 November 2016 01:08
> ...
>> -     for (i = (int)skb_shinfo(skb)->nr_frags - 1; i >= 0; i--)
>> +     for (i = skb_shinfo(skb)->nr_frags - 1; (int)i >= 0; i--)
>>               len += skb_frag_size(&skb_shinfo(skb)->frags[i]);
>
> Think I'd use:
>         for (i = skb_shinfo(skb)->nr_frags; i-- != 0; )

This kind of diverges from canonical loop form:

  for (init; temination condition: iterator)

by shifting everything into termination part.

  A
