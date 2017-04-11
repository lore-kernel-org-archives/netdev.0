From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] net: move padding in struct skb_shared_info
Date: Tue, 11 Apr 2017 12:41:08 +0300
Message-ID: <CACVxJT9ixBPtO4JN=dgLT_gbDOQ8tL_kTFfoYmDahaomatCKEw@mail.gmail.com>
References: <20170410080755.GA24514@avx2> <1491835406.10587.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:33280 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754477AbdDKJlK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 05:41:10 -0400
Received: by mail-qk0-f196.google.com with SMTP id d131so3549366qkc.0
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 02:41:09 -0700 (PDT)
In-Reply-To: <1491835406.10587.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 10, 2017 at 5:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-04-10 at 11:07 +0300, Alexey Dobriyan wrote:
>>  struct skb_shared_info {
>> -     unsigned short  _unused;
>>       unsigned char   nr_frags;
>>       __u8            tx_flags;
>>       unsigned short  gso_size;
>
> Nack
>
> This exact placement was discussed at Netconf and Netdev.
>
> We had off-by-one errors in the past leading to nr_frags being mangled,
> and some exploits were quite happy to use these bugs.
>
> Some shuffling in shared_info might help us to find other bugs, and give
> more work to security researchers

By this logic there should be redzone around every field in networking stack.
